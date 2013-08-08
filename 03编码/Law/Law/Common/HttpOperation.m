//
//  HttpOperation.m
//  Law
//
//  Created by shulianyong on 13-3-20.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "HttpOperation.h"
#import "AFNetworking.h"
#import "NSDate+SynsWindowsTime.h"

#import "UserInfo.h"
#import "Subjects.h"
#import "ArticlesOfLaw.h"
#import "News.h"
#import "DALNews.h"

#import "DALArticlesOfLaw.h"
#import "DAlUserSubject.h"
#import "DALSubjects.h"
#import "DALSubjectsOfArticles.h"

#import "AlertViewUtil.h"

@implementation HttpOperation

+ (AFHTTPClient*)httpClient
{
    static AFHTTPClient *client = nil;
    if (client == nil) {
        client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
        client.parameterEncoding = AFJSONParameterEncoding;
        [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }    
    return client;
}

+ (dispatch_queue_t)httpOperationQueue
{
    static dispatch_queue_t httpOperationQueue = NULL;
    if (httpOperationQueue==NULL) {        
        httpOperationQueue = dispatch_queue_create("httpOperationQueue", NULL);
    }
    return httpOperationQueue;
}

+ (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, NSDictionary *jsonResponseDict))success
         failure:(void (^)(_HTTPErrorStatus status))failure

{
    
    AFHTTPClient *httpClient = [HttpOperation httpClient];
    [httpClient postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async([HttpOperation httpOperationQueue], ^{
            dispatch_queue_t mainDispatch =  dispatch_get_main_queue();
            NSDictionary *jsonResponseDict = [operation.responseString JSONValue];
//            INFO(@"url:%@ ->response:%@",path,jsonResponseDict);            
            INFO(@"url:%@ ->parameters:%@",path,parameters);
            BOOL ExecutionResult = [[jsonResponseDict objectForKey:@"ExecutionResult"] boolValue];
            NSString *message = [jsonResponseDict objectForKey:@"Message"];
            if (ExecutionResult) {
                success(operation,jsonResponseDict);
            }
            else
            {
                failure(ExecutionError);
                dispatch_sync(mainDispatch, ^{
                    [CommonUtil showMessage:message];
                });                
            }
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async([HttpOperation httpOperationQueue], ^{
            INFO(@"network error:%@",error);
            failure(NetWorkError);
        });
    }];
}

+ (void)processLastUpdataTime:(void (^)(NSTimeInterval executionResult))result
{
    __block NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    AFHTTPClient *httpClient = [HttpOperation httpClient];
    [httpClient postPath:CurrentServerDateTime parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async([HttpOperation httpOperationQueue], ^{
            NSString *jsonValue = operation.responseString;
            jsonValue = [jsonValue stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            jsonValue = [jsonValue stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//            INFO(@"url:%@ ->response:%@",CurrentServerDateTime,jsonValue);
            NSTimeInterval timeValue = [NSDate timeIntervalFromJsonDate:jsonValue];
            if (timeValue>1) {
                currentTime = timeValue;
            }
            result(currentTime);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        result(currentTime);
    }];   
}

+ (void)validateToken:(void (^)(BOOL executionResult))result
{    
    UserInfo *userInfo = [UserInfo shareInstance];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 userInfo.AccessToken, @"AccessToken",
                                 nil];
    [self postPath:ValidateTokenUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonResponseDict) {
        BOOL Valid = [[jsonResponseDict objectForKey:@"Valid"] boolValue];        
        result(Valid);
    } failure:^(_HTTPErrorStatus status) {
        if (status==NetWorkError) {
            result(YES);
        }
        else if(status == ExecutionError)
        {
            result(NO);
        }
    }];
}

static float volatile updateProgressValue = 0;
static float volatile updateProgressMaxValue = 6;
+ (void)checkAllUpdates:(BOOL)isUserCenter
{
    if (isUserCenter) {
        [CommonUtil showLoadingWithTitle:checkUpdateLoadingString];
    }
    
    updateProgressValue = 0;
    updateProgressMaxValue=6;
    UserInfo *userInfo = [UserInfo shareInstance];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 userInfo.AccessToken, @"AccessToken",
                                 [NSDate jsonTimeFromTimeInterval:[CommonUtil timeIntervalForSyncNews]],@"LastUpdateTimeOfNews",
                                 [NSDate jsonTimeFromTimeInterval:[CommonUtil timeIntervalForUpdateSubject]],@"LastUpdateTimeOfSubjects",
                                 [NSDate jsonTimeFromTimeInterval:[CommonUtil timeIntervalForUpdateArticles]],@"LastUpdateTimeOfArticles",
                                 nil];
    [self postPath:CheckAllUpdatesUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonResponseDict) {
//        BOOL NewsUpdatesExist = [[jsonResponseDict objectForKey:@"NewsUpdatesExist"] boolValue];
        BOOL SubjectUpdatesExist = [[jsonResponseDict objectForKey:@"SubjectUpdatesExist"] boolValue];
        BOOL ArticleUpdatesExist = [[jsonResponseDict objectForKey:@"ArticleUpdatesExist"] boolValue];
        
        BOOL Status = [[jsonResponseDict objectForKey:@"Status"] boolValue];
        NSString *Message = [jsonResponseDict objectForKey:@"Message"];
        NSArray *messages = [Message componentsSeparatedByString:@"|"];        
        [CommonUtil setImportantStatus:Status];
        if (Status) {            
            NSString *message = [messages objectAtIndex:0];
            NSString *address = [messages objectAtIndex:1];
            [CommonUtil setImportantAddress:address];
            [CommonUtil setImportantMessage:message];
        }
        
        _UpdateDataStatus updateStatus = UpdateNone;
        if (SubjectUpdatesExist&&ArticleUpdatesExist) {
            updateStatus = UpdateAllData;
        }
        else if (SubjectUpdatesExist)
        {
            updateStatus = UpdateSubjectsData;
        }
        else if(ArticleUpdatesExist)
        {
            updateStatus = UpdateArticlesData;
        }
        
        if (updateStatus>UpdateNone) {
            dispatch_queue_t mainDispatch =  dispatch_get_main_queue();
            dispatch_sync(mainDispatch, ^{                
                [[AlertViewUtil shareInstance] alertMessage:updateDataString withOkBlock:^{
                    [AlertViewUtil shareInstance].canceled = NO;
                    updateProgressValue+=1;
                    [[AlertViewUtil shareInstance] showTitle:downloadingString atProcessIndex:updateProgressValue/updateProgressMaxValue];
                    if (SubjectUpdatesExist) {
                        [HttpOperation updateLawSubjects:updateStatus];
                    }
                    if (ArticleUpdatesExist) {
                        [HttpOperation updateArticles:updateStatus];
                    }
                    
                }];                
            });
        }
        
        if (isUserCenter)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [CommonUtil endLoading];
                if (updateStatus==UpdateNone) {
                    [CommonUtil showMessage:HaveNoUpdateDataString];
                }
            });
        }
        
        
    } failure:^(_HTTPErrorStatus status) {
        if (isUserCenter) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [CommonUtil endLoading];
                if (status == NetWorkError) {
                    [CommonUtil showMessage:networkDisconnectedString];
                }
                else
                {
                    [CommonUtil showMessage:HaveNoUpdateDataString];
                }
            });
        }
    }];
}

+ (void)getUserLawSubjects
{
    UserInfo *userInfo = [UserInfo shareInstance];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 userInfo.AccessToken, @"AccessToken",
                                 nil];   
    [self postPath:GetUserSubjectsUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonResponseDict) {        
        NSMutableArray *subjects = [[NSMutableArray alloc] init];
        NSArray *jsonSubjects = [jsonResponseDict objectForKey:@"Subjects"];                   
        for (NSDictionary *dicSubjects in jsonSubjects) {
            Subjects *subjectValue = [[Subjects alloc] init];
            NSString *lastUpdateTime = [dicSubjects objectForKey:@"LastUpdateTime"];
            NSNumber *lastUpdateTimeNumber = [NSNumber numberWithDouble:[NSDate timeIntervalFromJsonDate:lastUpdateTime] ];
            [dicSubjects setValue:lastUpdateTimeNumber forKey:@"LastUpdateTime"];
            [subjectValue reflectDataFromOtherObject:dicSubjects];
            [subjects addObject:subjectValue];              
        }       
        //添加用户购买的专题
        DAlUserSubject *dalUserSubject = [[DAlUserSubject alloc] init];
        [dalUserSubject addSubjects:subjects atUserID:userInfo.Id];
        
//        dispatch_sync(mainDispatch, ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:GetUserSubjectsUrlFinishedNotification object:nil];
//        });
        
    } failure:^(_HTTPErrorStatus status) {
//        dispatch_sync(dispatch_get_main_queue(), ^{
//        });
    }];
}

+ (void)updateLawSubjects:(_UpdateDataStatus)updateStatus
{
    UserInfo *userInfo = [UserInfo shareInstance];
    NSTimeInterval updateTime = [CommonUtil timeIntervalForUpdateSubject];
    NSString *time = [NSDate jsonTimeFromTimeInterval:updateTime];
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 userInfo.AccessToken, @"AccessToken",
                                 time,@"LastUpdateTime",
                                 nil];
    [self postPath:UpdateSubjectsUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonResponseDict) {
        dispatch_queue_t mainDispatch =  dispatch_get_main_queue();
        INFO(@"updateLawSubjects json:%@",operation.responseString);
        
        NSArray *removedSubjectIds = [jsonResponseDict objectForKey:@"RemovedSubjectIds"];
        NSArray *jsonSubjects = [jsonResponseDict objectForKey:@"Subjects"];
        NSMutableArray *subjects = [[NSMutableArray alloc] initWithCapacity:jsonSubjects.count];
        for (NSDictionary *dicSubjects in jsonSubjects) {
            Subjects *subjectValue = [[Subjects alloc] init];
            NSString *lastUpdateTime = [dicSubjects objectForKey:@"LastUpdateTime"];
            NSNumber *lastUpdateTimeNumber = [NSNumber numberWithDouble:[NSDate timeIntervalFromJsonDate:lastUpdateTime] ];
            [dicSubjects setValue:lastUpdateTimeNumber forKey:@"LastUpdateTime"];
            id price = [dicSubjects objectForKey:@"Price"];
            if([price isKindOfClass:[NSNull class]])
            {
                [dicSubjects setValue:[NSNumber numberWithFloat:0] forKey:@"Price"];
            }
            [subjectValue reflectDataFromOtherObject:dicSubjects];
            [subjects addObject:subjectValue];
            
        }
        
        dispatch_sync(mainDispatch, ^{
            updateProgressValue +=1;
            [[AlertViewUtil shareInstance] showTitle:downloadingString atProcessIndex:updateProgressValue/updateProgressMaxValue];
        });
        DALSubjects *dal = [[DALSubjects alloc] init];
        BOOL sqlRet = NO;
        if (removedSubjectIds.count>0) {
            NSString *subjectIds = [removedSubjectIds componentsJoinedByString:@","];
            sqlRet = [dal deleteSubjectWithIds:subjectIds];
        }
        if (subjects.count>0) {
            sqlRet = [dal insertSubjects:subjects];
            //重新绑定数据
            dispatch_sync(mainDispatch, ^{
                updateProgressValue +=1;
                [[AlertViewUtil shareInstance] showTitle:downloadingString atProcessIndex:updateProgressValue/updateProgressMaxValue];
                [[NSNotificationCenter defaultCenter] postNotificationName:UpdateSubjectsUrlFinishedNotification object:nil];
            });
        }
        if (updateStatus==UpdateSubjectsData||updateProgressMaxValue==updateProgressValue) {
            dispatch_sync(mainDispatch, ^{
                updateProgressValue +=1;
                [[AlertViewUtil shareInstance] cancelProcess];
            });
        }
        dispatch_sync(mainDispatch, ^{
            [self processLastUpdataTime:^(NSTimeInterval executionResult) {  
                [CommonUtil setTimeIntervalForUpdateSubject:executionResult];
            }];
        });
    } failure:^(_HTTPErrorStatus status) {
        
    }];
}

+ (void)updateArticles:(_UpdateDataStatus)updateStatus
{
    static int pageIndex = 0;
    static int pageSize = 1000;
    static int totalPages = 0;
    UserInfo *userInfo = [UserInfo shareInstance];
    NSTimeInterval updateTime = [CommonUtil timeIntervalForUpdateArticles];
    NSString *time = [NSDate jsonTimeFromTimeInterval:updateTime];
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 userInfo.AccessToken, @"AccessToken",
                                 time,@"LastUpdateTime",
                                 [NSString stringWithFormat:@"%d",pageIndex],@"PageIndex",
                                 [NSString stringWithFormat:@"%d",pageSize],@"PageSize",
                                 nil];
    [self postPath:UpdateArticlesUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonResponseDict) {    
        dispatch_queue_t mainDispatch =  dispatch_get_main_queue();
        NSString *TotalPages = [jsonResponseDict objectForKey:@"TotalPages"];
        totalPages = [TotalPages intValue];
        if (totalPages==0) {            
            dispatch_sync(mainDispatch, ^{
                updateProgressValue +=1;
                [[AlertViewUtil shareInstance] showTitle:downloadingString atProcessIndex:1.0];
            });
            sleep(1);
            dispatch_sync(mainDispatch, ^{
                [[AlertViewUtil shareInstance] cancelProcess];
            });
            return ;
        }
        if (pageIndex==0) {            
            updateProgressMaxValue += ((totalPages-1)*3);
        }
        NSArray *removedSubjectIds = [jsonResponseDict objectForKey:@"RemovedArticleIds"];
        NSArray *jsonSubjects = [jsonResponseDict objectForKey:@"Articles"];
        INFO(@"totalPages:%d  ----------- pageIndex:%d",totalPages,pageIndex);
        dispatch_sync(mainDispatch, ^{
            updateProgressValue +=1;
            [[AlertViewUtil shareInstance] showTitle:downloadingString atProcessIndex:updateProgressValue/updateProgressMaxValue];
        });
        
        if (pageIndex == (totalPages-1)) {
            dispatch_sync(mainDispatch, ^{
                [self processLastUpdataTime:^(NSTimeInterval executionResult) { 
                    [CommonUtil setTimeIntervalForUpdateArticles:executionResult];
                }];
                
            });
        }
        else
        {
            if (removedSubjectIds.count>0 && pageIndex==0) {
                DALArticlesOfLaw *dal = [[DALArticlesOfLaw alloc] init];
                BOOL sqlRet = YES;
                NSString *articlesIds = [removedSubjectIds componentsJoinedByString:@","];
                sqlRet = [dal deleteArticlesWithIds:articlesIds];
            }
            dispatch_sync(mainDispatch, ^{
                [self updateArticles:updateStatus];
            });
        }
        
        NSMutableArray *articles = [[NSMutableArray alloc] initWithCapacity:jsonSubjects.count];
        for (NSDictionary *dicSubjects in jsonSubjects) {
            ArticlesOfLaw *article = [[ArticlesOfLaw alloc] init];
            NSString *lastUpdateTime = [dicSubjects objectForKey:@"LastUpdateTime"];
            NSNumber *lastUpdateTimeNumber = [NSNumber numberWithDouble:[NSDate timeIntervalFromJsonDate:lastUpdateTime] ];
            [dicSubjects setValue:lastUpdateTimeNumber forKey:@"LastUpdateTime"];
            [article reflectDataFromOtherObject:dicSubjects];
            [articles addObject:article];
        }        
        dispatch_sync(mainDispatch, ^{
            updateProgressValue +=1;
            [[AlertViewUtil shareInstance] showTitle:downloadingString atProcessIndex:updateProgressValue/updateProgressMaxValue];
        });
        
        DALArticlesOfLaw *dal = [[DALArticlesOfLaw alloc] init];
        BOOL sqlRet = YES;
        if (articles.count>0)
        {       
            sqlRet = [dal insertWithArticles:articles];            
            DALSubjectsOfArticles *dalSubjectsOfArticle = [[DALSubjectsOfArticles alloc] init];
            sqlRet = [dalSubjectsOfArticle addArtilcesToSubjects:articles];
            
            dispatch_sync(mainDispatch, ^{
                updateProgressValue +=1;
                [[AlertViewUtil shareInstance] showTitle:downloadingString atProcessIndex:updateProgressValue/updateProgressMaxValue];
            });
        }
        if (pageIndex == (totalPages-1) || updateProgressMaxValue==updateProgressValue || articles.count==0) {
            dispatch_sync(mainDispatch, ^{
                updateProgressValue +=1;
                [[AlertViewUtil shareInstance] showTitle:downloadingString atProcessIndex:1.0];
                [[NSNotificationCenter defaultCenter] postNotificationName:UpdateArticlesUrlFinishedNotification object:nil];
            });
            sleep(1);
            dispatch_sync(mainDispatch, ^{
                [[AlertViewUtil shareInstance] cancelProcess];
                pageIndex=0;
            });
            return;
        }
        pageIndex++;
        INFO(@"updateArticles end:%d pageIndex:%d totalPages:%d",articles.count,pageIndex,totalPages);
        
    }  failure:^(_HTTPErrorStatus status) {        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[AlertViewUtil shareInstance] cancelProcess];
            pageIndex=0;
        });
    }];
}


+ (void)syncNew
{
    NSTimeInterval nowTime = [CommonUtil timeIntervalForSyncNews];
    NSString *lastUpdateTime = [NSDate jsonTimeFromTimeInterval:nowTime];
    UserInfo *userInfo = [UserInfo shareInstance];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 userInfo.AccessToken, @"AccessToken",
                                 lastUpdateTime,@"LastUpdateTime",
                                 nil];
    
    [self postPath:UpdateNewsUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonResponseDict) {  
        NSArray *newsValue = [jsonResponseDict valueForKey:@"News"];
        for (NSDictionary *dicValue in newsValue) {
            NSString *lastUpdateTime = [dicValue objectForKey:@"LastUpdateTime"];
            NSString *validTime = [dicValue objectForKey:@"ValidTime"];
            
            NSTimeInterval LastUpdateTime = [NSDate timeIntervalFromJsonDate:lastUpdateTime];
            NSTimeInterval ValidTime = [NSDate timeIntervalFromJsonDate:validTime];
            
            [dicValue setValue:[NSNumber numberWithDouble:LastUpdateTime] forKey:@"LastUpdateTime"];
            [dicValue setValue:[NSNumber numberWithDouble:ValidTime] forKey:@"ValidTime"];
            
            News *news = [[News alloc] init];
            [news reflectDataFromOtherObject:dicValue];
            [result addObject:news];
        }
        if(result.count>0)
        {
            DALNews *dal = [[DALNews alloc] init];
            [dal insertNews:result];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UpdateNewsUrlFinishedNotification object:nil];
            });
        }
        //设备更新时间
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self processLastUpdataTime:^(NSTimeInterval executionResult) { 
                [CommonUtil setTimeIntervalForSyncNews:executionResult];
            }];
        });
    } failure:^(_HTTPErrorStatus status) {
        
    }];
}

#pragma mark ----------------- login
+ (void)loginFromViewController:(UIViewController*)fromViewController ToViewController:(UIViewController*)toViewController
{
    UserInfo *userInfo = [UserInfo shareInstance];
    dispatch_block_t httpLoginOperation = ^{
        
        AFHTTPClient *client = [HttpOperation httpClient];
        NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                     userInfo.UserName, @"Username",
                                     userInfo.Password, @"Password",
                                     nil];
        [client postPath:@"Login" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            INFO(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
            INFO(@"response string: %@ ", operation.responseString);
            
            NSDictionary *jsonResponseDict = [operation.responseString JSONValue];
            [[UserInfo shareInstance] reflectDataFromOtherObject:jsonResponseDict];
            if ([userInfo ExecutionResult]) {
                [[NSUserDefaults standardUserDefaults] setObject:userInfo.UserName forKey:USERNAME];
                [fromViewController presentViewController:toViewController animated:YES completion:^{
                    
                }];
            }
            else
            {
                NSString *message = [NSString stringWithFormat:@"登录失败:%@",[UserInfo shareInstance].Message];
                [CommonUtil showMessage:message];
            }
            [CommonUtil endLoading];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [CommonUtil showMessage:@"网络联接失败，请检查网络"];
            [CommonUtil endLoading];
        }];
    };
    
    if (userInfo.isLocalLogin) {
        [self validateToken:^(BOOL executionResult) {
            if (executionResult) {
                dispatch_queue_t mainDispatch =  dispatch_get_main_queue();
                dispatch_sync(mainDispatch, ^{
                    [CommonUtil endLoading];
                    [fromViewController presentViewController:toViewController animated:YES completion:^{
                        
                    }];
                });
            }
            else
            {
                httpLoginOperation();
            }
        }];
        return;
    }
    else
    {
        httpLoginOperation();
    }
}

@end

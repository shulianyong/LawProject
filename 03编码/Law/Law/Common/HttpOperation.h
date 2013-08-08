//
//  HttpOperation.h
//  Law
//
//  Created by shulianyong on 13-3-20.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"
#import "AFNetworking.h"

#define BaseUrl @"http://s-58277.gotocdn.com:8080/Service.svc/"
#define RegisterUrl @"Register"
#define LoginUrl @"Login"

#define GetUserSubjectsUrl @"GetValidRootSubjects"//@"GetUserSubjects"
#define UpdateSubjectsUrl @"UpdateSubjects"
#define UpdateArticlesUrl @"UpdateArticles"
#define ValidateTokenUrl @"ValidateToken"
#define CheckAllUpdatesUrl @"CheckAllUpdates"
#define CurrentServerDateTime @"GetCurrentServerDateTimeEx"

#define UpdateNewsUrl @"UpdateNews"

#define GetUserSubjectsUrlFinishedNotification @"GetUserSubjectsUrlFinishedNotification"
#define UpdateSubjectsUrlFinishedNotification @"UpdateSubjectsUrlFinishedNotification"
#define UpdateArticlesUrlFinishedNotification @"UpdateArticlesUrlFinishedNotification"
#define UpdateNewsUrlFinishedNotification @"UpdateNewsUrlFinishedNotification"


typedef enum HTTPErrorStatus
{
    ExecutionError,
    NetWorkError,
}_HTTPErrorStatus;

typedef enum UpdateDataStatus
{
    UpdateNone,
    UpdateAllData,
    UpdateArticlesData,
    UpdateSubjectsData,
}_UpdateDataStatus;

@interface HttpOperation : NSObject

+ (AFHTTPClient*)httpClient;

+ (void)processLastUpdataTime:(void (^)(NSTimeInterval executionResult))result;
+ (void)validateToken:(void (^)(BOOL executionResult))result;
+ (void)checkAllUpdates:(BOOL)isUserCenter;
+ (void)syncNew;
+ (void)getUserLawSubjects;

#pragma mark ----------------- login
+ (void)loginFromViewController:(UIViewController*)fromViewController ToViewController:(UIViewController*)toViewController;

@end

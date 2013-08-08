//
//  DALUserInfo.m
//  Law
//
//  Created by shulianyong on 13-3-21.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALUserInfo.h"
#import "CDSFCategoriesUtility.h"
#import "NSObject+Reflect.h"
#import "UserInfo.h"
#import "Subjects.h"

@implementation DALUserInfo

- (void)selectUserInfo:(UserInfo*)aUserInfo
{
    NSString *fields = @"Id,UserName,ServiceType,AccessToken,Password";
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM UserInfo WHERE UserName='%@' limit 1",fields,aUserInfo.UserName];
    
    __block FMResultSet *dataSet = nil;
    [self.db executeDataBaseOPeration:^{
        dataSet = [self.db executeQuery:sql];
        if([dataSet next]) {
            NSDictionary *result = [dataSet resultDictionary];
            [aUserInfo reflectDataFromOtherObject:result];
            aUserInfo.ExecutionResult = YES;
        }
        else
        {
            aUserInfo.ExecutionResult = NO;
        }
    }];
}

- (BOOL)localLoginWithUserName:(NSString*)aUserName withPassword:(NSString*)aPassword
{
    __block BOOL ret = YES;
    [self.db executeDataBaseOPeration:^{
        int rows = [self.db intForQuery:@"SELECT COUNT(*) FROM UserInfo WHERE UserName=? AND Password=?",aUserName,aPassword];
        ret = rows>0;
    }];
    return ret;
}

- (BOOL)insertUserInfo:(UserInfo*)aUserInfo forUserID:(NSInteger*)userID
{
    *userID = aUserInfo.Id;
    NSString *fields = @"UserName,Password,AccessToken";
    NSString *values = @":UserName,:Password,:AccessToken";
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO UserInfo (%@) VALUES (%@)",fields,values];  
    NSMutableDictionary *dictionaryArgs = [NSMutableDictionary dictionary];
    [dictionaryArgs setObject:aUserInfo.UserName forKey:@"UserName"];
    [dictionaryArgs setObject:aUserInfo.Password forKey:@"Password"];
    [dictionaryArgs setObject:aUserInfo.AccessToken forKey:@"AccessToken"];
    [self.db executeDataBaseOPeration:^{
        int queryResult = [self.db intForQuery:@"SELECT COUNT(Id) as countNumber FROM UserInfo WHERE UserName=?",aUserInfo.UserName];
        if (queryResult>0) {            
            [self.db executeUpdate:@"UPDATE UserInfo SET UserName=?,Password=?,AccessToken=? WHERE UserName=?"
             ,aUserInfo.UserName
             ,aUserInfo.Password
             ,aUserInfo.AccessToken
             ,aUserInfo.UserName];
        }
        else
        {            
            aUserInfo.ExecutionResult = [self.db executeUpdate:sql withParameterDictionary:dictionaryArgs];
            *userID = [self.db lastInsertRowId];
        }  
        
    }];
    return aUserInfo.ExecutionResult;
}

- (BOOL)deleteUserInfo:(UserInfo*)aUserInfo
{
    __block BOOL ret = YES;
    if (aUserInfo.Id>0) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM UserInfo WHERE Id = ?"];
        [self.db executeDataBaseOPeration:^{
            ret = [self.db executeUpdate:sql,[NSNumber numberWithInteger:aUserInfo.Id]];
        }];        
    }
    return ret;
}

@end

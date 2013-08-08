//
//  UserInfo.m
//  Law
//
//  Created by shulianyong on 13-3-20.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

+ (NSLock*)userInfoLock
{
    static NSLock *userInfoLock = nil;
    if (userInfoLock==nil) {
        userInfoLock = [[NSLock alloc] init];
    }
    return userInfoLock;
}

+ (UserInfo*)shareInstance
{
    [[self userInfoLock] lock];
    
    static UserInfo *shareInstance = nil;
    if (shareInstance == nil) {        
        shareInstance = [[UserInfo alloc] init];
    }
    
    [[self userInfoLock] unlock];
    return shareInstance;
}

@end

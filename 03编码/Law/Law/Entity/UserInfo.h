//
//  UserInfo.h
//  Law
//
//  Created by shulianyong on 13-3-20.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityBase.h"

#define USERNAME @"UserName"
@interface UserInfo : EntityBase

@property (assign,nonatomic) NSInteger Id;
@property (strong,nonatomic) NSString *UserName;
@property (strong,nonatomic) NSString *AccessToken;
@property (strong,nonatomic) NSString *Password;
@property (assign,nonatomic) NSTimeInterval LastUpdateTime;

@property (assign,nonatomic) BOOL ExecutionResult;
@property (strong,nonatomic) NSString *Message;
@property (strong,nonatomic) NSString *ServiceType;

@property (nonatomic) BOOL isLocalLogin;

+ (UserInfo*)shareInstance;

@end

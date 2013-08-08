//
//  DALUserInfo.h
//  Law
//
//  Created by shulianyong on 13-3-21.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALBase.h"
@class UserInfo;

@interface DALUserInfo : DALBase

- (void)selectUserInfo:(UserInfo*)aUserInfo;

- (BOOL)localLoginWithUserName:(NSString*)aUserName withPassword:(NSString*)aPassword;
- (BOOL)insertUserInfo:(UserInfo*)aUserInfo forUserID:(NSInteger*)userID;
- (BOOL)deleteUserInfo:(UserInfo*)aUserInfo;

@end

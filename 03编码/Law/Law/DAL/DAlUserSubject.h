//
//  DAlUserSubject.h
//  Law
//
//  Created by shulianyong on 13-3-25.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALBase.h"

@interface DAlUserSubject : DALBase

- (void)addSubjects:(NSArray*)aSubjects atUserID:(NSInteger)aUserID;

- (NSArray*)userSubject:(NSInteger)aUserId;

@end

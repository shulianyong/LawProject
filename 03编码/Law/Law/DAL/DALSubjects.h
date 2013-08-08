//
//  DALSubjects.h
//  Law
//
//  Created by shulianyong on 13-3-11.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALBase.h"
#import "Subjects.h"

@interface DALSubjects : DALBase

- (NSArray*)queryFromParentId:(NSInteger)aParentId withUserId:(NSInteger)aUserId;
- (NSArray*)quertFromUserId:(NSInteger)aUserId;

//添加删除专题
- (BOOL)insertSubjects:(NSArray*)aSubjects;

- (BOOL)deleteSubjectWithIds:(NSString*)subjectIds;

//搜索
- (NSArray*)searchSubjectsWithName:(NSString*)aName withUserId:(NSInteger)aUserId;

//验证
- (BOOL)isExistSubject;
- (BOOL)isExistChildForParentId:(NSInteger)aSubjectId;
- (BOOL)validateSubjectId:(NSInteger)aSubjectId forUserId:(NSInteger)aUserId;
@end

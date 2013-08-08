//
//  DALSubjectsOfArticles.h
//  Law
//
//  Created by shulianyong on 13-3-24.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALBase.h"
#import "Subjects.h"
#import "ArticlesOfLaw.h"
@interface DALSubjectsOfArticles : DALBase

- (NSArray*)quertArticlesWithSubjectId:(NSInteger)aSubjectId withUserId:(NSInteger)aUserId;

- (BOOL)addArtilcesToSubjects:(NSArray*)aArtilces;

//验证法条是否可用
- (BOOL)validateExistArticlesForSubjectId:(NSInteger)aSubjectId;
@end

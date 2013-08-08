//
//  DALArticlesOfLaw.h
//  Law
//
//  Created by shulianyong on 13-3-24.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALBase.h"
@class ArticlesOfLaw;
@interface DALArticlesOfLaw : DALBase

- (BOOL)insertWithArticles:(NSArray*)aArticleList;

- (BOOL)deleteArticlesWithIds:(NSString*)aArticlesIds;

//Search Articles
- (NSArray*)searchArticlesWithTitle:(NSString*)aTitle withUserId:(NSInteger)aUserId;
- (NSArray*)searchArticlesWithContent:(NSString*)aContent withUserId:(NSInteger)aUserId;
#pragma mark ------------获取相同标题的法条
- (NSArray*)articlesWithTitle:(NSString*)aTitle withUserId:(NSInteger)aUserId;
//检查
- (BOOL)isNewArticles:(NSString*)aTitle;
@end

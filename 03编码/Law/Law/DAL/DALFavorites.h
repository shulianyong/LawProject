//
//  DALFavorites.h
//  Law
//
//  Created by shulianyong on 13-3-25.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALBase.h"

@interface DALFavorites : DALBase

- (BOOL)insertFavoritesWithObject:(NSObject*)obj withUserId:(NSInteger)aUserId withSubjectParentId:(NSInteger)aSubjectParentId;

- (BOOL)deleteWithObject:(NSObject*)obj withUserId:(NSInteger)aUserId;

- (NSArray*)quertFavoriteSubjectWithUserId:(NSInteger)aUserId;
- (NSArray*)quertFavoriteArticlesWithUserId:(NSInteger)aUserId;

//检查
- (NSInteger)fistSubjectId:(NSInteger)aSubjectId;
- (BOOL)isFavoriteToArticleTitle:(NSString*)aTitle ForUserId:(NSInteger)aUserId;
- (BOOL)isFavoriteToSubjectId:(NSInteger)aSubjectId ForUserId:(NSInteger)aUserId;

@end

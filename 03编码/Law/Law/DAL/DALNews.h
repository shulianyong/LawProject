//
//  DALNews.h
//  Law
//
//  Created by shulianyong on 13-3-21.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALBase.h"
@class News;

@interface DALNews : DALBase

- (NSArray*)selectAllNew;

- (void)insertNews:(NSArray*)aNews;

- (void)deleteNews:(News*)aNews;

@end

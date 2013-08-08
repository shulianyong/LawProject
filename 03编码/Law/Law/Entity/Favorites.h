//
//  Favorites.h
//  Law
//
//  Created by shulianyong on 13-3-25.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "EntityBase.h"

@interface Favorites : EntityBase

@property (nonatomic,assign) NSInteger Id;
@property (nonatomic,copy) NSString *Title;
@property (nonatomic,assign) NSInteger FavoriteType;//1为subject 2为 article
@property (nonatomic,assign) NSInteger FavoriteId;
@property (nonatomic,assign) NSInteger UserID;

@end

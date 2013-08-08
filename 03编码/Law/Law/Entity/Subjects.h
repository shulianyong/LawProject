//
//  Subjects.h
//  Law
//
//  Created by shulianyong on 13-3-11.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityBase.h"


@interface Subjects : EntityBase

@property (nonatomic) NSInteger Id;
@property (nonatomic) NSInteger ParentId;
@property (nonatomic,strong) NSString  *Name;
@property (nonatomic,strong) NSString *Description;
@property (nonatomic) NSInteger OrderId;
@property (nonatomic) BOOL IsPrivate;
@property (nonatomic,assign) NSTimeInterval LastUpdateTime;
@property (nonatomic) BOOL Synchronized;
@property (nonatomic) float Price;

@property (nonatomic) BOOL isNew;
@property (nonatomic,assign) float isFavorite;
//用于收藏表中的parentId
@property (nonatomic,assign) NSInteger FirstParentId;
//用于UserSubjects
@property (nonatomic,strong) NSString *SubscriptionStart;
@property (nonatomic,strong) NSString *SubscriptionEnd;

@end

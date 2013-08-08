//
//  News.h
//  Law
//
//  Created by shulianyong on 13-3-21.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "EntityBase.h"

@interface News : EntityBase

@property (nonatomic,assign) NSInteger NewsId         ;
@property (nonatomic,assign) NSInteger Id             ;
@property (nonatomic,strong) NSString *Title          ;
@property (nonatomic,strong) NSString *Contents       ;
@property (nonatomic,strong) NSString *Source         ;
@property (nonatomic,assign) NSTimeInterval ValidTime      ;
@property (nonatomic,assign) NSTimeInterval LastUpdateTime ;
@property (nonatomic,assign) char Synchronized   ;
@property (nonatomic,strong) NSString *DefaultImageUrl ;
@property (nonatomic,strong) NSString *ImageName ;
@end

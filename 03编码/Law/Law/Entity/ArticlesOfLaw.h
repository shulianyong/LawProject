//
//  ArticlesOfLaw.h
//  Law
//
//  Created by shulianyong on 13-3-11.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticlesOfLaw : NSObject

@property(nonatomic) NSInteger Id              ;
@property(nonatomic,strong) NSString *Title           ;
@property(nonatomic,strong) NSString *Contents        ;
@property(nonatomic,strong) NSString *Keywords        ;
@property(nonatomic,assign) NSTimeInterval LastUpdateTime  ;
@property(nonatomic) NSInteger Level           ;
@property(nonatomic) BOOL Synchronized    ;
@property (nonatomic) BOOL isNew;

@property (nonatomic,strong) NSString *Subjects;
@property (nonatomic,assign) NSInteger isFavorite;

@end

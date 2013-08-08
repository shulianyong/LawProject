//
//  BarView.h
//  splitTest
//
//  Created by shulianyong on 13-4-20.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+AKTabBarController.h"

@interface BarView : UIView

@property (nonatomic,strong) UITabBarController *barController;

@property (nonatomic,strong) NSArray *viewControllers;
@property (nonatomic,strong) NSString *imgBackground;
@property (nonatomic,strong) NSString *imgSelectBackground;

@end

//
//  AppDelegate.h
//  Law
//
//  Created by shulianyong on 13-2-27.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//也就是下面mainController的viewcontroller;
@property (strong,nonatomic) UIViewController *contentViewController;

+ (AppDelegate*)shareInstance;

- (UIViewController*)mainController;



@end

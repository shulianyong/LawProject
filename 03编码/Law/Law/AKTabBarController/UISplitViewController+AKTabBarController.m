//
//  UISplitViewController+AKTabBarController.m
//  Law
//
//  Created by shulianyong on 13-4-19.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "UISplitViewController+AKTabBarController.h"

@implementation UISplitViewController (AKTabBarController)

- (NSString *)tabImageName
{
	return [[self.viewControllers objectAtIndex:0] tabImageName];
}

- (NSString *)tabTitle
{
	return [[self.viewControllers objectAtIndex:0] tabTitle];
}

@end

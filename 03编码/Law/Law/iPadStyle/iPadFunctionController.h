//
//  iPadFunctionController.h
//  Law
//
//  Created by shulianyong on 13-4-7.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iPadContentController;

@interface iPadFunctionController : UIViewController

@property (strong, nonatomic) iPadContentController *detailViewController;

- (IBAction)click_btnSwitch:(UIView*)sender;

@end

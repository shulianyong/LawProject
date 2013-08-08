//
//  RegisterController.h
//  Law
//
//  Created by shulianyong on 13-3-23.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *txtUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtVerifyPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
- (IBAction)click_Register:(id)sender;
- (IBAction)click_keyboard:(UITextField*)sender;
- (IBAction)click_Cancel:(id)sender;

@end

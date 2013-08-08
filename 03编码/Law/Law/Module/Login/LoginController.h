//
//  LoginController.h
//  Law
//
//  Created by shulianyong on 13-3-20.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UITextField *txtUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnRemember;


- (IBAction)click_Login:(id)sender;
- (IBAction)click_keyDone:(UITextField*)sender;
- (IBAction)click_Register:(id)sender;
- (IBAction)click_remember:(id)sender;

@end

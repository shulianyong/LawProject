//
//  LoginController.m
//  Law
//
//  Created by shulianyong on 13-3-20.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "LoginController.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "SBJson.h"
#import "UserInfo.h"
#import "CDSFDataBase.h"
#import "CommonUtil.h"
#import "HttpOperation.h"
#import "CDSFCategoriesUtility.h"
#import "RegisterController.h"
#import "DALUserInfo.h"

#import "AlertViewUtil.h"
#import "AppDelegate.h"

#define NOREMEMBERPASSWORD @"NOREMEMBERPASSWORD"
@interface LoginController ()

@end

@implementation LoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.title = loginString;
    BOOL isNoRememberPassword = [[NSUserDefaults standardUserDefaults] boolForKey:NOREMEMBERPASSWORD];
    if (!isNoRememberPassword) {
        [self.btnRemember setImage:[UIImage imageNamed:@"checkbox_set.png"] forState:UIControlStateNormal];
    }
    else    
    {
        [self.btnRemember setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    }
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_background.png"]];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{    
    if ([UserInfo shareInstance].ExecutionResult) {
        BOOL isNoRememberPassword = [[NSUserDefaults standardUserDefaults] boolForKey:NOREMEMBERPASSWORD];
        if (!isNoRememberPassword) {
            self.txtPassword.text = [UserInfo shareInstance].Password;
        }
        self.txtUserName.text = [UserInfo shareInstance].UserName;
    }    
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else
        return ((interfaceOrientation ==UIDeviceOrientationPortrait)||(interfaceOrientation ==UIDeviceOrientationPortraitUpsideDown));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background1.png"]];
        }
        else
        {
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        }
    }
    
    // Redraw with will rotating and keeping the aspect ratio
}

- (void)viewDidUnload {
    [self setBtnLogin:nil];
    [self setTxtUserName:nil];
    [self setTxtPassword:nil];
    [self setBtnRegister:nil];
    [self setBtnRemember:nil];
    [super viewDidUnload];
}

- (BOOL)verifyFeild:(NSString**)aMessage
{
    BOOL ret = YES;
    if ([self.txtUserName.text.trim isEmpty])
    {
        *aMessage = @"用户名不能为空!";
        return NO;
    }
    if ([self.txtPassword.text.trim isEmpty]) {
        *aMessage = @"用户密码不能为空!";
        return NO;
    }    
    return ret;
}


- (IBAction)click_Login:(id)sender {
    UserInfo *userInfo = [UserInfo shareInstance];
    userInfo.UserName = self.txtUserName.text;
    userInfo.Password = self.txtPassword.text;
    NSString *message = nil;
    if ([self verifyFeild:&message]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [CommonUtil showLoadingWithTitle:loginLoading];
            });
            userInfo.isLocalLogin = [self localLogin];
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIViewController *mainController = [[AppDelegate shareInstance] mainController];
                [HttpOperation loginFromViewController:self ToViewController:mainController];
            });           
        });
        
    }
    else
    {
        [CommonUtil showMessage:message];
    }
    
}

- (IBAction)click_keyDone:(UITextField*)sender {
    UITextField *txtNext = (UITextField*)[self.view viewWithTag:sender.tag+1];
    if (txtNext) {
        [txtNext becomeFirstResponder];
    }
    else
    {
        [self click_Login:nil];
    }
}

- (IBAction)click_Register:(id)sender {
    NSString *registerNitName = [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad?@"RegisterController_iPad":@"RegisterController";
    
    RegisterController *controller = [[RegisterController alloc] initWithNibName:registerNitName bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)click_remember:(id)sender
{
    BOOL isNoRememberPassword = ![[NSUserDefaults standardUserDefaults] boolForKey:NOREMEMBERPASSWORD];
    [[NSUserDefaults standardUserDefaults] setBool:isNoRememberPassword forKey:NOREMEMBERPASSWORD];    
    if (!isNoRememberPassword) {
        [self.btnRemember setImage:[UIImage imageNamed:@"checkbox_set.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnRemember setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    }
}

- (BOOL)localLogin
{
    DALUserInfo *dal = [[DALUserInfo alloc] init];
    UserInfo *userInfo = [UserInfo shareInstance];
    userInfo.UserName = [self.txtUserName.text trim];
    if (userInfo.UserName != nil) {
        [dal selectUserInfo:userInfo];
    }
    if ([dal localLoginWithUserName:[self.txtUserName.text trim] withPassword:[self.txtPassword.text trim]]) {
        return YES;
    }
    return NO;
}

#pragma mark ------------touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txtPassword resignFirstResponder];
    [self.txtUserName resignFirstResponder];
}

@end

//
//  RegisterController.m
//  Law
//
//  Created by shulianyong on 13-3-23.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "RegisterController.h"
#import <QuartzCore/QuartzCore.h>
#import "HttpOperation.h"
#import "UserInfo.h"
#import "CDSFCategoriesUtility.h"
#import "CommonUtil.h"

#import "AppDelegate.h"

@interface RegisterController ()

@end

@implementation RegisterController

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
    self.title = @"注册";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_background.png"]];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTxtUserName:nil];
    [self setTxtPassword:nil];
    [self setTxtVerifyPassword:nil];
    [self setBtnRegister:nil];
    [self setBtnCancel:nil];
    [super viewDidUnload];
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

#pragma mark --
#pragma mark -------------http request

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
    if ([self.txtVerifyPassword.text.trim isEmpty]) {
        *aMessage = @"请确定密码!";
        return NO;
    }
    if (![self.txtPassword.text isEqualToString:self.txtVerifyPassword.text]) {
        *aMessage = @"密码不一致!";
        return NO;
    }
        
    return ret;
}

- (void)registeOperation
{
    [CommonUtil showLoadingWithTitle:@"注册中..."];
    AFHTTPClient *httpClient = [HttpOperation httpClient];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 self.txtUserName.text, @"Username",
                                 self.txtVerifyPassword.text, @"Password",
                                 nil];
    [httpClient postPath:RegisterUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonResponseDict = [operation.responseString JSONValue];        
        UserInfo *userInfo = [UserInfo shareInstance];
        [userInfo reflectDataFromOtherObject:jsonResponseDict];
        if (userInfo.ExecutionResult) {            
            [CommonUtil showLoadingWithTitle:loginLoading];
            userInfo.UserName = self.txtUserName.text;
            userInfo.Password = self.txtVerifyPassword.text;
            UIViewController *mainController = [[AppDelegate shareInstance] mainController];
            [HttpOperation loginFromViewController:self ToViewController:mainController];
        }
        else
        {
            [CommonUtil endLoading];
            NSString *message = [NSString stringWithFormat:@"注册失败:%@",userInfo.Message];
            [CommonUtil showMessage:message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil endLoading];
        ERROR(@"http error:%@",error);
    }];
}

- (void)login
{
    UserInfo *userInfo = [UserInfo shareInstance];
    AFHTTPClient *client = [HttpOperation httpClient];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 self.txtUserName.text, @"Username",
                                 self.txtPassword.text, @"Password",
                                 nil];
    [client postPath:@"Login" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        INFO(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
        INFO(@"response string: %@ ", operation.responseString);
        
        NSDictionary *jsonResponseDict = [operation.responseString JSONValue];
        [[UserInfo shareInstance] reflectDataFromOtherObject:jsonResponseDict];
        if ([userInfo ExecutionResult]) {
            userInfo.UserName = [self.txtUserName text];
            userInfo.Password = [self.txtPassword text];
            [[NSUserDefaults standardUserDefaults] setObject:userInfo.UserName forKey:USERNAME];            
            UIViewController *mainController = [[AppDelegate shareInstance] mainController];
            [self presentViewController:mainController animated:YES completion:^{
                
            }];
        }
        else
        {
            NSString *message = [NSString stringWithFormat:@"登录失败:%@",[UserInfo shareInstance].Message];
            [CommonUtil showMessage:message];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ERROR(@"error is:%@",error);
    }];
}

- (IBAction)click_Register:(id)sender {
    NSString *message = nil;
    if ([self verifyFeild:&message]) {
        [self registeOperation];        
    }
    else
    {
        [CommonUtil showMessage:message];
    }
}

- (IBAction)click_keyboard:(UITextField*)sender {    
    UITextField *txtNext = (UITextField*)[self.view viewWithTag:sender.tag+1];
    if (txtNext) {
        [txtNext becomeFirstResponder];
    }
    else
    {
        [self click_Register:nil];
    }
    
}

- (IBAction)click_Cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ----------touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txtUserName resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtVerifyPassword resignFirstResponder];
}

@end

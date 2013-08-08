//
//  AlertViewUtil.m
//  Law
//
//  Created by shulianyong on 13-4-18.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "AlertViewUtil.h"
#import "CommonUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "HttpOperation.h"

@interface AlertViewUtil ()

@property (nonatomic,strong) dispatch_block_t okBlock;

@end

@implementation AlertViewUtil



+ (AlertViewUtil*)shareInstance
{
    static AlertViewUtil *shareInstance = nil;
    if (shareInstance==nil) {
        shareInstance = [[AlertViewUtil alloc] init];
    }
    return shareInstance;
}

- (void)alertMessage:(NSString*)aMessage withOkBlock:(dispatch_block_t)block
{
    [self alertMessage:aMessage withCancelTitle:dismissString withOkBlock:block];
}

- (void)alertMessage:(NSString *)aMessage withCancelTitle:(NSString*)aCancelTitle withOkBlock:(dispatch_block_t)block
{    
    self.okBlock = block;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertString message:aMessage delegate:self cancelButtonTitle:dismissString otherButtonTitles:okString, nil];
    [alertView show];
}

#pragma mark -----------UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.cancelButtonIndex) {
        return;
    }
    else
    {
        self.okBlock();
    }
}

#pragma mark -----------Progress


NSInteger const progressTitleTag = 100;
NSInteger const progressTag = 101;

- (void)click_CancelProgress:(id)sender
{
    [[HttpOperation httpClient].operationQueue cancelAllOperations];
    [self cancelProcess];
}

- (void)showTitle:(NSString*)aMessage atProcessIndex:(CGFloat)index
{
    if (!self.canceled) {        
        UIView *progressView = [self progressView];
        [[UIApplication sharedApplication].delegate.window addSubview:progressView];
        
        UIProgressView *alertView = (UIProgressView*)[progressView viewWithTag:progressTag];
        [alertView setProgress:index];
        UILabel *lblTitle = (UILabel*)[progressView viewWithTag:progressTitleTag];
        lblTitle.text = aMessage;
        [self orientationProcess:nil];
    }
}

- (void)cancelProcess
{
    UIView *progressView = [self progressView];
    [progressView removeFromSuperview];
    self.canceled = YES;
}

- (void)orientationProcess:(NSNotification*)notification
{        
    UIView *progressView = [self progressView];
    UILabel *lblTitle = (UILabel*)[progressView viewWithTag:progressTitleTag];
    progressView = [lblTitle superview];    
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeRight:
            progressView.transform = CGAffineTransformMakeRotation(M_PI /2.0);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            progressView.transform = CGAffineTransformMakeRotation(-M_PI /2.0);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            progressView.transform = CGAffineTransformMakeRotation(M_PI);
            break;
        default:
            progressView.transform = CGAffineTransformMakeRotation(0);
            break;
    }
}

- (UIView*)progressView
{
    static UIView *progressView = nil;
    if (progressView==nil) {        
        
        UILabel *lblTitle = nil;
        UIProgressView *alertView  = nil;
        UIButton *btnCancel = nil;
        
        CGFloat width = 300;
        CGFloat height = 140;
        CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
        progressView = [[UIView alloc] initWithFrame:mainScreenFrame];
        progressView.backgroundColor = [UIColor clearColor];
        
        UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        viewContent.center = CGPointMake(CGRectGetMidX(mainScreenFrame), CGRectGetMidY(mainScreenFrame));
        viewContent.backgroundColor = RGBColor(251, 250, 251);
        viewContent.layer.cornerRadius = 8;
        
        UIView *viewMask = [[UIView alloc] initWithFrame:mainScreenFrame];
        viewMask.backgroundColor = [UIColor blackColor];
        viewMask.alpha = 0.7;
        
        
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, width, 21)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:17];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.textColor = RGBColor(103, 102, 104);
        
        alertView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        alertView.progressTintColor = RGBColor(99, 154, 115);
        alertView.trackTintColor = RGBColor(220, 219, 220);
        alertView.bounds = CGRectMake(0, 0, width-20, 9);
        alertView.center = CGPointMake(CGRectGetMidX(viewContent.bounds), CGRectGetMidY(viewContent.bounds));
        
        CGFloat btnCancelWidth = 100;
        CGFloat btnCancelHeight = 35;
        btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnCancel setBackgroundImage:[UIImage imageNamed:@"imgBtnProgressCancel.png"] forState:UIControlStateNormal];
        btnCancel.frame = CGRectMake((viewContent.bounds.size.width-btnCancelWidth)/2, CGRectGetMaxY(viewContent.bounds)-10-btnCancelHeight, btnCancelWidth, btnCancelHeight);
        [btnCancel addTarget:self action:@selector(click_CancelProgress:) forControlEvents:UIControlEventTouchUpInside];
        [btnCancel setTitle:dismissString forState:UIControlStateNormal];
        [btnCancel setTitleColor:RGBColor(93, 91, 93) forState:UIControlStateNormal];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationProcess:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        [progressView addSubview:viewMask];
        [progressView addSubview:viewContent];
        [viewContent addSubview:lblTitle];
        [viewContent addSubview:alertView];
        [viewContent addSubview:btnCancel];
        lblTitle.tag = progressTitleTag;
        alertView.tag = progressTag;
        
    }
    return progressView;
}

@end

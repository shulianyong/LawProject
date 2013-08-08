//
//  CommonUtil.m
//  Law
//
//  Created by shulianyong on 13-3-20.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "CommonUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "DALSubjects.h"
#import "DALSubjectsOfArticles.h"
#import "AlertViewUtil.h"
#import "UserInfo.h"

NSString *const alertString = @"提示";
NSString *const okString = @"确定";
NSString *const dismissString = @"取消";
NSString *const pleaseBuyTheSubjectString = @"你还没有购买该专题";
NSString *const loginString = @"登录";
NSString *const loginLoading = @"登录中...";
NSString *const updateDataString = @"有数据更新，是否进行数据更新？";
NSString *const logoutString = @"登出";
NSString *const haveNoDataString = @"没有数据";
NSString *const companyAddressString = @"http://www.llgarden.com";
NSString *const messageString = @"1、付费专题！请您到（网站）支付后查阅！（网站给个链接）\n"
"2、付费后，您可在所有客户端查阅专题数据。";
NSString *const downloadingString = @"数据更新下载中...";
NSString *const loadingString = @"加载中...";


//title
NSString *const lawDataString = @"法律数据";
NSString *const lawNewsString = @"法律新闻";
NSString *const favoriteString = @"收藏夹";
NSString *const personalCenterString = @"个人中心";
//network check
NSString *const checkUpdateString = @"检查更新";
NSString *const checkUpdateLoadingString = @"检查更新中...";
NSString *const networkDisconnectedString = @"网络联接失败";
NSString *const HaveNoUpdateDataString = @"没有更新数据";

@implementation CommonUtil

+ (void)showMessage:(NSString*)aMessage
{
    UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:alertString message:aMessage delegate:nil cancelButtonTitle:dismissString otherButtonTitles:nil];
    [messageAlert show];
}

//方法
CGFloat calulateHeightForString(NSString*lrcString,UIFont*font,CGFloat rowWidth)
{
    if (lrcString==nil)
    {
        return 0;
    }
    CGSize maxSize=CGSizeMake(rowWidth, 99999);
    CGSize  strSize=[lrcString sizeWithFont:font constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    
    return strSize.height;
    
}

#pragma mark -----------loading view

#define LoadingTitleTag 100
#define LoadingAlertViewTag  101
+ (UIView*)loadingView
{    
    static UIView *loadingView = nil;    
    if (loadingView==nil) {        
        UILabel *lblTitle = nil;
        UIActivityIndicatorView *alertView  = nil;
        CGFloat width = 100;
        CGFloat height = 100;        
        CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];       
        
        loadingView = [[UIView alloc] initWithFrame:mainScreenFrame];          
        loadingView.backgroundColor = [UIColor clearColor];
        
        UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        viewContent.center = CGPointMake(CGRectGetMidX(mainScreenFrame), CGRectGetMidY(mainScreenFrame));
        viewContent.backgroundColor = [UIColor blackColor];
        viewContent.layer.cornerRadius = 8;
        
        UIView *viewMask = [[UIView alloc] initWithFrame:mainScreenFrame];
        viewMask.backgroundColor = [UIColor blackColor];
        viewMask.alpha = 0.7;       
        
        
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 80, 30)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.font = [UIFont systemFontOfSize:15];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.textColor = [UIColor whiteColor];
        
        alertView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        alertView.frame = CGRectMake((width-30)/2, 55 , 30, 30);
        
        [loadingView addSubview:viewMask];
        [loadingView addSubview:viewContent];
        [viewContent addSubview:lblTitle];
        [viewContent addSubview:alertView];
        lblTitle.tag = LoadingTitleTag;
        alertView.tag = LoadingAlertViewTag;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationProcess:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return loadingView;
}

+ (void)showLoadingWithTitle:(NSString*)aTitle
{
    UIView *loadingView = [self loadingView];    
    UILabel *lblTitle = (UILabel*)[loadingView viewWithTag:LoadingTitleTag];
    UIActivityIndicatorView *alertView  = (UIActivityIndicatorView*)[loadingView viewWithTag:LoadingAlertViewTag];    
    lblTitle.text = aTitle;
    [alertView startAnimating];
    
    [[AppDelegate shareInstance].window addSubview:loadingView];    
    [AppDelegate shareInstance].window.userInteractionEnabled = NO;
    [self orientationProcess:nil];
}

+ (void)endLoading
{    
    UIView *loadingView = [self loadingView];
    [loadingView removeFromSuperview];
    [AppDelegate shareInstance].window.userInteractionEnabled = YES;
}

+ (void)orientationProcess:(NSNotification*)notification
{
    UIView *progressView = [self loadingView];
    UILabel *lblTitle = (UILabel*)[progressView viewWithTag:LoadingTitleTag];
    progressView = [lblTitle superview];
   
//    INFO(@"orientation:%d",[UIApplication sharedApplication].statusBarOrientation);
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

#pragma mark ----- LastUpdateTime

NSString *const UpdateSubjectLastUpdateDateTime = @"UpdateSubjectLastUpdateDateTime";
NSString *const UpdateArticlesUpdateDateTime = @"UpdateArticlesUpdateDateTime";
NSString *const SyncNewsLastUpdateDateTime = @"SyncNewsLastUpdateDateTime";

+ (NSTimeInterval)timeIntervalForUpdateSubject
{
    DALSubjects *dalSubject = [[DALSubjects alloc] init];
    if ([[NSUserDefaults standardUserDefaults] doubleForKey:UpdateSubjectLastUpdateDateTime]>1) {
        return [[NSUserDefaults standardUserDefaults] doubleForKey:UpdateSubjectLastUpdateDateTime];
    }
    else if(![dalSubject isExistSubject]) {
        [[NSUserDefaults standardUserDefaults] setDouble:NSTimeIntervalSince1970 forKey:UpdateSubjectLastUpdateDateTime];
    }
    else if([[NSUserDefaults standardUserDefaults] doubleForKey:UpdateSubjectLastUpdateDateTime]<1)
    {
        [[NSUserDefaults standardUserDefaults] setDouble:LASTUPDATETIMEINTERVAL forKey:UpdateSubjectLastUpdateDateTime];
    }
    return [[NSUserDefaults standardUserDefaults] doubleForKey:UpdateSubjectLastUpdateDateTime];
}
+ (void)setTimeIntervalForUpdateSubject:(NSTimeInterval)timeInterval
{
    [[NSUserDefaults standardUserDefaults] setDouble:timeInterval forKey:UpdateSubjectLastUpdateDateTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark ----Update Articles Time
+ (NSTimeInterval)timeIntervalForUpdateArticles
{
    DALSubjects *dalSubject = [[DALSubjects alloc] init];
    if ([[NSUserDefaults standardUserDefaults] doubleForKey:UpdateArticlesUpdateDateTime]>1) {        
        return [[NSUserDefaults standardUserDefaults] doubleForKey:UpdateArticlesUpdateDateTime];
    }
    else if (![dalSubject isExistSubject]) {
        [[NSUserDefaults standardUserDefaults] setDouble:NSTimeIntervalSince1970 forKey:UpdateArticlesUpdateDateTime];
    }
    else if([[NSUserDefaults standardUserDefaults] doubleForKey:UpdateArticlesUpdateDateTime]<1)
    {
        [[NSUserDefaults standardUserDefaults] setDouble:LASTUPDATETIMEINTERVAL forKey:UpdateArticlesUpdateDateTime];
    }
    return [[NSUserDefaults standardUserDefaults] doubleForKey:UpdateArticlesUpdateDateTime];
}
+ (void)setTimeIntervalForUpdateArticles:(NSTimeInterval)timeInterval
{
    [[NSUserDefaults standardUserDefaults] setDouble:timeInterval forKey:UpdateArticlesUpdateDateTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark ----update New Time
+ (NSTimeInterval)timeIntervalForSyncNews
{
    DALSubjects *dalSubject = [[DALSubjects alloc] init];
    if ([[NSUserDefaults standardUserDefaults] doubleForKey:SyncNewsLastUpdateDateTime]>1) {        
        return [[NSUserDefaults standardUserDefaults] doubleForKey:SyncNewsLastUpdateDateTime];
    }
    else if (![dalSubject isExistSubject]) {
        [[NSUserDefaults standardUserDefaults] setDouble:NSTimeIntervalSince1970 forKey:SyncNewsLastUpdateDateTime];
    }
    else if([[NSUserDefaults standardUserDefaults] doubleForKey:SyncNewsLastUpdateDateTime]<1)
    {
        [[NSUserDefaults standardUserDefaults] setDouble:LASTUPDATETIMEINTERVAL forKey:SyncNewsLastUpdateDateTime];
    }
    return [[NSUserDefaults standardUserDefaults] doubleForKey:SyncNewsLastUpdateDateTime];
}

+ (void)setTimeIntervalForSyncNews:(NSTimeInterval)timeInterval
{
    [[NSUserDefaults standardUserDefaults] setDouble:timeInterval forKey:SyncNewsLastUpdateDateTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//地址
NSString *const importantStatusDefault = @"importantStatusDefault";
NSString *const importantAddressDefault = @"importantAddressDefault";
NSString *const importantMessageDefault = @"importantMessageDefault";

+ (void)setImportantStatus:(BOOL)aStatus
{
    [[NSUserDefaults standardUserDefaults] setBool:aStatus forKey:importantStatusDefault];
}
+ (BOOL)importantStatus
{
#ifdef DISTRIBUTION
    return [[NSUserDefaults standardUserDefaults] boolForKey:importantStatusDefault];
#endif
    return YES;
}

+ (void)setImportantAddress:(NSString*)aAddress
{
    [[NSUserDefaults standardUserDefaults] setObject:aAddress forKey:importantAddressDefault];
}
+ (NSString*)importantAddress
{    
#ifdef DISTRIBUTION
    return [[NSUserDefaults standardUserDefaults] objectForKey:importantAddressDefault];
#endif    
    return companyAddressString;
}
+ (void)setImportantMessage:(NSString*)aMessage
{    
    [[NSUserDefaults standardUserDefaults] setObject:aMessage forKey:importantMessageDefault];
}
+ (NSString*)importantMessage
{
#ifdef DISTRIBUTION
    return [[NSUserDefaults standardUserDefaults] objectForKey:importantMessageDefault];
#endif    
    return messageString;
}

//返回值，允许通过
+ (BOOL)showImportantMessageBySubjectId:(NSInteger)aSubjectId
{
    DALSubjects *dalSubject = [[DALSubjects alloc] init];
    //专题是付了费的
    if ([dalSubject validateSubjectId:aSubjectId forUserId:[UserInfo shareInstance].Id])
    {
        return YES;
    }
    if (![CommonUtil importantStatus]) {
        return YES;
    }
    
    static AlertViewUtil *alertViewUtil = nil;
    if (alertViewUtil==nil) {
        alertViewUtil = [[AlertViewUtil alloc] init];
    }
    if ([CommonUtil importantStatus]) {
        [alertViewUtil alertMessage:[CommonUtil importantMessage] withOkBlock:^{
            NSURL *url = [NSURL URLWithString:[CommonUtil importantAddress]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [[UIApplication sharedApplication] performSelector:NSSelectorFromString(@"openURL:") withObject:url];
#pragma clang diagnostic pop
            
        }];
    }
    return ![CommonUtil importantStatus];
}

@end

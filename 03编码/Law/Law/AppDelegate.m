
//
//  AppDelegate.m
//  Law
//
//  Created by shulianyong on 13-2-27.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "AppDelegate.h"
#import "AKTabBarController.h"
#import "DALSubjects.h"
#import "UserInfo.h"
#import "DALUserInfo.h"
#import "iPadContentController.h"
#import "iPadFunctionController.h"

#import "LoginController.h"

#import "LawContentController.h"
#import "LawDataController.h"
#import "LawNewsController.h"
#import "FavoriteController.h"
#import "UserController.h"
#import "FavoriteDetailController.h"

#import "BarView.h"

@implementation AppDelegate

+ (AppDelegate*)shareInstance
{
    AppDelegate *shareInstance = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return shareInstance;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    //default style
    [self defaultNavigationBar];
    [self initData];
//    [self defaultSegmentedControl];
    UINavigationController *mainScreen = nil;    
    [[UITableView appearance] setBackgroundColor:RGBColor(249, 249, 249)];    
    UIView *viewSelected = [[UIView alloc] init];
    [viewSelected setBackgroundColor:RGBColor(138, 179, 154)];
    [[UITableViewCell appearance] setSelectedBackgroundView:viewSelected];
    
    
    LoginController *loginController = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        loginController = [[LoginController alloc] initWithNibName:@"LoginController_IPad" bundle:nil];
    }
    else
    {        
        loginController = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
    }
    mainScreen = [[UINavigationController alloc] initWithRootViewController:loginController];
    [mainScreen setNavigationBarHidden:YES];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_window setRootViewController:mainScreen];
    [_window makeKeyAndVisible];
    // Override point for customization after application launch.
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark ----------------default Device Bar

- (UIViewController*)mainController
{
    UIViewController *mainController = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        mainController = [self iPadMainScreen];
        mainController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    else
    {
        mainController = [self iPhoneMainScreen];
        mainController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    self.contentViewController = mainController;
    return mainController;
}

- (AKTabBarController*)deviceBar
{
    
    AKTabBarController *_tabBarController = [[AKTabBarController alloc] initWithTabBarHeight:49];
    [_tabBarController setMinimumHeightToDisplayTitle:40.0];
    
    // Tab background Image
    [_tabBarController setBackgroundImageName:@"imgTabBarBackGround.png"];
    [_tabBarController setSelectedBackgroundImageName:@"imgTabBarGroundSelected.png"];
    
    // Tabs top embos Color
    [_tabBarController setTabEdgeColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8]];
    
    // Tabs Colors settings
    [_tabBarController setTabColors:@[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.0],
     [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0]]]; // MAX 2 Colors
    
    [_tabBarController setSelectedTabColors:@[[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0],
     [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0]]]; // MAX 2 Colors
    
    // Tab Stroke Color
    [_tabBarController setTabStrokeColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    
    // Icons Color settings
    [_tabBarController setIconColors:@[[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1],
     [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1]]]; // MAX 2 Colors
    [_tabBarController setIconColors:@[[UIColor whiteColor],
     [UIColor whiteColor]]];
    
    // Icon Shadow
    [_tabBarController setIconShadowColor:[UIColor blackColor]];
    [_tabBarController setIconShadowOffset:CGSizeMake(0, 0)];
    
    [_tabBarController setSelectedIconColors:@[[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1],
     [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1]]]; // MAX 2 Colors
    [_tabBarController setSelectedIconColors:@[[UIColor whiteColor],
     [UIColor whiteColor]]];
    [_tabBarController setSelectedIconOuterGlowColor:[UIColor clearColor]];
    
    // Text Color
    [_tabBarController setTextColor:[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]];
    [_tabBarController setTextColor:[UIColor whiteColor]];
    [_tabBarController setSelectedTextColor:[UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0]];
    [_tabBarController setSelectedTextColor:[UIColor whiteColor]];
    
    // Hide / Show glossy on tab icons
    [_tabBarController setIconGlossyIsHidden:YES];
    return _tabBarController;
}

//iPhone style
- (UIViewController*)iPhoneMainScreen
{    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mainControllers" ofType:@"plist"];
    NSArray *source = [NSArray arrayWithContentsOfFile:filePath];
    
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:source.count];
    for (NSString *value in source) {
        Class controller = NSClassFromString(value);
        UIViewController *root = [[controller alloc] initWithNibName:value bundle:nil];
        UINavigationController *controllerNavigation = [[UINavigationController alloc] initWithRootViewController:root];
        [controllers addObject:controllerNavigation];
    }
//    AKTabBarController *_tabBarController = [self deviceBar];
//    [_tabBarController setViewControllers:controllers];
    
    UITabBarController *barController = [[UITabBarController alloc] init];
    barController.viewControllers = controllers;
    BarView *barView = [[BarView alloc] initWithFrame:barController.tabBar.bounds];
    barView.imgBackground = @"menu_bar_background.png";
    barView.imgSelectBackground = @"menubar_selt_01.png";
    barView.viewControllers = controllers;
    barView.barController = barController;
    barView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_bar_background.png"]];
    [barController.tabBar addSubview:barView];
    //    barController.tabBar.hidden = YES;
    [barView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    return barController;

}

//iPad style
- (UIViewController*)iPadMainScreen
{
    //law data
    UISplitViewController *lawDataController = [[UISplitViewController alloc] init];
    LawDataController *masterViewController = [[LawDataController alloc] initWithNibName:@"LawDataController_IPad" bundle:nil];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    
    LawContentController *detailViewController = [[LawContentController alloc] initWithStyle:UITableViewStylePlain];
    detailViewController.isDisplayArticel = YES;
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    masterViewController.detailViewController = detailViewController;  
    lawDataController.viewControllers = @[masterNavigationController, detailNavigationController];
    lawDataController.delegate = detailViewController;
    
    //law new
    LawNewsController *newController = [[LawNewsController alloc] initWithNibName:@"LawNewsController_IPad" bundle:nil];
    UINavigationController *navigationNewController = [[UINavigationController alloc] initWithRootViewController:newController];
    
    //Favorite
    FavoriteController *favoriteController = [[FavoriteController alloc] initWithNibName:@"FavoriteController" bundle:nil];
    UINavigationController *navigationFavoriteController = [[UINavigationController alloc] initWithRootViewController:favoriteController];
    LawContentController *favoriteDetailController = [[LawContentController alloc] initWithStyle:UITableViewStylePlain];
    favoriteDetailController.isDisplayArticel = YES;
    UINavigationController *navigationFavoriteDetailController = [[UINavigationController alloc] initWithRootViewController:favoriteDetailController];
    favoriteController.detailViewController = favoriteDetailController;
    
    UISplitViewController *spliteFavorite = [[UISplitViewController alloc] init];
    spliteFavorite.viewControllers = @[navigationFavoriteController,navigationFavoriteDetailController];
    spliteFavorite.delegate = favoriteDetailController;
    
    
    
    //User
    UserController *userController = [[UserController alloc] initWithNibName:@"UserController" bundle:nil];
    UINavigationController *navigationUserController = [[UINavigationController alloc] initWithRootViewController:userController];
    
    NSArray *controllers = @[lawDataController,navigationNewController,spliteFavorite];
    NSArray *barViewController = @[lawDataController,navigationNewController,spliteFavorite,navigationUserController];
    
    
    UITabBarController *barController = [[UITabBarController alloc] init];
    barController.viewControllers = controllers;
    BarView *barView = [[BarView alloc] initWithFrame:barController.tabBar.bounds];
    barView.imgBackground = @"menu_bar_background.png";
    barView.imgSelectBackground = @"menubar_selt_01.png";
    barView.viewControllers = barViewController;
    barView.barController = barController;
    barView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"imgTabBarBackGround.png"]];
    [barController.tabBar addSubview:barView];
//    barController.tabBar.hidden = YES;
    [barView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    return barController;
    
}

#pragma mark ----data init

- (void)initData
{
    DALUserInfo *dal = [[DALUserInfo alloc] init];
    [dal initDataBase];
    UserInfo *user = [UserInfo shareInstance];
    user.UserName = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
    if (user.UserName != nil) {
        [dal selectUserInfo:user];
    }
}

#pragma mark ----default style
- (void)defaultNavigationBar
{
    
    UINavigationBar *nbarMain = [UINavigationBar appearance];
    [nbarMain setBackgroundImage:[UIImage imageNamed:@"top_background.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIColor *textColor = RGBColor(83, 83, 83);
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[textColor
                          ,[UIColor whiteColor]
                          ,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)]]
                                                     forKeys:@[UITextAttributeTextColor
                          ,UITextAttributeTextShadowColor
                          ,UITextAttributeTextShadowOffset]];
    nbarMain.titleTextAttributes = dict;
}

- (void)defaultSegmentedControl
{
    UISegmentedControl *segScope = [UISegmentedControl appearance];
    [segScope setTintColor:RGBColor(224,224,224)];
    UIColor *textColor = RGBColor(100,100,100);
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[textColor
                          ,[UIColor whiteColor]
                          ,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)]]
                                                     forKeys:@[UITextAttributeTextColor
                          ,UITextAttributeTextShadowColor
                          ,UITextAttributeTextShadowOffset]];
    [segScope setTitleTextAttributes:dict forState:UIControlStateNormal];
}

@end

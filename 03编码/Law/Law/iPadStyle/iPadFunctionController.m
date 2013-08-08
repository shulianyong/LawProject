//
//  iPadFunctionController.m
//  Law
//
//  Created by shulianyong on 13-4-7.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "iPadFunctionController.h"
#import "iPadContentController.h"

#import "LawDataController.h"
#import "LawNewsController.h"
#import "FavoriteController.h"
#import "UserController.h"


@interface iPadFunctionController ()

@property (nonatomic,readonly) UIViewController *_LawDataController;
@property (nonatomic,readonly) UINavigationController *_LawNewsController;
@property (nonatomic,readonly) UINavigationController *_FavoriteController;
@property (nonatomic,readonly) UINavigationController *_UserController;

@end

@implementation iPadFunctionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIViewController*)_LawDataController
{
    static UIViewController *_LawDataController = nil;
    if (_LawDataController==nil) {
        _LawDataController = [[LawDataController alloc] initWithNibName:@"LawDataController_IPad" bundle:nil];
        
    }
    return _LawDataController;
}

- (UINavigationController*)_LawNewsController
{
    static UINavigationController *_LawNewsController = nil;
    if (_LawNewsController==nil) {
        UIViewController *root = [[LawNewsController alloc] initWithNibName:@"LawNewsController_IPad" bundle:nil];
        _LawNewsController = [[UINavigationController alloc] initWithRootViewController:root];
    }
    return _LawNewsController;
}

- (UINavigationController*)_FavoriteController
{
    static UINavigationController *_FavoriteController = nil;
    if (_FavoriteController==nil) {
        UIViewController *root = [[FavoriteController alloc] initWithNibName:@"FavoriteController_IPad" bundle:nil];
        _FavoriteController = [[UINavigationController alloc] initWithRootViewController:root];
    }
    return _FavoriteController;
}

- (UINavigationController*)_UserController
{
    static UINavigationController *_UserController = nil;
    if (_UserController==nil) {
        UIViewController *root = [[UserController alloc] initWithNibName:@"UserController_IPad" bundle:nil];
        _UserController = [[UINavigationController alloc] initWithRootViewController:root];
    }
    return _UserController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;//((interfaceOrientation ==UIDeviceOrientationLandscapeLeft)||(interfaceOrientation ==UIDeviceOrientationLandscapeRight));
}

- (IBAction)click_btnSwitch:(UIView*)sender {
    switch (sender.tag) {
        case 1:
            self.detailViewController.contentController = self._LawDataController;
            break;
        case 2:
            self.detailViewController.contentController = self._LawNewsController;
            break;
        case 3:
            self.detailViewController.contentController = self._FavoriteController;
            break;
        case 4:
            self.detailViewController.contentController = self._UserController;
            break;        
            
        default:
            break;
    }
    
}
@end

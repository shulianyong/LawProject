//
//  FavoriteDetailController.m
//  Law
//
//  Created by shulianyong on 13-4-22.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "FavoriteDetailController.h"
#import "CommonUtil.h"

@interface FavoriteDetailController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation FavoriteDetailController

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
    self.view.backgroundColor = [UIColor redColor];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-20, 44)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = RGBColor(83, 83, 83);
    self.navigationItem.titleView = lblTitle;
    lblTitle.font = [UIFont boldSystemFontOfSize:19];
    lblTitle.minimumFontSize = 10;
    lblTitle.adjustsFontSizeToFitWidth = YES;
    lblTitle.text = self.contentTitle;
    lblTitle.backgroundColor = [UIColor clearColor];
    [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
	// Do any additional setup after loading the view.
}

- (void)setContentTitle:(NSString *)contentTitle
{
    _contentTitle = contentTitle;
    [(UILabel*)self.navigationItem.titleView setText:contentTitle];
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

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = favoriteString;
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


@end

//
//  LawNewsDetailController.m
//  Law
//
//  Created by shulianyong on 13-3-22.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "LawNewsDetailController.h"
#import "News.h"
#import "CDSFCategoriesUtility.h"
#import "AFNetworking.h"

@interface LawNewsDetailController ()

@end

@implementation LawNewsDetailController

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
    
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo.png"]];
    self.navigationItem.titleView = imgTitle;
    
    self.lblTitle.text =  [NSString stringWithFormat:@"%@ \n \n",self.currentNews.Title];
    self.txtvFix.text = [NSString stringWithFormat:@"        %@",[self.currentNews.Contents stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n        "]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.currentNews.LastUpdateTime];    
    self.lblTime.text = [date descriptionLocalAsFormat:@"YYYY年MM月dd日 HH:mm"];
    self.lblTime.text = [self.lblTime.text stringByAppendingFormat:@" %@",self.currentNews.Source];   
    
    CGRect txtvFrame = self.txtvFix.frame;
    if ([self.currentNews.DefaultImageUrl isEmpty]) {
        txtvFrame.origin.y = self.imgNews.frame.origin.y;
        [self.imgNews removeFromSuperview];
    }
    else
    {
        [self.imgNews setImageWithURL:[NSURL URLWithString:self.currentNews.DefaultImageUrl]];
    }
    
    txtvFrame.size.height = self.txtvFix.contentSize.height;
    self.txtvFix.frame = txtvFrame;
    
    CGFloat contentSizeHeight = CGRectGetMaxY(txtvFrame)>self.view.bounds.size.height?CGRectGetMaxY(txtvFrame):self.view.bounds.size.height+20;
    [self.scrvContent setContentSize:CGSizeMake(self.scrvContent.frame.size.width, contentSizeHeight)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,17,17);
    [button setBackgroundImage:[UIImage imageNamed:@"icon_esc.png"] forState:UIControlStateNormal];
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];  
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    // Do any additional setup after loading the view from its nib.
}

- (void)loadView
{
    [super loadView];    
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

- (void)viewDidUnload {
    [self setLblTitle:nil];
    [self setLblTime:nil];
    [self setImgNews:nil];
    [self setScrvContent:nil];
    [self setTxtvFix:nil];
    [super viewDidUnload];
}

@end

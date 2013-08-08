//
//  LawNewsController.m
//  Law
//
//  Created by shulianyong on 13-3-5.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "LawNewsController.h"
#import <QuartzCore/QuartzCore.h>
#import "NewsCell.h"
#import "HttpOperation.h"
#import "News.h"
#import "UserInfo.h"
#import "CDSFCategoriesUtility.h"
#import "DALNews.h"
#import "NSDate+SynsWindowsTime.h"
#import "LawNewsDetailController.h"

@interface LawNewsController ()

@property (nonatomic,strong) NSArray *allNews;
@property (nonatomic,strong) UIButton *btnEdit;

@end

@implementation LawNewsController

- (NSString *)tabImageName
{
	return @"menubar_icon_new.png";
}

- (NSString *)tabTitle
{
	return [lawNewsString copy];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundData:) name:UpdateNewsUrlFinishedNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *imgTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo.png"]];
    self.navigationItem.titleView = imgTitle;
    [self bundData:nil];   
 
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
- (void)loadView
{
    [super loadView];
//    self.btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.btnEdit.frame = CGRectMake(0,0,25,25);
//    [self.btnEdit setImage:[UIImage imageNamed:@"img_tblEdit.png"] forState:UIControlStateNormal];
//    [self.btnEdit addTarget:self action:@selector(click_btnEdit:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnEdit];
//    [self.navigationItem setRightBarButtonItem:barButtonItem];
}

- (void)click_btnEdit:(id)sender
{
    [self setEditing:!(self.editing) animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    NSString *imgEdit = editing?@"img_tblEditing.png":@"img_tblEdit.png";
    [self.btnEdit setImage:[UIImage imageNamed:imgEdit] forState:UIControlStateNormal];    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allNews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";   
    
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[NewsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];        
    }
    News *aNews = [self.allNews objectAtIndex:indexPath.row];
    cell.newsInfo = aNews;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [(NewsCell*)cell relayout:[tableView rectForRowAtIndexPath:indexPath].size.height];
}


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        DALNews *dal = [[DALNews alloc] init];
//        [dal deleteNews:[self.allNews objectAtIndex:indexPath.row]];
//        [(NSMutableArray*)self.allNews removeObjectAtIndex:indexPath.row];
//        
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSString *detailNib = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ?@"LawNewsDetailController_iPad":@"LawNewsDetailController";    
    LawNewsDetailController *detailViewController = [[LawNewsDetailController alloc] initWithNibName:detailNib bundle:nil];
    
    News *currentNews = [self.allNews objectAtIndex:indexPath.row];
    detailViewController.currentNews = currentNews;
    // ...
    // Pass the selected object to the new view controller.］
    [detailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ?100:88;
}

#pragma mark -----bund data
- (void)bundData:(NSNotification*)notification
{
    DALNews *dal = [[DALNews alloc] init];
    self.allNews = [dal selectAllNew];
    [self.tableView reloadData];
}
@end

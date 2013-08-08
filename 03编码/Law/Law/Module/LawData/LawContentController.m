//
//  LawContentController.m
//  Law
//
//  Created by shulianyong on 13-3-11.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "LawContentController.h"
#import "LawDataController.h"

#import "DALSubjects.h"
#import "DALSubjectsOfArticles.h"
#import "DALFavorites.h"

#import "ArticlesOfLaw.h"
#import "LawDetailController.h"
#import "UserInfo.h"
#import "Subjects.h"

#import "SubjectDelegateAndSource.h"
#import "ArticlesDelegateAndSource.h"
#import "AlertViewUtil.h"

const NSInteger NoDataViewTag = 1000;
const NSInteger DetailViewTag = 1001;

@interface LawContentController ()
{
    UIView *noDataBackView;
    AlertViewUtil *alertViewUtil;
}

@property (nonatomic,strong) NSArray *subjectList;
@property (nonatomic,strong) NSArray *articlesList;

@property (nonatomic,strong) SubjectDelegateAndSource *subjectDelegateAndSource;
@property (nonatomic,strong) ArticlesDelegateAndSource *articlesDelegateAndSource;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation LawContentController

@synthesize isDisplayArticel;
@synthesize subjectParentId;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configTitle:(NSString*)aTitle
{    
    //title
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-20, 44)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = RGBColor(83, 83, 83);
    lblTitle.font = [UIFont boldSystemFontOfSize:15];
    lblTitle.minimumFontSize = 10;
    lblTitle.adjustsFontSizeToFitWidth = YES;
    lblTitle.text = aTitle;
    lblTitle.backgroundColor = [UIColor clearColor];
    [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
    [lblTitle setNumberOfLines:3];
    self.navigationItem.titleView = lblTitle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    [self reloadViewData];
    self.subjectDelegateAndSource = [[SubjectDelegateAndSource alloc] initWithTableView:self.tableView withDelegate:self];
    self.articlesDelegateAndSource = [[ArticlesDelegateAndSource alloc] initWithTableView:self.tableView withDelegate:self]; 
    
    [self configTitle:self.subject.Name];
    
    self.txtvFix = [[UITextView alloc] initWithFrame:CGRectMake(32, 0, self.view.bounds.size.width-42, 100)];
    [self.txtvFix setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
    self.txtvFix.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.txtvFix];
    self.txtvFix.hidden = YES;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && ![self isDisplayArticel]) {
        self.tableView.backgroundColor = RGBColor(243, 249, 249);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.tableView numberOfRowsInSection:0]>0&&[self isDisplayArticel]) {
        [self.tableView reloadData];
        return;
    }
    [self reloadViewData];
}

- (void)loadView
{
    [super loadView];
    //初始化当前专题数据
    DALSubjects *dalSubject = [[DALSubjects alloc] init];
    self.subjectList = [dalSubject queryFromParentId:self.subject.Id withUserId:[UserInfo shareInstance].Id];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self defaultiPhoneView];
    }
    else
    {
        if (!self.isDisplayArticel) {
            //default back button style
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0,0,17,17);
            [button setBackgroundImage:[UIImage imageNamed:@"icon_esc.png"] forState:UIControlStateNormal];
            [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            [self.navigationItem setLeftBarButtonItem:barButtonItem];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setTxtvFix:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;//[self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.tableView reloadData];
}

#pragma mark --------- iPhone Load
- (void)defaultiPhoneView
{    
    //default back button style
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,17,17);
    [button setBackgroundImage:[UIImage imageNamed:@"icon_esc.png"] forState:UIControlStateNormal];
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    //default segment button style
    if (self.subjectList.count<1) {
        self.isDisplayArticel = YES;
    }
    
    UIButton *btnSeg = (UIButton*)[self.tableView viewWithTag:1];
    btnSeg.enabled = !(self.isDisplayArticel);
    btnSeg = (UIButton*)[self.tableView viewWithTag:2];
    btnSeg.enabled = self.isDisplayArticel;
}


- (IBAction)click_segChange:(UIControl*)sender {
    if (![self isDisplayArticel]) {
        if (![CommonUtil showImportantMessageBySubjectId:self.subjectParentId]) {
            return;
        }
    }
    
    for (int i=1; i<3; i++) {
        UIButton *btnSeg = (UIButton*)[self.tableView viewWithTag:i];
        btnSeg.enabled = !btnSeg.enabled;
    }
    
    UIButton *btnSeg = (UIButton*)[self.tableView viewWithTag:1];
    self.isDisplayArticel = !(btnSeg.isEnabled);
    [self reloadViewData];
}

#pragma mark --
#pragma mark ----------- reload Data

//没有数据的时候，显示一个图片
- (void)displayNoDataRightContentController
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {      
        [noDataBackView removeFromSuperview];
        if (noDataBackView==nil) {
            noDataBackView = [[UIView alloc] initWithFrame:self.view.bounds];
            UIImageView *imgNoData = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"panel-right-bckground.png"]];
            [noDataBackView addSubview:imgNoData];
            imgNoData.center = CGPointMake(CGRectGetMidX(noDataBackView.bounds), CGRectGetMidY(noDataBackView.bounds));
            [imgNoData setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
            
            UILabel *lblNoData = [[UILabel alloc] init];
            lblNoData.text = haveNoDataString;
            lblNoData.font = [UIFont boldSystemFontOfSize:25];
            lblNoData.backgroundColor = [UIColor clearColor];
            lblNoData.autoresizingMask = imgNoData.autoresizingMask;
            lblNoData.textColor = RGBColor(113, 166, 126);
            lblNoData.textAlignment = NSTextAlignmentCenter;
            lblNoData.bounds = CGRectMake(0, 0, self.view.bounds.size.width, 40);
            lblNoData.center = CGPointMake(imgNoData.center.x, CGRectGetMidY(self.view.bounds)+150);
            [noDataBackView addSubview:lblNoData];
            
        }
        noDataBackView.frame = self.view.bounds;
        [noDataBackView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight];
        noDataBackView.backgroundColor = RGBColor(249, 249, 249);        
        [self.view.superview addSubview:noDataBackView];
    }
}


- (void)reloadViewData
{
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        [noDataBackView removeFromSuperview];
        if ([self isDisplayArticelContent]) {
            return;
        }
        else if(self.subject == nil && [self isDisplayArticel])
        {            
            [self displayNoDataRightContentController];
            [self configTitle:nil];
            return;
        }
    }
    
    
    if ([self isDisplayArticel]) {       
        DALSubjectsOfArticles *dalArticles = [[DALSubjectsOfArticles alloc] init];        
        self.articlesList = [dalArticles quertArticlesWithSubjectId:self.subject.Id withUserId:[UserInfo shareInstance].Id];
               
        self.tableView.delegate = self.articlesDelegateAndSource;
        self.tableView.dataSource = self.articlesDelegateAndSource;
        self.articlesDelegateAndSource.currentTableData = self.articlesList;
    }
    else
    {
        DALSubjects *dalSubject = [[DALSubjects alloc] init];
        self.subjectList = [dalSubject queryFromParentId:self.subject.Id withUserId:[UserInfo shareInstance].Id];
        self.tableView.delegate = self.subjectDelegateAndSource;
        self.tableView.dataSource = self.subjectDelegateAndSource;
        self.subjectDelegateAndSource.currentTableData = self.subjectList;
    }    
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {        
        [self configTitle:self.subject.Name];
        if (([self isDisplayArticel]&&self.articlesList.count<1)) {
            [self displayNoDataRightContentController];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark ----------click table row
//只针对专题
- (BOOL)tableDelegateAndSource:(TableDelegateAndSource*)tableDelegateAndSource didSelectRowForObject:(id)aValue
{    
    LawContentController *detailViewController = nil;    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        detailViewController = [[LawContentController alloc] initWithNibName:@"LawContentController" bundle:nil];
    }
    else
        detailViewController = [[LawContentController alloc] initWithStyle:UITableViewStylePlain];
    
    detailViewController.subjectParentId = self.subjectParentId;
    detailViewController.subject = aValue;
    detailViewController.isDisplayArticel = self.isDisplayArticel;
    
    //跳转到下一个专题
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        DALSubjects *dal = [[DALSubjects alloc] init];
        if ([dal isExistChildForParentId:((Subjects*)aValue).Id]) {
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
        //更新右边数据
        LawDataController *rightController = self.navigationController.viewControllers[0];
        DALSubjectsOfArticles *dalSubjectArticles = [[DALSubjectsOfArticles alloc] init];
        if ([dalSubjectArticles validateExistArticlesForSubjectId:((Subjects*)aValue).Id]) {
            if (![CommonUtil showImportantMessageBySubjectId:self.subjectParentId]) {
                return NO;
            }
        }
        else
        {
            rightController.detailViewController.subject = nil;
        }    
        rightController.detailViewController.subject = aValue;
        [rightController.detailViewController reloadViewData];
        [rightController.detailViewController.navigationController popToRootViewControllerAnimated:NO];
    }
    else
    {
        DALSubjects *dal = [[DALSubjects alloc] init];
        if ([dal isExistChildForParentId:((Subjects*)aValue).Id]) {            
            detailViewController.isDisplayArticel = NO;
            [self.navigationController pushViewController:detailViewController animated:YES];            
        }
        else
        {
            detailViewController.isDisplayArticel = YES;
            detailViewController.tableView.tableHeaderView = nil;
            if ([CommonUtil showImportantMessageBySubjectId:self.subjectParentId]) {
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
        }
    }    
    
    return YES;
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}
@end

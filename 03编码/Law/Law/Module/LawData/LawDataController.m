//
//  LawDataController.m
//  Law
//
//  Created by shulianyong on 13-3-5.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "LawDataController.h"
#import "Subjects.h"
#import "DALSubjects.h"
#import <QuartzCore/QuartzCore.h>
#import "AFURLConnectionOperation.h"
#import "LoginController.h"
#import "AFHTTPClient.h"
#import "HttpOperation.h"
#import "UserInfo.h"
#import "DALUserInfo.h"
#import "CommonUtil.h"
#import "NSDate+SynsWindowsTime.h"
#import "LawContentController.h"
#import "DAlUserSubject.h"
#import "DALSubjectsOfArticles.h"
#import "DALArticlesOfLaw.h"
#import "ArticlesOfLaw.h"
#import "LawDetailController.h"
#import "DALFavorites.h"

#import "LawDataArticlesDelegateAndSource.h"
#import "SubjectDelegateAndSource.h"
#import "AKTabBarController.h"
#import "AlertViewUtil.h"

@interface LawDataController ()<TableDelegateAndSourceDelegate>
{
    dispatch_queue_t httpOperationQueue;
    AlertViewUtil *alertViewUtil;
}

@property (nonatomic,strong) NSArray* searchSubjects;
@property (nonatomic,strong) NSArray *searchTitles;
@property (nonatomic,strong) NSArray *searchContents;

@property (nonatomic,assign) NSInteger* searchPathIndex;

@property (nonatomic,strong) LawDataArticlesDelegateAndSource *searchArticlesDelegateAndSource;
@property (nonatomic,strong) SubjectDelegateAndSource *searchSubjectDelegateAndSource;
@property (nonatomic,strong) SubjectDelegateAndSource *subjectDelegateAndSource;

@end

@implementation LawDataController

@synthesize lawSubjects;
@synthesize titleValue;
@synthesize subjectParentId;

- (NSString *)tabImageName
{
	return @"menubar_icon_news.png";
}

- (NSString *)tabTitle
{
	return lawDataString;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {       
    }
    return self;
}

- (void)loadView
{
    [super loadView];    
    httpOperationQueue = dispatch_queue_create("httpOperationQueue", NULL);
    //获取新数据成功后的数据绑定
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadViewData:) name:GetUserSubjectsUrlFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadViewData:) name:UpdateSubjectsUrlFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadViewData:) name:UpdateArticlesUrlFinishedNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //table source and delegate
    self.searchArticlesDelegateAndSource = [[LawDataArticlesDelegateAndSource alloc] initWithTableView:self.searchDisplayController.searchResultsTableView withDelegate:self];
    self.searchSubjectDelegateAndSource = [[SubjectDelegateAndSource alloc] initWithTableView:self.searchDisplayController.searchResultsTableView withDelegate:self];
    self.subjectDelegateAndSource = [[SubjectDelegateAndSource alloc] initWithTableView:self.tableView withDelegate:self];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo.png"]];
    self.navigationItem.titleView = imgTitle;   
    
    UISearchBar *searchBar = self.searchDisplayController.searchBar;
    UIColor *textColor = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        for (UIView *subview in searchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                UIView *view = [[UIView alloc] initWithFrame:subview.bounds];
                [view setBackgroundColor:RGBColor(243, 249, 249)];
                [subview addSubview:view];               
                break;
            }
            if ([subview isKindOfClass:[UISegmentedControl class]]) {
                UISegmentedControl *segScope = (UISegmentedControl*)subview;
                [segScope setTintColor:RGBColor(227,238,234)];
            }
        }
        [searchBar setScopeBarBackgroundImage:[UIImage imageNamed:@"left-background.png"]];
        textColor = RGBColor(67, 100, 100);
    }
    else
    {        
        for (UIView *subview in searchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                UIView *view = [[UIView alloc] initWithFrame:subview.bounds];
                [view setBackgroundColor:RGBColor(249, 249, 249)];
                [subview addSubview:view];
                
                
                break;
            }
            if ([subview isKindOfClass:[UISegmentedControl class]]) {
                UISegmentedControl *segScope = (UISegmentedControl*)subview;
                [segScope setTintColor:RGBColor(224,224,224)];
            }
        }
        [searchBar setScopeBarBackgroundImage:[UIImage imageNamed:@"img_SearchBack.png"]];
        textColor = RGBColor(100, 100, 100);
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[textColor
                          ,[UIColor whiteColor]
                          ,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)]]
                                                     forKeys:@[UITextAttributeTextColor
                          ,UITextAttributeTextShadowColor
                          ,UITextAttributeTextShadowOffset]];
    [searchBar setScopeBarButtonTitleTextAttributes:dict forState:UIControlStateNormal];
    
    //登录后的初始化工作
    [self loginSuccess];
    
    self.txtvFix = [[UITextView alloc] initWithFrame:CGRectMake(32, 0, self.view.bounds.size.width-112, 100)];
    [self.txtvFix setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
    [self.view addSubview:self.txtvFix];
    self.txtvFix.font = [UIFont boldSystemFontOfSize:18];
    self.txtvFix.hidden = YES;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.tableView.backgroundColor = RGBColor(243, 249, 249);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self isDidSearch]&&self.searchDisplayController.searchBar.selectedScopeButtonIndex>0) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else
    {
        [self reloadViewData:nil];
    }
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.tableView reloadData];
}

#pragma mark --
#pragma mark ----------------reload data

- (BOOL)isDidSearch
{
    return self.searchDisplayController.isActive;
}

- (NSArray*)currentTableData
{    
    NSArray *currentTableData = nil;    
    if ([self isDidSearch]) {
        NSInteger selectedScope = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
        switch (selectedScope) {
            case 0:
                currentTableData = self.searchSubjects;
                break;
            case 1:                
                currentTableData = self.searchTitles;
                break;
            case 2:
                currentTableData = self.searchContents;
            default:
                break;
        }
    }
    else
    {
        currentTableData = self.lawSubjects;
    }
    return currentTableData;
}


- (void)reloadViewData:(NSNotification*)notification
{    
    DALSubjects *dal = [[DALSubjects alloc] init];
    INFO(@"reloadViewData begin");
    if ([self isDidSearch]) {
        NSInteger selectedScope = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
        NSString *searchText = self.searchDisplayController.searchBar.text;
        
        
        DALArticlesOfLaw *dalArticles = [[DALArticlesOfLaw alloc] init];
        switch (selectedScope) {
            case 0:                
                self.searchSubjects = [dal searchSubjectsWithName:searchText
                                                       withUserId:[UserInfo shareInstance].Id];                
                self.searchDisplayController.searchResultsDataSource = self.searchSubjectDelegateAndSource;
                self.searchDisplayController.searchResultsDelegate = self.searchSubjectDelegateAndSource;
                self.searchSubjectDelegateAndSource.currentTableData = [self currentTableData];
                break;
            case 1:
                self.searchTitles = [dalArticles searchArticlesWithTitle:searchText
                                                              withUserId:[UserInfo shareInstance].Id];
                self.searchDisplayController.searchResultsDataSource = self.searchArticlesDelegateAndSource;
                self.searchDisplayController.searchResultsDelegate = self.searchArticlesDelegateAndSource;
                self.searchArticlesDelegateAndSource.currentTableData = [self currentTableData];
                break;
            case 2:
                self.searchContents = [dalArticles searchArticlesWithContent:searchText
                                                                  withUserId:[UserInfo shareInstance].Id];
                self.searchDisplayController.searchResultsDataSource = self.searchArticlesDelegateAndSource;
                self.searchDisplayController.searchResultsDelegate = self.searchArticlesDelegateAndSource;
                self.searchArticlesDelegateAndSource.currentTableData = [self currentTableData];
                break;                
            default:
                break;
        }        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else
    {
        self.lawSubjects = [dal quertFromUserId:[UserInfo shareInstance].Id];
        self.tableView.delegate = self.subjectDelegateAndSource;
        self.tableView.dataSource = self.subjectDelegateAndSource;
        self.subjectDelegateAndSource.currentTableData = [self currentTableData];
        [self.tableView reloadData];
    }    
    INFO(@"reloadViewData end");
}

#pragma mark ---------did selected cell

- (BOOL)tableDelegateAndSource:(TableDelegateAndSource*)tableDelegateAndSource didSelectRowForObject:(id)aValue
{
    Subjects *currentSubject = (Subjects*)aValue;
    NSInteger firstSubjectId = currentSubject.Id;
    if ([self isDidSearch]) {
        DALFavorites *dalFav = [[DALFavorites alloc] init];
        firstSubjectId = [dalFav fistSubjectId:currentSubject.Id];
    }
//    DALSubjects 
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        //跳转专题
        DALSubjects *dal = [[DALSubjects alloc] init];
        if ([dal isExistChildForParentId:currentSubject.Id]) {            
            LawContentController *lawAritclesController = [[LawContentController alloc] initWithStyle:UITableViewStylePlain];            
            lawAritclesController.subjectParentId = firstSubjectId;
            lawAritclesController.subject = currentSubject;
            lawAritclesController.isDisplayArticel = NO;            
            [self.navigationController pushViewController:lawAritclesController animated:YES];
        }
        
        //绑定右边法条
        DALSubjectsOfArticles *dalSubjectArticles = [[DALSubjectsOfArticles alloc] init];
        if ([dalSubjectArticles validateExistArticlesForSubjectId:currentSubject.Id]) {
            if (![CommonUtil showImportantMessageBySubjectId:currentSubject.Id]) {
                return NO;
            }
        }
        else
        {
            self.detailViewController.subject = nil;
        }
        self.detailViewController.subject = aValue;
        self.detailViewController.isDisplayArticelContent = NO;
        [self.detailViewController reloadViewData];
        [self.detailViewController.navigationController popToRootViewControllerAnimated:NO];
        
    }
    else
    {
        //跳转专题
        LawContentController *lawAritclesController = [[LawContentController alloc] initWithNibName:@"LawContentController" bundle:nil];
        lawAritclesController.subjectParentId = firstSubjectId;
        lawAritclesController.subject = currentSubject;
        
        DALSubjects *dal = [[DALSubjects alloc] init];
        if ([dal isExistChildForParentId:currentSubject.Id]) {
            lawAritclesController.isDisplayArticel = NO;
            [self.navigationController pushViewController:lawAritclesController animated:YES];
        }
        else
        {
            lawAritclesController.isDisplayArticel = YES;
            lawAritclesController.tableView.tableHeaderView = nil;
            if ([CommonUtil showImportantMessageBySubjectId:currentSubject.Id]) {
                [self.navigationController pushViewController:lawAritclesController animated:YES];
            }
        }
    }   
      
    return YES;
}

#pragma mark --
#pragma mark -------------------Login Operation

- (void)loginSuccess
{
    [HttpOperation checkAllUpdates:NO];
    [HttpOperation syncNew];
    [self httpLoginsuccess];
}

- (void)httpLoginsuccess
{      
        UserInfo *user = [UserInfo shareInstance];
        DALUserInfo *dal = [[DALUserInfo alloc] init];
        NSInteger userID = 0;
        user.ExecutionResult = [dal insertUserInfo:user forUserID:&userID];
        user.Id = userID;        
        //获取用户购买的专题
        [HttpOperation getUserLawSubjects];
}

#pragma mark --
#pragma mark ------------search bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.subjectDelegateAndSource.tableView = self.searchDisplayController.searchResultsTableView;
    searchBar.showsCancelButton = YES;
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:dismissString  forState:UIControlStateNormal];
            UIColor *textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
            [btn setBackgroundImage:[UIImage imageNamed:@"img_btnSearch.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"img_btnSearchselected.png"] forState:UIControlStateHighlighted];
            [btn setTitleShadowColor:textColor forState:UIControlStateNormal];
            [btn setTitleColor:textColor forState:UIControlStateNormal];
            [[btn titleLabel] setShadowOffset:CGSizeMake(0, 0)];
        }
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (searchBar.selectedScopeButtonIndex>0) {
            self.detailViewController.navigationController.delegate = self.searchArticlesDelegateAndSource;
        }
        else
        {
            self.detailViewController.navigationController.delegate = nil;
        }
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{    
    self.subjectDelegateAndSource.tableView = self.tableView;
    [[self.detailViewController.view.superview viewWithTag:DetailViewTag] removeFromSuperview];
    self.detailViewController.navigationController.delegate = nil;
}

#pragma mark -------------UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    dispatch_async(httpOperationQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
        [CommonUtil showLoadingWithTitle:loadingString];
        });
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self reloadViewData:nil];
        });
        dispatch_sync(dispatch_get_main_queue(), ^{
            [CommonUtil endLoading];
        });
    });
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {        
        self.detailViewController.isDisplayArticelContent = NO;
        self.detailViewController.subject = nil;
        [self.detailViewController reloadViewData];
    } 
    return;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {        
        if (selectedScope>0) {
            self.detailViewController.navigationController.delegate = self.searchArticlesDelegateAndSource;
        }
        else
        {
            self.detailViewController.navigationController.delegate = nil;
        }
    }
    
    [[self.detailViewController.view.superview viewWithTag:DetailViewTag] removeFromSuperview];
    NSString *searchString = [searchBar text];
    if ([searchString isEmpty]) {
        return;
    }
    [self searchBarCancelButtonClicked:nil];
    [self searchBarSearchButtonClicked:searchBar];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return NO;
}

@end




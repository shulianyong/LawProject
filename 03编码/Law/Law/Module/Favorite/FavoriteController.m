//
//  FavoriteController.m
//  Law
//
//  Created by shulianyong on 13-3-5.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "FavoriteController.h"
#import "DALFavorites.h"
#import "DALSubjects.h"
#import "DALSubjectsOfArticles.h"

#import "UserInfo.h"
#import "LawCell.h"
#import "Subjects.h"
#import "ArticlesOfLaw.h"
#import "LawContentController.h"
#import "LawDetailController.h"

#import "FavoriteDetailController.h"
@interface FavoriteController ()<UINavigationControllerDelegate>
{
    BOOL isFirstLoad;
    UIView *articlesContentView;    
}

@property (nonatomic,strong) NSArray *favoriteSubjects;
@property (nonatomic,strong) NSArray *favoriteArticles;
@property (nonatomic,strong) UIButton *btnEdit;

//@property (nonatomic,strong) UITableView *currentTableView;

@end

@implementation FavoriteController

- (NSString *)tabImageName
{
	return @"menubar_icon_love.png";
}

- (NSString *)tabTitle
{
	return favoriteString;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstLoad = YES;
//    self.currentTableView = self.detailViewController.tableView;
    self.navigationItem.title = favoriteString;   
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.tableView.backgroundColor = RGBColor(243, 249, 249);
        self.btnArticle.superview.superview.backgroundColor = RGBColor(243, 249, 249);
    }
    
}

- (void)loadView
{    
    [super loadView];
    self.btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnEdit.frame = CGRectMake(0,0,25,25);
    [self.btnEdit setImage:[UIImage imageNamed:@"img_tblEdit.png"] forState:UIControlStateNormal];
    [self.btnEdit addTarget:self action:@selector(click_btnEdit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnEdit];
    [self.navigationItem setRightBarButtonItem:barButtonItem];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//    if (!isFirstLoad) {
        [self reloadViewData];
//    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else
        return ((interfaceOrientation ==UIDeviceOrientationPortrait)||(interfaceOrientation ==UIDeviceOrientationPortraitUpsideDown));
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self currentTableData].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ArticlesCell = @"ArticlesCell";    
    static NSString *SubjectCell = @"SubjectCell";
    NSString *CellIdentifier = [self isDisplayArticles]?ArticlesCell:SubjectCell;
    
    LawCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LawCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.isFavorite = YES;
        cell.btnFavorite.hidden = YES;
        cell.accessoryView = nil;
        cell.textLabel.numberOfLines = 3;
        if ([self isDisplayArticles]) {
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        }
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            cell.textLabel.textColor = RGBColor(69, 104, 104);
        }
    }
    
    if ([self isDisplayArticles]) {
        ArticlesOfLaw *value = [[self currentTableData] objectAtIndex:indexPath.row];
        cell.textLabel.text = value.Title;
        cell.detailTextLabel.text = nil;
    }
    else
    {
        Subjects *value = [[self currentTableData] objectAtIndex:indexPath.row];        
        cell.textLabel.text = value.Name;
        cell.detailTextLabel.text = value.Description;
    }
    
    if (isFirstLoad&&indexPath.row == 0 &&[self isDisplayArticles] && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        isFirstLoad = NO;
    }
    // Configure the cell...
    
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSMutableArray *currentTable = (NSMutableArray*)[self currentTableData];
        DALFavorites *dal = [[DALFavorites alloc] init];
        [dal deleteWithObject:[currentTable objectAtIndex:indexPath.row] withUserId:[UserInfo shareInstance].Id];
        [currentTable removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


#pragma mark - Table view delegate


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{    
    LawContentController *contentController = self.detailViewController;
    [contentController.view.superview addSubview:articlesContentView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UIView *conentView = [self.detailViewController.view.superview viewWithTag:DetailViewTag];
    [conentView removeFromSuperview];
    
    if ([self isDisplayArticles]) {
        LawDetailController *detailViewController = [[LawDetailController alloc] initWithNibName:@"LawDetailController" bundle:nil];
        ArticlesOfLaw *lawArticle = [[self currentTableData] objectAtIndex:indexPath.row];
        [self.detailViewController configTitle:lawArticle.Title];
        detailViewController.lawArticle = lawArticle;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.detailViewController.navigationController.delegate = self;
            self.detailViewController.isDisplayArticelContent = YES;
            
            UIView *contentView = detailViewController.view;
            contentView.tag = DetailViewTag;
            contentView.frame = self.detailViewController.view.bounds;
            [contentView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight];
            articlesContentView = contentView;
            if ([self.detailViewController.navigationController.visibleViewController isKindOfClass:[LawContentController class]]) {
                [self.detailViewController.view.superview addSubview:contentView];
            }
            else
            {
                [self.detailViewController.navigationController popToRootViewControllerAnimated:NO];                
            }
            
        }
        else
        {
            detailViewController.hidesBottomBarWhenPushed = YES;
            detailViewController.isFavoriteFunction = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
        
    }
    else
    {
        self.detailViewController.navigationController.delegate = nil;
        DALFavorites *dalFavorite = [[DALFavorites alloc] init];
        Subjects *currentSubject =  [[self currentTableData] objectAtIndex:indexPath.row];
        currentSubject.FirstParentId = [dalFavorite fistSubjectId:currentSubject.Id];
        //    DALSubjects
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            //跳转专题
            self.detailViewController.isDisplayArticelContent = NO;
            DALSubjects *dal = [[DALSubjects alloc] init];
            if ([dal isExistChildForParentId:currentSubject.Id]) {
                LawContentController *lawAritclesController = [[LawContentController alloc] initWithStyle:UITableViewStylePlain];
                lawAritclesController.subjectParentId = currentSubject.FirstParentId;
                lawAritclesController.subject = currentSubject;
                lawAritclesController.isDisplayArticel = NO;
                [self.navigationController pushViewController:lawAritclesController animated:YES];
            }            
            //绑定右边法条
            DALSubjectsOfArticles *dalSubjectArticles = [[DALSubjectsOfArticles alloc] init];
            self.detailViewController.subject = currentSubject;
            if ([dalSubjectArticles validateExistArticlesForSubjectId:currentSubject.Id])
            {
                
                if (![CommonUtil showImportantMessageBySubjectId:currentSubject.FirstParentId])
                    self.detailViewController.subject = nil;
            }
            [self.detailViewController reloadViewData];
            [self.detailViewController.navigationController popToRootViewControllerAnimated:NO];
        }
        else
        {
            //跳转专题
            LawContentController *lawAritclesController = [[LawContentController alloc] initWithNibName:@"LawContentController" bundle:nil];
            lawAritclesController.subjectParentId = currentSubject.FirstParentId;
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
                if ([CommonUtil showImportantMessageBySubjectId:currentSubject.FirstParentId]) {
                    [self.navigationController pushViewController:lawAritclesController animated:YES];
                }
            }
        }     
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isDisplayArticles]) {
        return 54;
    }
    return 44;
}

#pragma mark --change view
- (IBAction)click_segChange:(UIControl*)sender {
    if (self.editing) {
        return;
    }
    for (int i=1; i<3; i++) {
        UIButton *btnSeg = (UIButton*)[self.tableView viewWithTag:i];
        btnSeg.enabled = !btnSeg.enabled;
    }
    self.detailViewController.isDisplayArticelContent = [self isDisplayArticles];
    [self reloadViewData];
}

#pragma mark --reload tableview data
- (BOOL)isDisplayArticles
{
    return !(self.btnArticle.enabled);
}

- (NSArray*)currentTableData
{
    NSArray *currentTableData = nil;
    if ([self isDisplayArticles]) {
        currentTableData = self.favoriteArticles;
    }
    else
    {
        currentTableData = self.favoriteSubjects;
    }
    return currentTableData;
}
- (void)reloadViewData
{    
    DALFavorites *dal = [[DALFavorites alloc] init];
    if ([self isDisplayArticles]) {
        self.favoriteArticles = [dal quertFavoriteArticlesWithUserId:[UserInfo shareInstance].Id];
    }
    else
    {
        self.favoriteSubjects = [dal quertFavoriteSubjectWithUserId:[UserInfo shareInstance].Id];
    }
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [self setBtnArticle:nil];
    [super viewDidUnload];
}

@end

//
//  LawDataArticlesDelegateAndSource.m
//  Law
//
//  Created by shulianyong on 13-4-18.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "LawDataArticlesDelegateAndSource.h"
#import "LawCell.h"
#import "LawDetailController.h"
#import "LawDataController.h"
#import "LawContentController.h"

#import "DALFavorites.h"
#import "DALArticlesOfLaw.h"

#import "ArticlesOfLaw.h"
#import "UserInfo.h"

@interface LawDataArticlesDelegateAndSource ()<LawCellDelegate>
{
    UIView *articlesContentView;
}

@end

@implementation LawDataArticlesDelegateAndSource

#pragma mark ------event
- (void)LawCell:(LawCell*)cell withFavorite:(UIButton*)sender withEvent:(id)event
{
    cell.isFavorite = !cell.isFavorite;
    
    UITableView *tblCurrent = self.tableView;
    NSIndexPath *indexPath = [tblCurrent indexPathForCell:cell];
    DALFavorites *dal = [[DALFavorites alloc] init];
    if (cell.isFavorite) {
        [dal insertFavoritesWithObject:[[self currentTableData] objectAtIndex:indexPath.row]
                            withUserId:[UserInfo shareInstance].Id
                   withSubjectParentId:self.delegate.subjectParentId];
    }
    else
    {
        [dal deleteWithObject:[[self currentTableData] objectAtIndex:indexPath.row]
                   withUserId:[UserInfo shareInstance].Id];
    }
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

- (void)boundTableDataWithArticles:(ArticlesOfLaw*)aValue forCell:(LawCell*)cell
{
    cell.textLabel.text = aValue.Title;
    cell.detailTextLabel.text = aValue.Contents;
    cell.detailTextLabel.numberOfLines = 2;
    cell.textLabel.numberOfLines = 0;    
    DALFavorites *dalFavorite = [[DALFavorites alloc] init];
    cell.isFavorite = [dalFavorite isFavoriteToArticleTitle:aValue.Title ForUserId:[UserInfo shareInstance].Id];
    DALArticlesOfLaw *dalArticles = [[DALArticlesOfLaw alloc] init];
    cell.isNew = [dalArticles isNewArticles:aValue.Title];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchArticlesCell";
    LawCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LawCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            cell.textLabel.textColor = RGBColor(69, 104, 104);
        }
    }
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self boundTableDataWithArticles:[[self currentTableData] objectAtIndex:indexPath.row] forCell:(LawCell*)cell];
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArticlesOfLaw *value = [[self currentTableData] objectAtIndex:indexPath.row];    
    self.delegate.txtvFix.text = value.Title;
    CGFloat heightContent = self.delegate.txtvFix.contentSize.height;
    return heightContent>44?heightContent:44;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    LawContentController *contentController = ((LawDataController*)self.delegate).detailViewController;
    [contentController.view.superview addSubview:articlesContentView];
}

- (void)pushViewControllerForArticlesOfLaw:(ArticlesOfLaw*)aValue
{    
    LawDetailController *detailViewController = [[LawDetailController alloc] initWithNibName:@"LawDetailController" bundle:nil];
    detailViewController.lawArticle = aValue;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if ([self.delegate isKindOfClass:[LawDataController class]]) {
            //法规显示
            LawContentController *contentController = ((LawDataController*)self.delegate).detailViewController;
            contentController.isDisplayArticelContent = YES;
            [[contentController.view.superview viewWithTag:DetailViewTag] removeFromSuperview];
            
            UIView *contentView = detailViewController.view;
            contentView.tag = DetailViewTag;
            contentView.frame = ((LawDataController*)self.delegate).detailViewController.view.bounds;
            [contentView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight];
            
            articlesContentView = contentView;
            if ([contentController.navigationController.visibleViewController isKindOfClass:[LawContentController class]]) {
                [contentController.view.superview addSubview:detailViewController.view];
            }
            else
            {
                [contentController.navigationController popToRootViewControllerAnimated:NO];                
            }
            [contentController configTitle:aValue.Title];
        }
    }
    else
    {
        [self.delegate.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushViewControllerForArticlesOfLaw:[[self currentTableData] objectAtIndex:indexPath.row]];    
}

#pragma mark --
#pragma mark ------------event

@end

//
//  ArticlesDelegateAndSource.m
//  Law
//
//  Created by shulianyong on 13-4-18.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "ArticlesDelegateAndSource.h"
#import "LawCell.h"
#import "ArticlesOfLaw.h"
#import "LawDetailController.h"
#import "DALFavorites.h"
#import "DALArticlesOfLaw.h"
#import "UserInfo.h"

@implementation ArticlesDelegateAndSource


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    tableView.backgroundColor = RGBColor(249, 249, 249);
    return [self currentTableData].count;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dicArticles = [[self currentTableData] objectAtIndex:section];
    NSArray *allValues = [dicArticles allValues];
    NSArray *titleArticles = [allValues objectAtIndex:0];
    return titleArticles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ArticlesCell";
    LawCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LawCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryView = nil;
        cell.selectedBackgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dicArticles = [[self currentTableData] objectAtIndex:indexPath.section];
    NSArray *allValues = [dicArticles allValues];
    NSArray *titleArticles = [allValues objectAtIndex:0];    
    ArticlesOfLaw *value = [titleArticles objectAtIndex:indexPath.row];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Heiti SC" size:15];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [self operationSpaceForContent:value.Contents];
    
    
    return cell;
}

#pragma mark --------table header view
- (void)clickFavorite:(UIButton*)sender withEvent:(id)event
{
    DALFavorites *dal = [[DALFavorites alloc] init];
    NSDictionary *dicArticles = [[self currentTableData] objectAtIndex:sender.tag];
    NSArray *allValues = [dicArticles allValues];
    NSArray *titleArticles = [allValues objectAtIndex:0];
    ArticlesOfLaw *value = [titleArticles objectAtIndex:0];
    value.isFavorite = !value.isFavorite;
    if (value.isFavorite) {
        [dal insertFavoritesWithObject:value
                            withUserId:[UserInfo shareInstance].Id
                   withSubjectParentId:self.delegate.subjectParentId];
    }
    else
    {
        [dal deleteWithObject:value
                   withUserId:[UserInfo shareInstance].Id];
    }
    [sender setImage:[UIImage imageNamed:value.isFavorite?@"icon_fav.png":@"icon_fav_no.png"] forState:UIControlStateNormal];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect tableBounds = tableView.bounds;
    
    UIButton *btnHeader = [UIButton buttonWithType:UIButtonTypeCustom];
    btnHeader.tag = section;
    [btnHeader setFrame:CGRectMake(0, 0, tableBounds.size.width, 54)];
    [btnHeader setBackgroundColor:RGBColor(249, 249, 249)];
    
    UIImageView *imgRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list-icon.png"]];    
    [imgRight setFrame:CGRectMake(10, 0, 7, 54)];
    [imgRight setContentMode:UIViewContentModeScaleAspectFit];
    
    [btnHeader addSubview:imgRight];
    
    [btnHeader addTarget:self action:@selector(click_Header:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [btnHeader setBackgroundImage:[UIImage imageNamed:@"img_tblHeaderBackground.png"] forState:UIControlStateHighlighted];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, tableBounds.size.width-55, 54)];
    [btnHeader addSubview:lblTitle];
    
    
    NSDictionary *dicArticles = [[self currentTableData] objectAtIndex:section];
    NSArray *allKeys = [dicArticles allKeys];
    NSArray *allValues = [dicArticles allValues];
    NSArray *titleArticles = [allValues objectAtIndex:0];
    ArticlesOfLaw *value = [titleArticles objectAtIndex:0];
    
    DALFavorites *dalFavorite = [[DALFavorites alloc] init];
    value.isFavorite = [dalFavorite isFavoriteToArticleTitle:value.Title ForUserId:[UserInfo shareInstance].Id];
    DALArticlesOfLaw *dalArticles = [[DALArticlesOfLaw alloc] init];
    value.isNew = [dalArticles isNewArticles:value.Title];
    
    //is new articles
    CGRect rightViewFrame = value.isNew?CGRectMake(tableBounds.size.width-45, 0, 45, 54):CGRectMake(tableBounds.size.width-30, 0, 30, 54);
    CGRect favoriteFrame = value.isNew?CGRectMake(15, 0, 30, 54):CGRectMake(0, 0, 30, 54);
    CGRect lblTitleFrame = CGRectMake(34, 0, tableBounds.size.width-34-rightViewFrame.size.width, 54);
    lblTitle.frame = lblTitleFrame;
    
    UIView *rightView = [[UIView alloc] initWithFrame:rightViewFrame];
    [rightView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    UIImageView *imgNew = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 15, 15)];
    [imgNew setImage:[UIImage imageNamed:value.isNew?@"img_light.png":@""]];
    UIButton *btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnFavorite setFrame:favoriteFrame];
    [btnFavorite setImage:[UIImage imageNamed:value.isFavorite?@"icon_fav.png":@"icon_fav_no.png"] forState:UIControlStateNormal];
    [btnFavorite addTarget:self action:@selector(clickFavorite:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    btnFavorite.tag = section;
    [rightView addSubview:btnFavorite];
    if (value.isNew) {
        [rightView addSubview:imgNew];
    }
    [btnHeader addSubview:rightView];
    
    lblTitle.text = [allKeys objectAtIndex:0];
    lblTitle.textAlignment = NSTextAlignmentLeft;
    lblTitle.numberOfLines = 3;
    lblTitle.textColor = RGBColor(140, 170, 152);
    lblTitle.minimumFontSize = 10;
    lblTitle.adjustsFontSizeToFitWidth = YES;
    lblTitle.font = [UIFont boldSystemFontOfSize:15];
    lblTitle.backgroundColor = [UIColor clearColor];
    
    return btnHeader;
}

- (void)click_Header:(UIButton*)sender withEvent:(id)event
{    
    LawDetailController *detailViewController = [[LawDetailController alloc] initWithNibName:@"LawDetailController" bundle:nil];    
    NSDictionary *dicArticles = [[self currentTableData] objectAtIndex:sender.tag];
    NSArray *allValues = [dicArticles allValues];
    NSArray *titleArticles = [allValues objectAtIndex:0];
    ArticlesOfLaw *lawArticle = [titleArticles objectAtIndex:0];
    detailViewController.lawArticle = lawArticle;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        detailViewController.hidesBottomBarWhenPushed = YES;
    }
    [self.delegate.navigationController pushViewController:detailViewController animated:YES];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dicArticles = [[self currentTableData] objectAtIndex:indexPath.section];
    NSArray *allValues = [dicArticles allValues];
    NSArray *titleArticles = [allValues objectAtIndex:0];
    ArticlesOfLaw *value = [titleArticles objectAtIndex:indexPath.row];
    
    self.delegate.txtvFix.text = value.Contents;
    CGFloat heightContent = calulateHeightForString([self operationSpaceForContent:value.Contents], [UIFont fontWithName:@"Heiti SC" size:15], self.delegate.view.bounds.size.width-42) ;
    heightContent+=5;
    heightContent = heightContent>44?heightContent:44;
    return heightContent;
}

- (NSString*)operationSpaceForContent:(NSString*)contents
{
    return [NSString stringWithFormat:@"        %@",[contents stringByReplacingOccurrencesOfString:@"\n" withString:@"\n        "]];
}

#pragma mark - Table view delegate

@end

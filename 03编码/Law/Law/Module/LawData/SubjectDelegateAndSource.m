//
//  SubjectDelegateAndSource.m
//  Law
//
//  Created by shulianyong on 13-4-18.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "SubjectDelegateAndSource.h"
#import "Subjects.h"
#import "DALFavorites.h"
#import "DALSubjects.h"
#import "UserInfo.h"
#import "LawContentController.h"
#import "LawDataController.h"

@implementation SubjectDelegateAndSource

- (void)LawCell:(LawCell*)cell withFavorite:(UIButton*)sender withEvent:(id)event
{
    cell.isFavorite = !cell.isFavorite;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DALFavorites *dal = [[DALFavorites alloc] init];
    
    if (cell.isFavorite) {
        NSInteger firstSubjectId = self.delegate.subjectParentId;
        id favoriteData = [[self currentTableData] objectAtIndex:indexPath.row];
        if ([self.delegate isKindOfClass:[LawDataController class]]) {
            firstSubjectId = [(Subjects*)favoriteData Id];
            if ([(LawDataController*)self.delegate isDidSearch]) {
                firstSubjectId = [dal fistSubjectId:[(Subjects*)favoriteData Id]];
            }
        }
        
        [dal insertFavoritesWithObject:favoriteData
                            withUserId:[UserInfo shareInstance].Id
                   withSubjectParentId:firstSubjectId];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SubjectCell";
    LawCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LawCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            cell.textLabel.textColor = RGBColor(69, 104, 104);
        }
    }    
    cell.delegate = self;
    Subjects *value = [self.currentTableData objectAtIndex:indexPath.row];
    cell.textLabel.text = value.Name;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = value.Description;
    cell.isFavorite = (value.isFavorite>0);
    cell.isNew = value.isNew;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Subjects *value = [self.currentTableData objectAtIndex:indexPath.row]; 
    if ([self.delegate respondsToSelector:@selector(tableDelegateAndSource:didSelectRowForObject:)]) {       
        [self.delegate tableDelegateAndSource:self didSelectRowForObject:value];
    }   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Subjects *value = [self.currentTableData objectAtIndex:indexPath.row];
    
    self.delegate.txtvFix.text = value.Name;
    CGFloat heightContent = self.delegate.txtvFix.contentSize.height;
    heightContent = heightContent>44?heightContent:44;
    return heightContent;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell bringSubviewToFront:cell.textLabel];
}

@end

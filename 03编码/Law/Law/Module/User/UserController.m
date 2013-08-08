//
//  UserController.m
//  Law
//
//  Created by shulianyong on 13-3-5.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "UserController.h"
#import "UserInfo.h"
#import "CDSFCategoriesUtility.h"
#import "AppDelegate.h"
#import "DAlUserSubject.h"
#import "Subjects.h"


#import "HttpOperation.h"
#import <QuartzCore/QuartzCore.h>

@interface UserController ()

//@property (nonatomic,assign) NSInteger cellRows;
@property (nonatomic,assign) NSString *aboutUs;
@property (nonatomic,strong) NSMutableArray *userCenterTitle;

@end

@implementation UserController

- (NSString *)tabImageName
{
	return @"menubar_icon_user.png";
}

- (NSString *)tabTitle
{
	return personalCenterString;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dismissViewController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)logout
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [[AppDelegate shareInstance].contentViewController dismissViewControllerAnimated:NO completion:^{
            [[AppDelegate shareInstance].contentViewController dismissViewControllerAnimated:YES completion:^{
                
            }];
        }];
    }
    else
    {
        [[AppDelegate shareInstance].contentViewController dismissViewControllerAnimated:YES completion:^{
            
        }];        
    }
    [(UINavigationController*)[AppDelegate shareInstance].window.rootViewController popToRootViewControllerAnimated:NO];
}

- (void)checkUpdate:(id)sender
{
    [HttpOperation getUserLawSubjects];
    [HttpOperation checkAllUpdates:YES];
    [HttpOperation syncNew];
}

- (UIButton*)customBarButton
{
    UIButton *btnLogout = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogout.frame = CGRectMake(0,0,60,28);
    [btnLogout setBackgroundImage:[UIImage imageNamed:@"imgBarItem.png"] forState:UIControlStateNormal];
    [btnLogout setBackgroundImage:[UIImage imageNamed:@"imgBarItemSelected.png"] forState:UIControlStateHighlighted];
    [btnLogout setTitleColor:RGBColor(67, 100, 100) forState:UIControlStateNormal];
    btnLogout.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    return btnLogout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self boundData];
//    self.cellRows = self.userCenterTitle.count-1;
    self.navigationItem.title = personalCenterString;
    self.navigationController.navigationBar.backgroundColor = RGBColor(242, 242, 242);    
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //default back button style
        UIButton *btnBack = [self customBarButton];
        [btnBack addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
        [btnBack setTitle:@"返回" forState:UIControlStateNormal];
        UIBarButtonItem *barBack = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
        [self.navigationItem setLeftBarButtonItem:barBack];
    }
    self.view.backgroundColor = RGBColor(230, 230, 230);
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else
        return ((interfaceOrientation ==UIDeviceOrientationPortrait)||(interfaceOrientation ==UIDeviceOrientationPortraitUpsideDown));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.userCenterTitle.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsNumber = 1;
    NSDictionary *dicValue = [self.userCenterTitle objectAtIndex:section];
    if ([[dicValue objectForKey:@"value"] isKindOfClass:[NSArray class]]) {
        NSArray *value = [dicValue objectForKey:@"value"];
        rowsNumber = value.count;
    }
    return rowsNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {     
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.textColor = RGBColor(94, 124, 124);
        cell.textLabel.textColor = RGBColor(94, 124, 124);
        if (indexPath.section==self.userCenterTitle.count-1) {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 21)];
            lblTitle.backgroundColor = [UIColor clearColor];
            lblTitle.textColor = RGBColor(94, 124, 124);
            lblTitle.font = [UIFont boldSystemFontOfSize:17];
            lblTitle.center = CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetMidY(cell.bounds));
            lblTitle.tag = 100;
            lblTitle.textAlignment = NSTextAlignmentCenter;
            [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
            [cell addSubview:lblTitle];
        }
        else
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
        cell.selectedBackgroundView = nil;        
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{    
    NSDictionary *dicValue = [self.userCenterTitle objectAtIndex:section];
    BOOL displayTitle = [[dicValue objectForKey:@"displayTitle"] boolValue];    
    if (displayTitle) {
        return [dicValue objectForKey:@"title"];
    }
    return nil;
}

- (void)boundData
{    
    UserInfo *userInfo = [UserInfo shareInstance];
    NSString *userCenterPlistPath = [[NSBundle mainBundle] pathForResource:@"UserCenter" ofType:@"plist"];
    self.userCenterTitle = [[NSMutableArray alloc] initWithContentsOfFile:userCenterPlistPath];
    NSDictionary *dicUser = [self.userCenterTitle objectAtIndex:0];
    [dicUser setValue:[NSString stringWithFormat:@"用户名 : %@",userInfo.UserName] forKey:@"value"];
    
    
    if ([CommonUtil importantStatus]) {
        DAlUserSubject *dalUserSubjects = [[DAlUserSubject alloc] init];
        NSArray *userSubjects = [dalUserSubjects userSubject:userInfo.Id];
        NSMutableArray *centerTitle = [[NSMutableArray alloc] initWithCapacity:userSubjects.count];        
        for (Subjects *subjectEntity in userSubjects) {
            [centerTitle addObject:[NSString stringWithFormat:@"%@ 截至 %@有效"
                                    ,subjectEntity.Name
                                    ,[subjectEntity.SubscriptionEnd substringToIndex:10]]
             ];
        }
        NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:dicUser];        
        NSDictionary *dicSubjects = [NSKeyedUnarchiver unarchiveObjectWithData:copyData];
        [dicSubjects setValue:centerTitle forKey:@"value"];
        [dicSubjects setValue:@"购买专题" forKey:@"title"];
        [dicSubjects setValue:[NSNumber numberWithBool:YES] forKey:@"displayTitle"];
        [self.userCenterTitle insertObject:dicSubjects atIndex:1];
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleValue = nil;
    NSDictionary *dicValue = [self.userCenterTitle objectAtIndex:indexPath.section];
    if ([[dicValue objectForKey:@"value"] isKindOfClass:[NSArray class]]) {
        NSArray *value = [dicValue objectForKey:@"value"];
        titleValue = [value objectAtIndex:indexPath.row];
    }
    else
    {
        titleValue = [dicValue objectForKey:@"value"];
    }
    
    cell.textLabel.text = titleValue;
    
    if (indexPath.section==self.userCenterTitle.count-1) {
        cell.textLabel.hidden = YES;
        [(UILabel*)[cell viewWithTag:100] setText:titleValue];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 44;
    
    NSString *titleValue = nil;
    NSDictionary *dicValue = [self.userCenterTitle objectAtIndex:indexPath.section];
    if ([[dicValue objectForKey:@"value"] isKindOfClass:[NSArray class]]) {
        NSArray *value = [dicValue objectForKey:@"value"];
        titleValue = [value objectAtIndex:indexPath.row];
    }
    else
    {
        titleValue = [dicValue objectForKey:@"value"];
    }
    rowHeight = calulateHeightForString(titleValue, [UIFont boldSystemFontOfSize:17], self.view.bounds.size.width-42)+10;
    rowHeight = rowHeight>44?rowHeight:44;
    
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==self.userCenterTitle.count-1) {
        if (indexPath.row==0) {
            [self checkUpdate:nil];
        }
        else
        {
            [self logout];
        }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end

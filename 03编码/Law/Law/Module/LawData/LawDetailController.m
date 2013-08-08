//
//  LawDetailController.m
//  Law
//
//  Created by shulianyong on 13-3-25.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "LawDetailController.h"
#import "DALFavorites.h"
#import "UserInfo.h"
#import "DALArticlesOfLaw.h"

@interface LawDetailController ()

@property (nonatomic,strong) UIButton *btnFavorite;
@property (nonatomic,strong) NSArray *articlesList;

@end

@implementation LawDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-20, 44)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = RGBColor(83, 83, 83);
    lblTitle.font = [UIFont boldSystemFontOfSize:15];
    lblTitle.minimumFontSize = 10;
    lblTitle.adjustsFontSizeToFitWidth = YES;
    lblTitle.text = self.lawArticle.Title;
    lblTitle.backgroundColor = [UIColor clearColor];   
    [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
    [lblTitle setNumberOfLines:3];
    self.navigationItem.titleView = lblTitle;
    
    INFO(@"defaultArticlesData");
    [self defaultArticlesData];
    NSMutableString *content = [[NSMutableString alloc] init];
    INFO(@"appendFormat");
    for (ArticlesOfLaw *article in self.articlesList) {
        [content appendFormat:@"%@%@\n",@"        ",[article.Contents stringByReplacingOccurrencesOfString:@"\n" withString:@"\n        "]];
    }
    INFO(@"appendFormated");
    self.txtvContent.text = content;
    // Do any additional setup after loading the view from its nib.
}

- (void)loadView
{
    [super loadView];
    //default back button style
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(0,0,17,17);
    [btnBack setBackgroundImage:[UIImage imageNamed:@"icon_esc.png"] forState:UIControlStateNormal];
    [btnBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBack = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    [self.navigationItem setLeftBarButtonItem:barBack];
    
    
    //default add fav
    if (![self isFavoriteFunction]) {        
        self.btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnFavorite.frame = CGRectMake(0,0,30,30);
        [self.btnFavorite addTarget:self action:@selector(click_btnFavorite:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barFavorite = [[UIBarButtonItem alloc] initWithCustomView:self.btnFavorite];
        [self.navigationItem setRightBarButtonItem:barFavorite];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DALFavorites *dalFavorite = [[DALFavorites alloc] init];
    self.lawArticle.isFavorite = [dalFavorite isFavoriteToArticleTitle:self.lawArticle.Title ForUserId:[UserInfo shareInstance].Id];
    [self configFavoriteImage];
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
    [self setTxtvContent:nil];
    [super viewDidUnload];
}

#pragma mark ----------button event
- (void)click_btnFavorite:(id)sender
{
    DALFavorites *dal = [[DALFavorites alloc] init];
    if (self.lawArticle.isFavorite) {
        self.lawArticle.isFavorite = 0;
        [dal deleteWithObject:self.lawArticle
                   withUserId:[UserInfo shareInstance].Id];
    }
    else
    {
        self.lawArticle.isFavorite = (self.lawArticle.Id==0)?1:self.lawArticle.Id;
        [dal insertFavoritesWithObject:self.lawArticle
                            withUserId:[UserInfo shareInstance].Id withSubjectParentId:0];
    }
    [self configFavoriteImage];
}

- (void)configFavoriteImage
{
    if (self.lawArticle.isFavorite>0) {
        [self.btnFavorite setImage:[UIImage imageNamed:@"icon_fav.png"] forState:UIControlStateNormal];
    }
    else
    {        
        [self.btnFavorite setImage:[UIImage imageNamed:@"icon_fav_no.png"] forState:UIControlStateNormal];
    }
}

#pragma mark ----------db data
- (void)defaultArticlesData
{
    DALArticlesOfLaw *dal = [DALArticlesOfLaw alloc];
    self.articlesList = [dal articlesWithTitle:self.lawArticle.Title withUserId:[UserInfo shareInstance].Id];
}

@end

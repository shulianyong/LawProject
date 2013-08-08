//
//  FavoriteController.h
//  Law
//
//  Created by shulianyong on 13-3-5.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LawContentController;

@interface FavoriteController : UITableViewController

- (IBAction)click_segChange:(UIControl*)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnArticle;

@property (strong, nonatomic) LawContentController *detailViewController;

@end

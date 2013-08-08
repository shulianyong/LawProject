//
//  LawNewsDetailController.h
//  Law
//
//  Created by shulianyong on 13-3-22.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class News;
@interface LawNewsDetailController : UIViewController<UISplitViewControllerDelegate>

@property (strong, nonatomic) News *currentNews;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UIImageView *imgNews;
@property (strong, nonatomic) IBOutlet UIScrollView *scrvContent;
@property (strong, nonatomic) IBOutlet UITextView *txtvFix;

@end

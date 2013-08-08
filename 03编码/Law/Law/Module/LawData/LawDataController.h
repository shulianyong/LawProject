//
//  LawDataController.h
//  Law
//
//  Created by shulianyong on 13-3-5.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LawCell.h"
@class LawContentController;

@interface LawDataController : UITableViewController<UISearchBarDelegate>

@property (nonatomic,strong) NSArray *lawSubjects;
@property (nonatomic,strong) NSString *titleValue;

@property (strong, nonatomic) LawContentController *detailViewController;
@property (nonatomic,strong) UITextView *txtvFix;

- (BOOL)isDidSearch;
@end

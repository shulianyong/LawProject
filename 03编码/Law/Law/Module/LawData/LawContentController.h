//
//  LawContentController.h
//  Law 法条界面
//
//  Created by shulianyong on 13-3-11.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubjectDelegateAndSource.h"
@class Subjects;

extern const NSInteger NoDataViewTag;
extern const NSInteger DetailViewTag;

@interface LawContentController : UITableViewController<UISplitViewControllerDelegate,TableDelegateAndSourceDelegate>

@property (nonatomic,strong) Subjects *subject;
@property (nonatomic,assign) BOOL isDisplayArticel;
//显示法律法规
@property (nonatomic,assign) BOOL isDisplayArticelContent;
@property (strong, nonatomic) UITextView *txtvFix;

//最上层的，用于查找这个是否是需要付费的
- (void)configTitle:(NSString*)aTitle;
- (IBAction)click_segChange:(UIControl*)sender;
- (void)reloadViewData;

@end

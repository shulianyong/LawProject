//
//  NewsCell.h
//  Law
//
//  Created by shulianyong on 13-3-19.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
@interface NewsCell : UITableViewCell
@property (strong, nonatomic) UIImageView *imgNews;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblDescription;
@property (strong, nonatomic) UILabel *lblOther;

@property (strong, nonatomic) News *newsInfo;
//重要布局
- (void)relayout:(CGFloat)height;

@end

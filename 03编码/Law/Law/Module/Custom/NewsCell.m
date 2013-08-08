//
//  NewsCell.m
//  Law
//
//  Created by shulianyong on 13-3-19.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "NewsCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"

@implementation NewsCell

@synthesize newsInfo=_newsInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSInteger lines = 3;
        NSInteger cornerRadius = 5;
        
        UIView *viewSelected = [[UIView alloc] init];
        [viewSelected setBackgroundColor:RGBColor(138, 179, 154)];
        self.selectedBackgroundView = viewSelected;
        
        self.imgNews = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgNews.layer.masksToBounds = YES;
        self.imgNews.layer.cornerRadius = cornerRadius;
        self.imgNews.contentMode = UIViewContentModeScaleAspectFit;
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblTitle.numberOfLines = lines;
        self.lblTitle.textColor = RGBColor(98, 154, 114);
        self.lblTitle.font = [UIFont systemFontOfSize:13];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        
        self.lblDescription = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblDescription.numberOfLines = lines;
        self.lblDescription.textColor = RGBColor(83, 83, 83);
        self.lblDescription.font = [UIFont systemFontOfSize:10];
        self.lblDescription.backgroundColor = [UIColor clearColor];
        
        
        self.lblOther = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblOther.textColor = RGBColor(135, 135, 135);
        self.lblOther.font = [UIFont systemFontOfSize:10];
        self.lblOther.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.imgNews];
        [self addSubview:self.lblTitle];
        [self addSubview:self.lblDescription];
        [self addSubview:self.lblOther];
    }
    return self;
}

- (void)relayout:(CGFloat)height
{        
    self.imgNews.frame = CGRectMake(5, 5, height-10, height-10);   
    CGFloat labelWidth = self.bounds.size.width-self.imgNews.bounds.size.width-10;
    INFO(@"width:%f",labelWidth);
    CGFloat labelX = CGRectGetMaxX(self.imgNews.frame)+5;
    if ([self.newsInfo.DefaultImageUrl isEmpty]) {
        labelX = 5;
        labelWidth = self.bounds.size.width-10;
    }
    
    
    CGFloat lblTitleHeight = calulateHeightForString(self.lblTitle.text, self.lblTitle.font, labelWidth);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        lblTitleHeight = lblTitleHeight>58?58:lblTitleHeight;
    }
    else
    {
        lblTitleHeight = lblTitleHeight>46?46:lblTitleHeight;
    }
    CGFloat lblDescriptionHeight = 28;
    CGFloat lblOther = 14;
    CGFloat lblTitleY = (height-lblTitleHeight-lblDescriptionHeight-lblOther)/2;
    
    self.lblTitle.frame = CGRectMake(labelX
                                     , lblTitleY
                                     , labelWidth
                                     , lblTitleHeight);
    self.lblDescription.frame = CGRectMake(labelX
                                           , CGRectGetMaxY(self.lblTitle.frame)
                                           , labelWidth
                                           , lblDescriptionHeight);
    self.lblOther.frame = CGRectMake(labelX
                                     , CGRectGetMaxY(self.lblDescription.frame)
                                     , labelWidth
                                     , lblOther);
    
    [self.lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
    [self.lblDescription setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
    
}

- (void)setNewsInfo:(News *)newsInfo
{
    _newsInfo = newsInfo;
    [self boundData];
}

- (void)boundData
{   
    self.lblTitle.text = self.newsInfo.Title;
    
    self.lblDescription.text = [NSString stringWithFormat:@"%@ \n \n",[self.newsInfo.Contents trim]];
    NSDate *lastUpdate = [NSDate dateWithTimeIntervalSince1970:self.newsInfo.LastUpdateTime];
    self.lblOther.text = [lastUpdate descriptionLocalAsFormat:@"YYYY年MM月dd日 HH:mm"];
    self.lblOther.text = [self.lblOther.text stringByAppendingFormat:@" %@",self.newsInfo.Source];
    self.imgNews.image = [UIImage imageNamed:@"imgTabBarBackGround.png"];
    [self.imgNews setImageWithURL:[NSURL URLWithString:self.newsInfo.DefaultImageUrl]];
}

@end

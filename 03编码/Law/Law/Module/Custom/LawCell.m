//
//  LawCell.m
//  Law
//
//  Created by shulianyong on 13-3-19.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "LawCell.h"

@interface LawCell ()

@property (nonatomic,strong) UIImageView *imgNew;

@end

@implementation LawCell

@synthesize isNew;
@synthesize isFavorite;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
        rightView.backgroundColor = [UIColor clearColor];
        self.imgNew = [[UIImageView alloc] initWithFrame:CGRectMake(5, 12, 15, 15)];
        [self.imgNew setImage:[UIImage imageNamed:self.isNew?@"img_light.png":@""]];
        self.btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnFavorite setFrame:CGRectMake(0, 5, 30, 30)];
        [self.btnFavorite setImage:[UIImage imageNamed:self.isFavorite?@"icon_fav.png":@"icon_fav_no.png"] forState:UIControlStateNormal];
        [self.btnFavorite addTarget:self action:@selector(click_Favorite:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:self.btnFavorite];
    
        self.accessoryView = rightView;
        self.imageView.image = [UIImage imageNamed:@"list_icon_c.png"];
        
        UIView *viewSelected = [[UIView alloc] init];
        [viewSelected setBackgroundColor:RGBColor(138, 179, 154)]; 
        [self setSelectedBackgroundView:viewSelected];
        
        self.textLabel.textColor = RGBColor(83, 83, 83);
        self.textLabel.minimumFontSize = 10;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.minimumFontSize = 10;
        self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)click_Favorite:(UIButton*)sender withEvent:(id)event
{
    [[self delegate] LawCell:self withFavorite:sender withEvent:event];
}

- (void)setIsNew:(BOOL)aIsNew
{
    isNew = aIsNew;
    if (isNew) {        
        [self.imgNew setImage:[UIImage imageNamed:self.isNew?@"img_light.png":@""]];
        [self.accessoryView addSubview:self.imgNew];
        self.accessoryView.frame = CGRectMake(0, 0, 45, 40);
        self.btnFavorite.frame = CGRectMake(15, 5, 30, 30);
    }
    else
    {
        [self.imgNew removeFromSuperview];
        self.accessoryView.frame = CGRectMake(0, 0, 30, 40);
        self.btnFavorite.frame = CGRectMake(0, 5, 30, 40);
    }
}

- (void)setIsFavorite:(BOOL)aIsFavorite
{
    isFavorite = aIsFavorite;
    [self.btnFavorite setImage:[UIImage imageNamed:self.isFavorite?@"icon_fav.png":@"icon_fav_no.png"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

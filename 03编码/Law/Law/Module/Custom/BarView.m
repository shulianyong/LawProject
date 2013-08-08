//
//  BarView.m
//  splitTest
//
//  Created by shulianyong on 13-4-20.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.,LTD. All rights reserved.
//

#import "BarView.h"

@interface BarView ()
{
    BOOL isNotFirstDraw;
}

@property (nonatomic,strong) UIButton *btnSelected;
//放所有Item的View
@property (nonatomic,strong) UIView *itemView;

@end

@implementation BarView

@synthesize btnSelected;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

int const offset = 100;
int const itemViewWidth = 320;
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (isNotFirstDraw) {
        return;
    }
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:self.imgBackground]];    
    self.itemView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-itemViewWidth, 0, itemViewWidth, self.bounds.size.height)];
    self.itemView.backgroundColor = [UIColor clearColor];
    [self.itemView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    
    [self addSubview:self.itemView];
    for (UIView *obj in self.barController.tabBar.subviews) {        
        if (![obj isKindOfClass:self.class]) {
            [obj removeFromSuperview];
        }
    }
    [self drawButton];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIImageView *barLog = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pag-logo.png"]];
        barLog.frame = CGRectMake(80, (self.bounds.size.height-27)/2, 251, 27);
        [self addSubview:barLog];
    }
    self.barController.tabBar.backgroundImage = [UIImage imageNamed:self.imgBackground];
    isNotFirstDraw = YES;
}

- (void)setBtnSelected:(UIButton *)aBtnSelected
{
    if (btnSelected) {
        [btnSelected setSelected:NO];
    }
    [aBtnSelected setSelected:YES];
    btnSelected = aBtnSelected;
}

- (void)drawButton
{   
    CGFloat barWidth = self.itemView.bounds.size.width/self.viewControllers.count;
    for (int i=0; i<self.viewControllers.count; i++) {
        UIViewController *currentController = [self.viewControllers objectAtIndex:i];
        
        UIButton *btnBar = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBar.frame = CGRectMake(i*barWidth, 0, barWidth, self.bounds.size.height);
        btnBar.tag = i+offset;
        [btnBar setBackgroundImage:[UIImage imageNamed:self.imgSelectBackground] forState:UIControlStateSelected];
        [btnBar setBackgroundImage:nil forState:UIControlStateNormal];
        
        [btnBar addTarget:self action:@selector(didSelectedItem:) forControlEvents:UIControlEventTouchUpInside];
        [btnBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
                
        [btnBar setTitle:currentController.tabTitle forState:UIControlStateNormal];
        UIFont *btnFont = [UIFont boldSystemFontOfSize:12];
        [btnBar.titleLabel setFont:btnFont];
        [btnBar setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnBar.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        btnBar.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 5, 0);
        
        UIImageView *imgvIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:currentController.tabImageName]];
        imgvIcon.frame = CGRectMake((barWidth-22)/2, 5, 22, 22);
        [btnBar addSubview:imgvIcon];
        [imgvIcon setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        if (i==0) {           
            self.btnSelected = btnBar;
        }        
        [self.itemView addSubview:btnBar];
    }
}

- (void)didSelectedItem:(UIButton*)sender
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {        
        if (sender.tag-offset+1 == self.viewControllers.count) {
            UIViewController *lastController = [self.viewControllers lastObject];
            lastController.modalPresentationStyle = UIModalPresentationFormSheet;
            lastController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self.barController presentViewController:lastController animated:YES completion:^{
                
            }];
            return;
        }
    }
    if (sender.tag==self.btnSelected.tag) {
        UIViewController *currentController = [self.barController selectedViewController];
        if ([currentController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController*)currentController popToRootViewControllerAnimated:YES];
        }
    }
    else
    {
        self.btnSelected = sender;
        [self.barController setSelectedIndex:sender.tag-offset];
    }
    
}

@end

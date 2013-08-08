//
//  LawCell.h
//  Law
//
//  Created by shulianyong on 13-3-19.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LawCell;

@protocol LawCellDelegate <NSObject>

- (void)LawCell:(LawCell*)cell withFavorite:(UIButton*)sender withEvent:(id)event;

@end

@interface LawCell : UITableViewCell
{
    @private
}

@property (nonatomic,assign) id<LawCellDelegate> delegate;
@property (nonatomic,assign) BOOL isNew;
@property (nonatomic,assign) BOOL isFavorite;
@property (nonatomic,strong) UIButton *btnFavorite;
@end

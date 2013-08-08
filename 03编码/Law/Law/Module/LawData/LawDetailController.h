//
//  LawDetailController.h
//  Law
//
//  Created by shulianyong on 13-3-25.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticlesOfLaw.h"

@interface LawDetailController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *txtvContent;

@property (strong,nonatomic) ArticlesOfLaw *lawArticle;

@property (nonatomic) BOOL isFavoriteFunction;

@end

//
//  AlertViewUtil.h
//  Law
//
//  Created by shulianyong on 13-4-18.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertViewUtil : NSObject<UIAlertViewDelegate>

+ (AlertViewUtil*)shareInstance;

- (void)alertMessage:(NSString *)aMessage withCancelTitle:(NSString*)aCancelTitle withOkBlock:(dispatch_block_t)block;
- (void)alertMessage:(NSString*)aMessage withOkBlock:(dispatch_block_t)block;

- (void)showTitle:(NSString*)aMessage atProcessIndex:(CGFloat)index;
- (void)cancelProcess;
@property (atomic,assign) BOOL canceled;

@end

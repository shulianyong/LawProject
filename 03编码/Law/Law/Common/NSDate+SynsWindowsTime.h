//
//  NSDate+SynsWindowsTime.h
//  Law
//
//  Created by shulianyong on 13-3-22.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SynsWindowsTime)

+ (NSDate*)changeDateToLocalDate:(NSDate*)date;
+ (NSTimeInterval)timeIntervalFromJsonDate:(NSString*)aDateString;
+ (NSString*)jsonTimeFromTimeInterval:(NSTimeInterval)aTimeInterval;

@end

//
//  NSDate+SynsWindowsTime.m
//  Law
//
//  Created by shulianyong on 13-3-22.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "NSDate+SynsWindowsTime.h"

@implementation NSDate (SynsWindowsTime)

+ (NSDate*)changeDateToLocalDate:(NSDate*)date{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    return localeDate;
}

+ (NSTimeInterval)timeIntervalFromJsonDate:(NSString*)aDateString
{
    NSString *interval = [aDateString stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
    interval = [interval stringByReplacingOccurrencesOfString:@"+0800)/" withString:@""];
    NSTimeInterval time = [interval doubleValue];
    time = time/1000;
    return time;
}

+ (NSString*)jsonTimeFromTimeInterval:(NSTimeInterval)aTimeInterval
{
    return [NSString stringWithFormat:@"/Date(%.0f+0800)/",aTimeInterval*1000];
}

@end

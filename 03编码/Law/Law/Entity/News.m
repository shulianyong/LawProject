//
//  News.m
//  Law
//
//  Created by shulianyong on 13-3-21.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "News.h"

@implementation News

@synthesize DefaultImageUrl=aDefaultImageUrl;

- (NSString*)DefaultImageUrl
{
    if ([aDefaultImageUrl hasSuffix:@"/"] || [aDefaultImageUrl isEmpty]) {
        return @"";
    }
    else
        return aDefaultImageUrl;
}

- (void)setDefaultImageUrl:(NSString *)DefaultImageUrl
{
    if ([DefaultImageUrl isKindOfClass:[NSNull class]]) {
        aDefaultImageUrl = @"";
        return;
    }
    if ([DefaultImageUrl hasSuffix:@"/"] || [DefaultImageUrl isEmpty]) {
        aDefaultImageUrl = @"";
    }
    else
    {
        aDefaultImageUrl = DefaultImageUrl;
    }
}

@end

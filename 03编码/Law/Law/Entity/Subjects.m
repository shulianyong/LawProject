//
//  Subjects.m
//  Law
//
//  Created by shulianyong on 13-3-11.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "Subjects.h"

@implementation Subjects

- (NSString*)Description
{
    if ([_Description isKindOfClass:[NSNull class]]) {
        return @"";
    }
    return [NSString valueNotNull:_Description];
}
@end

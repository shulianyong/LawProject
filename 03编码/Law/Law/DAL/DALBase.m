//
//  DALBase.m
//  Law
//
//  Created by shulianyong on 13-3-11.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALBase.h"
#import "CDSFCategoriesUtility.h"
#import <objc/runtime.h>

@interface DALBase ()
{
    FMDatabase *db;
}

@end

@implementation DALBase

- (NSString*)dbPath
{
    static NSString *dbPath = nil;
    if(dbPath == nil)
    {
        NSString *dbName = @"/LawDB.db";
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        bundlePath = [bundlePath stringByAppendingString:dbName];
        
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        
        documentPath = [documentPath stringByAppendingString:dbName];        
        if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{                    
                    [CommonUtil showLoadingWithTitle:@"数据准备..."];
                });
                NSError *error = [[NSError alloc] init];
                BOOL ret = [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:documentPath error:&error];
                if (!ret) {
                    NSLog(@"fault");
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [CommonUtil endLoading];
                });
            });
            
        }      
        dbPath = [[NSString alloc] initWithString:documentPath];
    }
    return dbPath;
}

- (void)initDataBase
{
    [self dbPath];
}

- (FMDatabase*)db
{
    if (db==nil) {        
        db = [FMDatabase databaseWithPath:[self dbPath]];
    }
    db.logsErrors = YES;
    return db;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end

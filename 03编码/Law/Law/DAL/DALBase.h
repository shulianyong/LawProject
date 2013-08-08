//
//  DALBase.h
//  Law
//
//  Created by shulianyong on 13-3-11.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDSFDataBase.h"
#import "CDSFCategoriesUtility.h"

@interface DALBase : NSObject

@property (nonatomic,readonly) FMDatabase *db;

- (void)initDataBase;

@end

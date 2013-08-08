//
//  TableDelegateAndSource.m
//  Law
//
//  Created by shulianyong on 13-4-18.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "TableDelegateAndSource.h"

@implementation TableDelegateAndSource

- (id)initWithTableView:(UITableView*)aTableView withDelegate:(UIViewController<TableDelegateAndSourceDelegate>*)aDelegate;
{
    self = [super init];
    if (self) {
        self.tableView = aTableView;
        self.delegate = aDelegate;
    }
    return self;
}

@end

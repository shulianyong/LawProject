//
//  TableDelegateAndSource.h
//  Law
//
//  Created by shulianyong on 13-4-18.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TableDelegateAndSource;

@protocol TableDelegateAndSourceDelegate <NSObject>
@property (strong, nonatomic) UITextView *txtvFix;

//最上层的专题ID
@property (nonatomic,assign) NSInteger subjectParentId;
@optional
- (BOOL)tableDelegateAndSource:(TableDelegateAndSource*)tableDelegateAndSource didSelectRowForObject:(id)aValue;

@end

@interface TableDelegateAndSource : NSObject<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray *currentTableData;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,weak) UIViewController<TableDelegateAndSourceDelegate> *delegate;

- (id)initWithTableView:(UITableView*)aTableView withDelegate:(UIViewController<TableDelegateAndSourceDelegate>*)aDelegate;

@end




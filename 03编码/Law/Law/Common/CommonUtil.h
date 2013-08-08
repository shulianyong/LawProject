//
//  CommonUtil.h
//  Law
//
//  Created by shulianyong on 13-3-20.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const alertString;
extern NSString *const okString;
extern NSString *const dismissString;
extern NSString *const pleaseBuyTheSubjectString;
extern NSString *const loginString;
extern NSString *const loginLoading;
extern NSString *const updateDataString;
extern NSString *const logoutString ;
extern NSString *const haveNoDataString ;
extern NSString *const companyAddressString;
extern NSString *const messageString;
extern NSString *const downloadingString;
extern NSString *const loadingString;

//title
extern NSString *const lawDataString;
extern NSString *const lawNewsString;
extern NSString *const favoriteString;
extern NSString *const personalCenterString;
//network check
extern NSString *const checkUpdateString;
extern NSString *const checkUpdateLoadingString;
extern NSString *const networkDisconnectedString;
extern NSString *const HaveNoUpdateDataString;


@interface CommonUtil : NSObject

CGFloat calulateHeightForString(NSString*lrcString,UIFont*font,CGFloat rowWidth);

+ (void)showMessage:(NSString*)aMessage;

+ (void)showLoadingWithTitle:(NSString*)aTitle;

+ (void)endLoading;

+ (NSTimeInterval)timeIntervalForUpdateSubject;
+ (void)setTimeIntervalForUpdateSubject:(NSTimeInterval)timeInterval;

+ (NSTimeInterval)timeIntervalForUpdateArticles;
+ (void)setTimeIntervalForUpdateArticles:(NSTimeInterval)timeInterval;

+ (NSTimeInterval)timeIntervalForSyncNews;
+ (void)setTimeIntervalForSyncNews:(NSTimeInterval)timeInterval;

//地址

+ (void)setImportantStatus:(BOOL)aStatus;
+ (BOOL)importantStatus;
+ (void)setImportantAddress:(NSString*)aAddress;
+ (NSString*)importantAddress;
+ (void)setImportantMessage:(NSString*)aMessage;
+ (NSString*)importantMessage;

+ (BOOL)showImportantMessageBySubjectId:(NSInteger)aSubjectId;
@end

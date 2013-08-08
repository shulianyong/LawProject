//
//  NSString+Util.h
//  VVM
//
//  Created by shulianyong on 12/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DCM_DOCUMENT_NAME
#define DCM_DOCUMENT_NAME @"DCMDATADOCUMENT"
#endif

@interface NSString (Util)

- (BOOL)isEmpty;

+ (NSString*)urlEncode:(NSString*)aSource;

+ (NSString*)urlDecode:(NSString*)aSource;

+ (unsigned int)convertHexString:(NSString*)aHex;

+ (NSString*)base64Encode:(NSData*)aData;

+ (NSString*)base64Encode:(NSString*)aString encoding:(NSStringEncoding)aEncoding;

+ (NSString*)base64Decode:(NSString*)aBase64 encoding:(NSStringEncoding)aEncoding;

+ (NSString*)base64Decode:(NSString*)aBase64;

+ (NSUInteger)length:(NSString*)aString;

+ (BOOL)isAsciiOnly:(NSString*)aString;

+ (BOOL) regexWithFormat:(NSString*)aFormat ValueString:(NSString*)aValueString;

+ (NSString*) MD5:(NSString*)aValue;

+ (NSString *) phoneNumFormat:(NSString*)aValue;

+ (NSArray*)emails:(NSString*)aText;

+ (NSString *) valueNotNull:(NSString*)aValue;

+ (BOOL) marchStringForSearch:(NSString*)aBaseString withMarch:(NSString*)aMarchString;

+ (NSString *) firstLetter:(NSString*)aString;


#pragma mark --dcm path
+ (NSString*)documentPath;

+ (NSString*)pathInDocument:(NSString*)aPath;

+ (NSString*)fileNameWithFilePath:(NSString*)aFilePath;

//获取文件名，主要取下划线之前的数据
+ (NSString*)fileNameWithFilePathForUnderline:(NSString *)aFilePath;
//获取plist路，用于存线条的路径
+ (NSString*)dcmPlistDataPath:(NSString*)aFileName;
//获取jpeg路径
+ (NSString*)jpegFilePathWithFilePath:(NSString*)aFilePath;
//获取被剪切的jpeg
+ (NSString*)clippedJpegFilePath:(NSString*)aFilePath;
//bmp路径
+ (NSString*)bmpPathWithFilePath:(NSString*)aFilePath;

//获取dcm路径
+ (NSString*)dcmPathWithFilePath:(NSString*)aFilePath;
//获取已经处理的dcm路径
+ (NSString*)dcmProcessedWithFilePath:(NSString*)aFilePath withProcessedRow:(int)aRow;

- (NSString*)trim;

+ (BOOL)isNumberString:(NSString*)aString;

@end

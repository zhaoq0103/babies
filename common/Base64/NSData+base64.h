//
//  NSData+base64.h
//  Fetion
//
//  Created by zypsg on 9/2/09.
//  Copyright 2009 zyp company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (URLENCODE)

-(NSString *)rawUrlEncode;
-(NSString *)rawUrlEncodeByEncoding:(NSStringEncoding)code;

@end

@interface NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;
+ (id) dataToBase64Encoded:(NSData*)data;//使用base64编码处理数据.
+ (id) dataFromBase64Encoded:(NSData*)base64Data;//将base64编码的数据还原.

@end

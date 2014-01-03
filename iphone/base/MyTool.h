//
//  MyTool.h
//  SinaNews
//
//  Created by shieh fabo on 11-9-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyTool : NSObject {
    
}
+ (BOOL)isRunningOniPad;
+ (UIDeviceOrientation)deviceOrientation;
+ (NSString*)encryptPwd:(NSString*)pwd;
+ (NSString*)decryptPwd:(NSString*)encryptPassword;
+ (NSString*)MD5DigestFromString:(NSString*)aString;
+ (NSString*)MD5Digest:(NSData*)data;
+ (NSString*)MD5RandomString;
+ (NSString*)MD5RandomStringFromTime:(NSDate*)cTime extraNum:(BOOL)bNeed;
+ (NSString*) stringWithUUID;
+ (NSString *)HMAC_SHA1:(NSString *)key text:(NSString *)text;
+ (NSInteger)getFreeMemory;
+ (NSString *)getDeviceUniqueMD5;
+ (UIImage*)makeTwoImageForOne:(UIImage*)image1 firstRect:(CGRect)subRect1 secondImage:(UIImage*)image2 sencondRect:(CGRect)subRect2;
+ (NSString*)writeToDocument:(id)data folder:(NSString*)folderName fileName:(NSString*)filename;
+ (NSString*)humanizeDateFormatFromDate:(NSDate*)date;
+ (NSString*)threePartDateFormatFromDate:(NSDate*)date;
+ (NSString *)flattenHTML:(NSString *)html;
+ (NSInteger)getFileSizeFromPath:(NSString*)pathString;
//+ (BOOL)isRetina;
//+ (BOOL)isPad;
//+ (BOOL)isSimulator;

+ (BOOL)isDigtal:(NSString *)string;

+(NSString*)urlParmFormatWithSourceString:(NSString*)sourceString FromDict:(NSDictionary*)dict order:(NSArray*)orderArray useEncode:(BOOL)encoded;
+(NSString*)urlString:(NSString*)urlString replaceStringKey:(NSString*)stringKey withValueString:(NSString*)valueString;
+(NSString*)formatlizeJSonStringWith:(NSString*)oldJson;
+(UIColor *)colorWithHexString: (NSString *)color;

+ (UIButton *)createButton:(NSString *)text font:(UIFont *)font color:(UIColor *)color width:(int)width height:(int)height left:(int)x top:(int)y;
@end

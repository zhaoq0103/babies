//
//  RegValueSaver.h
//  SinaNews
//
//  Created by shieh exbice on 11-7-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegValueSaver : NSObject
{
    @private
    NSMutableDictionary* mAccountDict;
    NSString* mCurrrentUserID;
}

@property(retain)NSString* currrentUserID;

+ (id)getInstance;

-(void)saveSystemInfoValue:(id)data forKey:(NSString*)oneKey encryptString:(BOOL)bEncrypt;
-(id)readSystemInfoForKey:(NSString*)oneKey;
-(void)saveUserInfoValue:(id)data forKey:(NSString*)oneKey userID:(NSString*)mid encryptString:(BOOL)bEncrypt;
-(id)readUserInfoForKey:(NSString*)oneKey userID:(NSString*)mid;

/////extend
-(NSDictionary*)readAccountDict;
-(void)saveAccountDictValue:(NSString*)uid forKey:(NSString*)accountName;
-(NSString*)findUIDFromAccount:(NSString*)accountName;
//-(void)removeinfovalue:(NSString*)oneKey;
-(void)removeAccountDictValueforkey:(NSString*)accountName;
-(void)removeSystemInfoValueforkey:(NSString*)oneKey;
-(void)removeUserInfoValueforKey:(NSString*)oneKey userID:(NSString*)mid;


//User Name Remember for easier login
-(void)saveUserName:(NSString*)accountName;
-(NSString*)getSavedUserName;
@end

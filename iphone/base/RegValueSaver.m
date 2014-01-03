//
//  RegValueSaver.m
//  SinaNews
//
//  Created by shieh exbice on 11-7-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "RegValueSaver.h"
#import "MyTool.h"

NSString* RegKey_SYSTEMINFO = @"{systeminfo}";
NSString* RegKey_AccountDict = @"{accountdict}";
NSString* Encrypt_Header = @"~{encrypt}";

#define                 kSaved_User_Name            @"savedUserName"

static RegValueSaver* s_regValueSaver = nil;

@interface RegValueSaver (private)

-(void)initAccountDict;
-(void)saveInfoValue:(id)data forKey:(NSString*)oneKey encryptString:(NSString*)bEncryptStr;
-(id)readInfoForKey:(NSString*)oneKey encryptString:(NSString*)bEncryptStr;
-(NSMutableArray*)revertArrayToEncryptArray:(NSArray*)array encryptString:(NSString*)bEncryptStr;
-(NSMutableDictionary*)revertDictToEncryptDict:(NSDictionary*)dict encryptString:(NSString*)bEncryptStr;
-(NSMutableDictionary*)revertDictToDecryptDict:(NSDictionary*)dict encryptString:(NSString*)bEncryptStr;
-(NSMutableArray*)revertArrayToDecryptArray:(NSArray*)array encryptString:(NSString*)bEncryptStr;
-(NSString*)subStringOfString:(NSString*)sourceString removePrefixString:(NSString*)prefix;
-(NSString*)decryptStringValue:(NSString*)sourceString encryptString:(NSString*)bEncryptStr;
-(NSString*)encryptStringValue:(NSString*)sourceString encryptString:(NSString*)bEncryptStr;

@end

@implementation RegValueSaver

@synthesize currrentUserID = mCurrrentUserID;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self initAccountDict];
    }
    
    return self;
}

-(void)dealloc
{
    [mAccountDict release];
    [mCurrrentUserID release];
    
    [super dealloc];
}

+ (id)getInstance
{
	if (s_regValueSaver == nil)
	{
		//没有创建则创建
		s_regValueSaver = [[RegValueSaver alloc] init];
	}
	return s_regValueSaver;
}

-(void)initAccountDict
{
    if (!mAccountDict) {
        NSDictionary* aAccountDict = (NSDictionary*)[self readInfoForKey:RegKey_AccountDict encryptString:nil];
        if (aAccountDict) {
            mAccountDict = [[NSMutableDictionary alloc] initWithDictionary:aAccountDict];
        }
        else
        {
            mAccountDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
    }
}

-(NSDictionary*)readAccountDict
{
    NSDictionary* dict = [NSDictionary dictionaryWithDictionary:mAccountDict];
    return dict;
}

-(void)saveAccountDictValue:(NSString*)uid forKey:(NSString*)accountName
{
    [self initAccountDict];
    if (uid&&accountName) 
    {
        NSString* oldUID = [mAccountDict objectForKey:accountName];
        if (![oldUID isEqualToString:uid]) {
            [mAccountDict setObject:uid forKey:accountName];
            [self saveInfoValue:mAccountDict forKey:RegKey_AccountDict encryptString:nil];
        }
        
    }
    else
    {
        NSLog(@"saveAccountDictValue not right params!");
    }
    
}
-(void)removeAccountDictValueforkey:(NSString*)accountName
{
    [mAccountDict removeObjectForKey:accountName];

    [self saveInfoValue:mAccountDict forKey:RegKey_AccountDict encryptString:nil];

}
-(void)saveSystemInfoValue:(id)data forKey:(NSString*)oneKey encryptString:(BOOL)bEncrypt
{
    if (data&&oneKey) {
        NSString* newKey = [NSString stringWithFormat:@"%@%@",RegKey_SYSTEMINFO,oneKey];
        NSString* bEncryptStr = bEncrypt ? (RegKey_SYSTEMINFO) : nil;
        [self saveInfoValue:data forKey:newKey encryptString:bEncryptStr];
    }
    else if(oneKey)
    {
        NSString* newKey = [NSString stringWithFormat:@"%@%@",RegKey_SYSTEMINFO,oneKey];
        [self saveInfoValue:data forKey:newKey encryptString:nil];
    }
    else
    {
        NSLog(@"saveSystemInfoValue not right params!");
    }
}
-(void)removeSystemInfoValueforkey:(NSString*)oneKey
{
    NSString* newKey = [NSString stringWithFormat:@"%@%@",RegKey_SYSTEMINFO,oneKey];
    [self saveInfoValue:nil forKey:newKey encryptString:nil];
}
-(id)readSystemInfoForKey:(NSString*)oneKey
{
    if (oneKey) {
        NSString* newKey = [NSString stringWithFormat:@"%@%@",RegKey_SYSTEMINFO,oneKey];
        return [self readInfoForKey:newKey encryptString:RegKey_SYSTEMINFO];
    }
    else
    {
        NSLog(@"readSystemInfoForKey not right params!");
        return nil;
    }
}

-(void)saveUserInfoValue:(id)data forKey:(NSString*)oneKey userID:(NSString*)mid encryptString:(BOOL)bEncrypt
{
    if (data&&oneKey) {
        if (!mid) {
            if (mCurrrentUserID) {
                mid = mCurrrentUserID;
            }
            else
            {
               mid = @"defaultaccount"; 
            }
        }
        NSString* newKey = [NSString stringWithFormat:@"[%@]%@",mid,oneKey];
        NSString* bEncryptStr = bEncrypt ? (mid) : nil;
        [self saveInfoValue:data forKey:newKey encryptString:bEncryptStr];
    }
    else if(oneKey)
    {
        NSString* newKey = [NSString stringWithFormat:@"[%@]%@",mid,oneKey];
        [self saveInfoValue:data forKey:newKey encryptString:nil];
    }
    else
    {
        NSLog(@"saveUserInfoValue not right params!");
    }
}
-(void)removeUserInfoValueforKey:(NSString*)oneKey userID:(NSString*)mid 
{
    NSString* newKey = [NSString stringWithFormat:@"[%@]%@",mid,oneKey];
    [self saveInfoValue:nil forKey:newKey encryptString:nil];
}
-(id)readUserInfoForKey:(NSString*)oneKey userID:(NSString*)mid
{
    if (oneKey) {
        if (!mid) {
            if (mCurrrentUserID) {
                mid = mCurrrentUserID;
            }
            else
            {
                mid = @"defaultaccount"; 
            }
        }
        NSString* newKey = [NSString stringWithFormat:@"[%@]%@",mid,oneKey];
        return [self readInfoForKey:newKey encryptString:mid];
    }
    else
    {
        NSLog(@"readUserInfoForKey not right params!");
        return nil;
    }
}

-(void)saveInfoValue:(id)data forKey:(NSString*)oneKey encryptString:(NSString*)bEncryptStr
{
    if (data) {
        if (bEncryptStr) {
            if([data isKindOfClass:[NSDictionary class]])
            {
                data = [self revertDictToEncryptDict:(NSDictionary*)data encryptString:bEncryptStr];
            }
            else if([data isKindOfClass:[NSArray class]])
            {
                data = [self revertArrayToEncryptArray:(NSArray*)data encryptString:bEncryptStr];
            }
            else if([data isKindOfClass:[NSString class]])
            {
                data = [self encryptStringValue:(NSString*)data encryptString:bEncryptStr];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:oneKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:oneKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(NSMutableDictionary*)revertDictToEncryptDict:(NSDictionary*)dict encryptString:(NSString*)bEncryptStr
{
    NSMutableDictionary* tempDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSArray* keyArray = [dict allKeys];
    int keyCount = [keyArray count];
    for (int i=0; i<keyCount; i++) {
        NSString* tempKey = [keyArray objectAtIndex:i];
        id tempValue = [dict objectForKey:tempKey];
        if ([tempValue isKindOfClass:[NSString class]]) {
            tempValue = [self encryptStringValue:(NSString*)tempValue encryptString:bEncryptStr];
        }
        else if([tempValue isKindOfClass:[NSDictionary class]])
        {
            tempValue = [self revertDictToEncryptDict:(NSDictionary*)tempValue encryptString:bEncryptStr];
        }
        else if([tempValue isKindOfClass:[NSArray class]])
        {
            tempValue = [self revertArrayToEncryptArray:(NSArray*)tempValue encryptString:bEncryptStr];
        }
        [tempDict setObject:tempValue forKey:tempKey];
    }
    return tempDict;
}

-(NSMutableArray*)revertArrayToEncryptArray:(NSArray*)array encryptString:(NSString*)bEncryptStr
{
    NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity:0];
    int arrayCount = [array count];
    for (int i=0; i<arrayCount; i++) 
    {
        id tempValue = [array objectAtIndex:i];
        if([tempValue isKindOfClass:[NSDictionary class]])
        {
            tempValue = [self revertDictToEncryptDict:(NSDictionary*)tempValue encryptString:bEncryptStr];
        }
        else if([tempValue isKindOfClass:[NSArray class]])
        {
            tempValue = [self revertArrayToEncryptArray:(NSArray*)tempValue encryptString:bEncryptStr];
        }
        else if([tempValue isKindOfClass:[NSString class]])
        {
            tempValue = [self encryptStringValue:(NSString*)tempValue encryptString:bEncryptStr];
        }
        [tempArray addObject:tempValue];
    }
    return tempArray;
}

-(id)readInfoForKey:(NSString*)oneKey encryptString:(NSString*)bEncryptStr
{
    id rtval = nil;
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:oneKey];
    if (!rtval&&data) {
        if([data isKindOfClass:[NSDictionary class]])
        {
            rtval = [self revertDictToDecryptDict:(NSDictionary*)data encryptString:bEncryptStr];
        }
        else if([data isKindOfClass:[NSArray class]])
        {
            rtval = [self revertArrayToDecryptArray:(NSArray*)data encryptString:bEncryptStr];
        }
        else if([data isKindOfClass:[NSString class]])
        {
            rtval = [self decryptStringValue:(NSString*)data encryptString:bEncryptStr];
        }
        else
            rtval = data;
    }
    return rtval;
}

-(NSMutableDictionary*)revertDictToDecryptDict:(NSDictionary*)dict encryptString:(NSString*)bEncryptStr
{
    NSMutableDictionary* tempDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSArray* keyArray = [dict allKeys];
    int keyCount = [keyArray count];
    for (int i=0; i<keyCount; i++) {
        NSString* tempKey = [keyArray objectAtIndex:i];
        id tempValue = [dict objectForKey:tempKey];
        if ([tempValue isKindOfClass:[NSString class]]) {
            tempValue = [self decryptStringValue:(NSString*)tempValue encryptString:bEncryptStr];
        }
        else if([tempValue isKindOfClass:[NSDictionary class]])
        {
            tempValue = [self revertDictToDecryptDict:(NSDictionary*)tempValue encryptString:bEncryptStr];
        }
        else if([tempValue isKindOfClass:[NSArray class]])
        {
            tempValue = [self revertArrayToDecryptArray:(NSArray*)tempValue encryptString:bEncryptStr];
        }
        [tempDict setObject:tempValue forKey:tempKey];
    }
    return tempDict;
}

-(NSMutableArray*)revertArrayToDecryptArray:(NSArray*)array encryptString:(NSString*)bEncryptStr
{
    NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity:0];
    int arrayCount = [array count];
    for (int i=0; i<arrayCount; i++) 
    {
        id tempValue = [array objectAtIndex:i];
        if([tempValue isKindOfClass:[NSDictionary class]])
        {
            tempValue = [self revertDictToDecryptDict:(NSDictionary*)tempValue encryptString:bEncryptStr];
        }
        else if([tempValue isKindOfClass:[NSArray class]])
        {
            tempValue = [self revertArrayToDecryptArray:(NSArray*)tempValue encryptString:bEncryptStr];
        }
        else if([tempValue isKindOfClass:[NSString class]])
        {
            tempValue = [self decryptStringValue:(NSString*)tempValue encryptString:bEncryptStr];
        }
        [tempArray addObject:tempValue];
    }
    return tempArray;
}

-(NSString*)encryptStringValue:(NSString*)sourceString encryptString:(NSString*)bEncryptStr
{
    NSString* rtval = sourceString;
    if (bEncryptStr) {
        NSString* tempValue = [bEncryptStr stringByAppendingString:sourceString];
        tempValue = [MyTool encryptPwd:tempValue];
        rtval = [Encrypt_Header stringByAppendingString:tempValue];
    }
    return rtval;
}

-(NSString*)decryptStringValue:(NSString*)sourceString encryptString:(NSString*)bEncryptStr
{
    NSString* rtval = sourceString;
    if (bEncryptStr&&[sourceString hasPrefix:Encrypt_Header]) {
        NSString* tempString = [self subStringOfString:sourceString removePrefixString:Encrypt_Header];
        tempString = [MyTool decryptPwd:tempString];
        rtval = [self subStringOfString:tempString removePrefixString:bEncryptStr];
    }
    return rtval;
}

-(NSString*)subStringOfString:(NSString*)sourceString removePrefixString:(NSString*)prefix
{
    NSString* rtval = nil;
    if (sourceString&&prefix) {
        if ([sourceString hasPrefix:prefix]) {
            rtval = [sourceString substringFromIndex:[prefix length]];
        }
    }
    else
    {
        NSLog(@"subStringOfString removePrefixString not right params!");
    }
    return rtval;
}

-(NSString*)findUIDFromAccount:(NSString*)accountName
{
    if (accountName) {
        return [mAccountDict objectForKey:accountName];
    }
    else
        return nil;
}


//User Name Remember for easier login
-(void)saveUserName:(NSString*)accountName
{
    if(accountName.length <= 0)
        return;
        
    NSUserDefaults* saver = [NSUserDefaults standardUserDefaults];
    [saver removeObjectForKey:kSaved_User_Name];
    [saver setObject:accountName forKey:kSaved_User_Name];
}

-(NSString*)getSavedUserName
{
    NSUserDefaults* saver = [NSUserDefaults standardUserDefaults];
    NSString* name = (NSString*)[saver objectForKey:kSaved_User_Name];
    return name;
}

@end

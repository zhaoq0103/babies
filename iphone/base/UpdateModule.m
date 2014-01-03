//
//  UpdateModule.m
//  SinaFinance
//
//  Created by shieh exbice on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UpdateModule.h"
#import "ASIFormDataRequest.h"
//#import "JSONKit.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJSON.h"
#import "RegValueSaver.h"
#import "UIDevice-Hardware.h"
#import "MyTool.h"

#define LastTipUpdateVersion @"LastTipUpdateVersion"
#define RunningVersionKey @"RunningVersionKey"

@interface UpdateModule()
-(void)startupCheckUpdateTimer;
-(void)updatefinished:(ASIHTTPRequest*)request;
-(void)updateFailed:(ASIHTTPRequest*)request;
-(void)updateChecked:(NSNotification*)notify;
-(BOOL)hasNewVersion:(NSString*)version;
-(void)mainThreadRunningNotification:(NSDictionary*)argInfo;
@end

@implementation UpdateModule
{
    NSTimer* timer;
}
@synthesize updateDomain;

+ (id)getInstance
{
    static UpdateModule* s_instance = nil;
	if (s_instance == nil)
	{
		//没有创建则创建
		s_instance = [[UpdateModule alloc] init];
	}
	return s_instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self 
               selector:@selector(updateChecked:) 
                   name:UpdateCheckedNotification
                 object:nil];
    }
    return self;
}

-(void)dealloc
{
    [updateDomain release];
    [super dealloc];
}

-(void)startrequest
{
    [self startupCheckUpdateTimer];
}

-(void)stop
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

-(void)startupCheckUpdateTimer
{
    if (!timer) {
        [self performSelector:@selector(CheckUpdateTimer:)];
        timer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(CheckUpdateTimer:) userInfo:nil repeats:YES];
    }
}

-(void)CheckUpdateTimer:(NSTimer*)sender
{
    NSDictionary* oldVersion = [[RegValueSaver getInstance] readSystemInfoForKey:LastTipUpdateVersion];
    NSString* runningVer = [[RegValueSaver getInstance] readSystemInfoForKey:RunningVersionKey];
    if (oldVersion&&runningVer) {
        NSNumber* timeNumber = [oldVersion valueForKey:@"time"];
        NSTimeInterval curtime = [[NSDate date] timeIntervalSince1970];
        if (abs(curtime - [timeNumber doubleValue])>12*60*60) {
            [self startCheckUpdate:NO];
        }
    }
    else
    {
        [self startCheckUpdate:NO];
    }
}

-(void)startCheckUpdate:(BOOL)forceShow
{
    if (updateDomain) {
        NSString* updateURLString = updateDomain;
        NSString* macAdd = [[UIDevice currentDevice] macaddress];
        macAdd = [MyTool MD5DigestFromString:macAdd];
        updateURLString = [updateURLString stringByAppendingFormat:@"?guid=%@",macAdd];
        NSURL* url = [NSURL URLWithString:updateURLString];
        ASIFormDataRequest* request = [[[ASIFormDataRequest alloc] initWithURL :url] autorelease];
        NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:forceShow],@"forceShow",nil];
        request.userInfo = userInfo;
        [userInfo release];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(updateFailed:)];
        [request setDidFinishSelector:@selector(updatefinished:)];
        [request startAsynchronous];
    }
    
}

-(void)updateFailed:(ASIHTTPRequest*)request
{
    NSDictionary* userInfo = request.userInfo;
    NSLog(@"updateFailed=%@,\nupdateFailedString=%@",[request.error description],request.responseString);
    NSNumber* forceShowNumber = [userInfo valueForKey:@"forceShow"];
    BOOL forceShow = [forceShowNumber boolValue];
    if (forceShow) {
        NSString* errorTitle = nil;
        errorTitle = @"网络出错!";
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" 
                                                      message:errorTitle 
                                                     delegate:self
                                            cancelButtonTitle:@"确定"  
                                            otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(void)updatefinished:(ASIHTTPRequest*)request
{
    NSString* resultString = request.responseString;
    NSDictionary* userInfo = request.userInfo;
    NSNumber* forceShowNumber = [userInfo valueForKey:@"forceShow"];
//    BOOL forceShow = [forceShowNumber boolValue];
    NSDictionary* jsonDict = [resultString JSONValue];
    if(jsonDict!=nil&&[jsonDict isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
        [notifyDict setObject:UpdateCheckedNotification forKey:@"postNotificationName"];
        
        NSMutableDictionary* notifyUserDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [notifyUserDict addEntriesFromDictionary:jsonDict];
        [notifyUserDict setValue:forceShowNumber forKey:@"forceShow"];
        NSTimeInterval timeLength = [[NSDate date] timeIntervalSince1970];
        [notifyUserDict setValue:[NSNumber numberWithDouble:timeLength] forKey:@"time"];
        
        [notifyDict setObject:notifyUserDict forKey:@"userInfo"];
        [notifyUserDict release];
        
        [self performSelectorOnMainThread:@selector(mainThreadRunningNotification:) withObject:notifyDict waitUntilDone:NO];
    }
    else
    {
        [self updateFailed:request];
    }
}

-(void)updateChecked:(NSNotification*)notify
{
    NSDictionary* info = [notify userInfo];
    NSString* version = [info objectForKey:@"version"];
//    NSString* client = [info objectForKey:@"client"];
    int isForce = [(NSNumber*)[info objectForKey:@"isForce"] intValue];
//    NSString* lastVersionUrl = [info objectForKey:@"url"];
    NSNumber* forceShowNumber = [info valueForKey:@"forceShow"];
    BOOL forceShow = [forceShowNumber boolValue];
    NSString* bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    BOOL ingoreVersion = NO;
    if (!forceShow) {
        NSDictionary* oldVersion = [[RegValueSaver getInstance] readSystemInfoForKey:LastTipUpdateVersion];
        NSString* runningVer = [[RegValueSaver getInstance] readSystemInfoForKey:RunningVersionKey];
        if (runningVer&&[bundleVersion isEqualToString:runningVer]) {
            if (oldVersion) {
                NSString* lastUpdateVersion = [oldVersion valueForKey:@"version"];
                if ([lastUpdateVersion isEqualToString:version]) {
                    ingoreVersion = YES;
                }
            }
        }
    }
    
    int showType = -1;
    if (!ingoreVersion) {
        BOOL newversion = [self hasNewVersion:version];
        if(newversion) 
        {
            if (!isForce) {
                showType = 1;
            }
            else
            {
                showType = 2;
            }
        }
        else if(forceShow)
        {
            showType = 0;
        }
    }
    
    NSString* errorTitle = nil;
    if (showType==2) {
        errorTitle = @"您必须要更新到最新版本才能继续使用!";
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" 
                                                      message:errorTitle 
                                                     delegate:self
                                            cancelButtonTitle:@"确定"  
                                            otherButtonTitles:nil];
        alert.tag = 122299;
        [alert show];
        [alert release];
    }
    else if(showType==1)
    {
        errorTitle = [NSString stringWithFormat:@"发现有新版本%@,您需要更新到此版本吗?",version];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"更新提示" 
                                                      message:errorTitle 
                                                     delegate:self
                                            cancelButtonTitle:@"跳过"  
                                            otherButtonTitles:@"确定",nil];
        alert.tag = 1117657;
        [alert show];
        [alert release];
    }
    else if(showType==0)
    {
        errorTitle = @"您目前使用的已是最新版本!";
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"更新提示" 
                                                      message:errorTitle 
                                                     delegate:self
                                            cancelButtonTitle:@"确定"  
                                            otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [[RegValueSaver getInstance] saveSystemInfoValue:info forKey:LastTipUpdateVersion encryptString:NO];
    [[RegValueSaver getInstance] saveSystemInfoValue:bundleVersion forKey:RunningVersionKey encryptString:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    BOOL needUpdate = NO;
    if (alertView.tag==1117657) {
        if (buttonIndex == 1){
            needUpdate = YES;
            [self performSelector:@selector(gotoAppStore) withObject:nil afterDelay:0.3];
        }
    }
    else if(alertView.tag==122299)
    {
        needUpdate = YES;
        [[RegValueSaver getInstance] saveSystemInfoValue:nil forKey:RunningVersionKey encryptString:NO];
        [self performSelector:@selector(gotoAppStore)];
        NSString* errorTitle = @"您必须要更新到最新版本才能继续使用!";
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"更新提示" 
                                                      message:errorTitle 
                                                     delegate:self
                                            cancelButtonTitle:@"确定"  
                                            otherButtonTitles:nil];
        alert.tag = 122299;
        [alert show];
        [alert release];
    }
}

-(void)gotoAppStore
{
    NSDictionary* info = [[RegValueSaver getInstance] readSystemInfoForKey:LastTipUpdateVersion];
    NSString* lastVersionUrl = [info objectForKey:@"url"];
    NSRange seperatorRange = [lastVersionUrl rangeOfString:@"//"];
    if (seperatorRange.location!=NSNotFound) {
        lastVersionUrl = [lastVersionUrl substringFromIndex:seperatorRange.location+seperatorRange.length];
    }
    lastVersionUrl = [NSString stringWithFormat:@"%@%@",@"itms-apps://",lastVersionUrl];
    NSURL* url = [NSURL URLWithString:lastVersionUrl];
    [[UIApplication sharedApplication] openURL:url];
}

-(BOOL)hasNewVersion:(NSString*)version
{
    BOOL rtval = NO;
    NSString* bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* appVersion = [NSString stringWithFormat:@"%@",bundleVersion];
    NSArray* newVersionList = [version componentsSeparatedByString:@"."];
    NSArray* oldVersionList = [appVersion componentsSeparatedByString:@"."];
    int oldVerLen = [oldVersionList count];
    int newVerLen = [newVersionList count];
    int minVerLen = newVerLen>oldVerLen?oldVerLen:newVerLen;
    for (int i=0; i<minVerLen; i++) {
        NSString* versionNumOld = [oldVersionList objectAtIndex:i];
        NSString* versionNumNew = [newVersionList objectAtIndex:i];
        if ([versionNumOld intValue]<[versionNumNew intValue]) {
            rtval = YES;
        }
        if ([versionNumOld intValue]!=[versionNumNew intValue]) {
            break;
        }
    }
    return rtval;
}

-(void)mainThreadRunningNotification:(NSDictionary*)argInfo
{
    NSString* notifyName = [argInfo objectForKey:@"postNotificationName"];
    id object = [argInfo objectForKey:@"object"];
    NSDictionary* userInfo = [argInfo objectForKey:@"userInfo"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:object userInfo:userInfo];
}
@end

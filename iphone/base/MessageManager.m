//
//  MessageManager.m
//  SinaNews
//
//  Created by shieh fabo on 11-9-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MessageManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "MyTool.h"
#import "defines.h"
#import "RegValueSaver.h"
#import "DataBaseSaver.h"
#import "NSData+base64.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJSON.h"
#import "LKTipCenter.h"
#import "DataModel.h"

#import "CommentDataList.h"
#import "LKLoadingCenter.h"
#import "DataCenter.h"
#import "BCTabBarController.h"
#ifdef FIXFIX
#import "BabyAppDelegate.h"
#endif
#import <MapKit/MapKit.h>
#import "UIDevice-Hardware.h"
//#import "OfflineManager.h"

static MessageManager* s_messageManager = nil;

@interface MessageManager () 

@property(retain)NSMutableDictionary* obtainedWeibo; //NSMutableDictionary // NSMutableDictionary:main >>NSMutableArray:subid >> NSMutableDictionary :@"request" @"data" @"user_id"
@property(assign)NSInteger obtainedWeiboCount;
@property(retain)NSLock* lock;
@property(retain)NSDictionary* smallLoginData;
@property(retain)NSDictionary* smallOAuthData;
@property (retain)NSMutableArray* weiboRequestList;
@property (retain)NSString* loginedGroupID;

@property(nonatomic,retain)NSDictionary* loginData;
@property(nonatomic,retain)NSDictionary* oAuthData;
@property(nonatomic,retain)ASINetworkQueue* loginQueue;
@property(nonatomic,retain)ASINetworkQueue* downloadQueue;
@property(nonatomic,retain)ASINetworkQueue* otherQueue;
@property (nonatomic, retain)CLLocationManager* locManager;
@property (nonatomic, retain)CLLocation *myLocation;
@property (nonatomic, retain)MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, retain)MKPlacemark *locPlacemark;

@property (nonatomic, retain)NSMutableArray* emotionArray;

@property(nonatomic,retain)NSDictionary* tmploginData;

@property(nonatomic,retain)NSMutableData* remindData;

-(void)startRealLoginV1;
-(void)startRealLoginV2;
-(void)startRealSmallLoginV2;
-(void)restartHttpAPIRequst:(ASIFormDataRequest*)request;
-(void)failedHttpAPIRequst:(ASIFormDataRequest*)request;
-(void)clearLoginRequestQueue;
-(void)initalLoginQueue;
-(void)addRequestToLoginQueue:(ASIHTTPRequest*)request;
//-(void)initData;
-(void)initNotification;
-(void)startEmotionRequst;

-(NSMutableDictionary*)sourceAPIDictRetOrder:(NSMutableArray*)orderArray;
-(NSMutableDictionary*)rawAuthDictRetOrder:(NSMutableArray*)orderArray;
-(NSMutableDictionary*)rawAuth2DictRetOrder:(NSMutableArray*)orderArray loginDict:(NSDictionary*)loginDict;
-(NSString*)urlParmFormatFromDict:(NSDictionary*)dict order:(NSArray*)orderArray useEncode:(BOOL)encoded;
-(NSMutableArray*)baseStringArrayFromUrl:(NSString*)urlStr CoreString:(NSString*)baseStr;
-(NSString*)urlParmFormatFromArray:(NSArray*)array useEncode:(BOOL)encoded;
-(void)startLoginRequest:(NSDictionary*)dict order:(NSArray*)orderArray httpAPI:(NSString*)api stage:(NSInteger)stage;
-(void)startLoginV2Request:(NSDictionary*)dict order:(NSArray*)orderArray httpAPI:(NSString*)api stage:(NSInteger)stage;
//-(void)startV2ObtainWithSender:(id)sender page:(NSInteger)page withWeibo:(NSInteger)count singleUserID:(NSString*)user_id totalUserID:(NSString*)totalID maxID:(NSString*)maxID args:(NSArray*)args;
-(void)afterPublishWeiboSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request;
-(void)afterPublishWeiboFailed:(ASIHTTPRequest*)request;

-(void)clearLoginConnect;
-(void)afterLoginSuccessed:(NSInteger)stage;
- (void)requestFailed:(ASIHTTPRequest*)request;
- (void)afterFailed:(ASIHTTPRequest*)request;
-(void)afterLoginFailed;
-(void)afterPublishFailed;


-(void)startVerifier;
-(void)startVerifierRequest;
-(void)afterVerifierFailed;

-(NSMutableDictionary*)rawPublishDict:(NSString*)aStatus retOrder:(NSMutableArray*)orderArray;
-(NSMutableDictionary*)rawV2PublishWithRetOrder:(NSMutableArray*)orderArray status:(NSString*)aStatus;
-(void)clearRequestQueue;
-(void)initalDownloadQueue;
-(void)addRequestToDowloadQueue:(ASIHTTPRequest*)request;
-(void)addRequestToOfflineQueue:(ASIHTTPRequest*)request;
-(void)startHttpAPIRequest:(NSString*)method data:(NSDictionary*)dict order:(NSArray*)orderArray api:(NSString*)HttpAPI stage:(NSInteger)stageInteger userInfo:(NSDictionary*)userData bInback:(BOOL)bInback;
-(void)startHttpAPIRequestV2:(NSString*)method data:(NSDictionary*)dict order:(NSArray*)orderArray api:(NSString*)HttpAPI stage:(NSInteger)stageInteger userInfo:(NSDictionary*)userData headerDict:(NSDictionary*)headerDict needSmallLogin:(BOOL)needLogin bInback:(BOOL)bInback;
-(void)dictAddSignatureWithDict:(NSMutableDictionary*)dict order:(NSMutableArray*)orderArray api:(NSString*)requestAPI;

-(NSMutableDictionary*)rawObtainInfoDictRetOrder:(NSMutableArray*)orderArray;

-(void)startHttpAPIRequstByURL:(NSURL*)url headerDict:(NSDictionary*)headerDict userInfo:(NSDictionary*)info stage:(NSInteger)stageInt inBack:(BOOL)bInBack;
-(void)clearOhterRequestQueue;
-(void)initalOtherQueue;
-(void)addRequestToOhterQueue:(ASIHTTPRequest*)request;
-(void)ohterQueueComplete:(ASINetworkQueue *)queue;

//-(void)stopLocationUpdate;
//-(void)realStartReverse:(CGPoint)aPos;

-(NSString*)parseDateFromInformatDate:(NSString*)oldDateStr;


-(void)startAPIRequest:(id)sender withAPICode:(NSArray*)codeArray pagename:(NSString*)pageName pagevalue:(NSInteger)pageValue countname:(NSString*)countName countvalue:(NSInteger)countValue args:(NSArray*)args stage:(NSInteger)stage otherUserInfo:(NSDictionary*)oUserInfo headerInfo:(NSDictionary*)headerDict;
-(void)afterDefaultSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request dataname:(NSString*)dateName;
-(void)afterDefaultSuccessed:(NSArray*)resultArray userRequst:(ASIHTTPRequest*)request;
-(void)afterGetExpertMsgSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request;
-(void)afterGetExpertClassSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request;
-(void)afterExpertReplySuccessed:(NSDictionary*)jsonDict userReqeust:(ASIHTTPRequest*)request;
-(void)afterGetExpertbyGroupSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request;
-(void)afterGetSearchGroupSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request;
-(void)checkRefreshToken;
-(void)afterSearchCateIdSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request;
-(void)afteraddQuizeSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request;
-(void)afterRepostWeiboSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request;
-(void)afterRepostWeiboFailed:(ASIHTTPRequest*)request;
-(void)afterCommentWeiboSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request;
-(void)afterCommentWeiboFailed:(ASIHTTPRequest*)request;
-(void)afterAddFavoriteSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request;
-(void)afterSettingSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request;
-(void)afterAddFavoriteFailed:(ASIHTTPRequest*)request;
-(void)afterSettingFailed:(ASIHTTPRequest*)request;
-(void)afterGetNewRemindSucessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request;
-(void)afterGetNewRemindFailed:(ASIHTTPRequest*)request;

-(void)afterCommentListWeiboSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request;

-(void)afterCommentListWeiboFailed:(ASIHTTPRequest*)request;
-(void)afterGetExpertInfoSucessed:(NSDictionary*)jsonDict userRequest:(ASIHTTPRequest *)request;
-(void)afterSearchWordsSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request;
-(void)afterGetSettingInfoSucessed:(NSDictionary*)jsonDict userRequest:(ASIHTTPRequest *)request;
@end

@implementation MessageManager

@synthesize loginData = mLoginData,loginQueue = mLoginQueue,oAuthData = mOAuthData,downloadQueue = mDownloadQueue,otherQueue = mOtherQueue;
@synthesize locManager = mLocManager;
@synthesize myLocation,locPlacemark,reverseGeocoder;
@synthesize obtainedWeibo,obtainedWeiboCount;
@synthesize lock=mLock;
@synthesize smallLoginData,smallOAuthData;
@synthesize hasLogined;
@synthesize weiboRequestList=mWeiboRequestList;

@synthesize loginedGroupID;

@synthesize emotionArray;
@synthesize tmploginData;
@synthesize offlineDelegate;
+ (id)getInstance
{
	if (s_messageManager == nil)
	{
		//没有创建则创建
		s_messageManager = [[MessageManager alloc] init];
        
	}
	return s_messageManager;
}

- (id) init
{
	self = [super init];
	if (self != nil)
	{
        myLocationChanged = 0;
        mLock = [[NSLock alloc] init];
        
        _remindData = [[NSMutableData alloc] initWithCapacity:100];

        [self initNotification];
    }
    return self;
}


-(void)dealloc
{
    [self clearLoginConnect];
    [self clearRequestQueue];
    [self clearOhterRequestQueue];
    [mLoginData release];
    [mLoginQueue release];
    [mOAuthData release];
    [mDownloadQueue release];
    [smallLoginData release];
    [smallOAuthData release];
    
    [reverseGeocoder cancel];
    [reverseGeocoder release];
    reverseGeocoder = nil;
    [obtainedWeibo release];
    [mLock release];
    [mWeiboRequestList release];
    [loginedGroupID release];
    
    [emotionArray release];
    [tmploginData release];
    [_remindData release];
    [mSubjectID release];
    [super dealloc];
}

-(void)clear
{
    
}


-(void)initNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    //remind
    [nc addObserver:self 
           selector:@selector(NewRemendAddObjects:) 
               name:NewRemendNotification
             object:nil];
    
    [nc addObserver:self 
           selector:@selector(NewRemendFailedObjects:) 
               name:NewRemendFaildedNotification
             object:nil];
}

-(void)NewRemendAddObjects:(NSNotification*)notify
{
#ifdef FIXFIX
    NSDictionary* userInfo = [notify userInfo];
    NSNumber* count = [userInfo objectForKey:@"count"];
    
    BCTabBarController* tabBarController = [(BabyAppDelegate*)[[UIApplication sharedApplication] delegate] tabBarController];
    NSArray* tabArray =  tabBarController.tabBar.tabs;
    BCTab* tab = [tabArray objectAtIndex:3];
//    bubbleView
    int cint = [count intValue];
    if (cint > 0) {
        tab.bubbleView.hidden = NO;
        NSString* remCount = nil;
        if (cint > 99) {
            remCount = @"N";
        }
        else
        {
            remCount = [NSString stringWithFormat:@"%d", cint];
        }
        tab.bubbleContentLable.text = remCount;
    }
    else
    {
        tab.bubbleView.hidden = YES;
    }
#endif
}
-(void)NewRemendFailedObjects:(NSNotification*)notify
{
#ifdef FIXFIX
    BCTabBarController* tabBarController = [(BabyAppDelegate*)[[UIApplication sharedApplication] delegate] tabBarController];
    NSArray* tabArray =  tabBarController.tabBar.tabs;
    BCTab* tab = [tabArray objectAtIndex:3];
    tab.bubbleView.hidden = YES;
#endif
}
-(void)startAPIRequest:(id)sender withAPICode:(NSArray*)codeArray pagename:(NSString*)pageName pagevalue:(NSInteger)pageValue countname:(NSString*)countName countvalue:(NSInteger)countValue args:(NSArray*)args stage:(NSInteger)stage otherUserInfo:(NSDictionary*)oUserInfo headerInfo:(NSDictionary*)headerDict
{
    if ([codeArray count]>0) {
        if (args) {
            args = [NSArray arrayWithArray:args];
        }
        NSString* urlStr = [codeArray objectAtIndex:0];
        if (pageName) {
            urlStr = [urlStr stringByAppendingFormat:@"&%@=%d",pageName,pageValue];
        }
        if (countName) {
            urlStr = [urlStr stringByAppendingFormat:@"&%@=%d",countName,countValue];
        }
        NSLog(@"url = %@", urlStr);
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableDictionary* dict1 = [NSMutableDictionary dictionaryWithCapacity:0];
        if (sender) {
            [dict1 setValue:sender forKey:RequsetSender];
        }
        [dict1 setValue:[NSDate date] forKey:RequsetDate];
        if (args) {
            [dict1 setObject:args forKey:RequsetArgs];
        }
        [dict1 setObject:[NSNumber numberWithInt:pageValue] forKey:RequsetPage];
        [dict1 addEntriesFromDictionary:oUserInfo];
        
        BOOL bBack = NO;
        /*
         if ([(NSNumber*)sender intValue]==(int)[OfflineManager getInstance]) {
         bBack = YES;
         }*/
        
        [self startHttpAPIRequstByURL:url headerDict:headerDict userInfo:dict1 stage:stage inBack:bBack];
    }
}


-(NSString*)loginedAccount
{
    NSString* rtval = nil;
    if (self.hasLogined) {
        rtval = [self.loginData objectForKey:Key_Login_Username];
    }
    return rtval;
}

-(NSString*)loginedID
{
    NSString* rtval = nil;
    if (self.hasLogined) {
        NSString* loginAccount = [self loginedAccount];
        rtval = [[RegValueSaver getInstance] findUIDFromAccount:loginAccount];
    }
    return rtval;
}


-(void)LoginSuccessed:(NSNotification*)notify
{
    NSNumber* stageNumber = [notify object];
    if([stageNumber intValue]==Stage_LoginV2_Small)
    {
        bSmallLogining = NO;
        int requestCount = [self.weiboRequestList count];
        if (self.weiboRequestList&&requestCount>0) {
            for (int i=requestCount-1;i>=0;i--) {
                ASIFormDataRequest* request = [self.weiboRequestList objectAtIndex:i];
                [self restartHttpAPIRequst:request];
                [self.weiboRequestList removeObject:request];
            }
        }
    }
    else
    {
        self.loginedGroupID = nil;
        NSString* tipString = nil;
        tipString = @"帐号登录成功了!";
        [[LKTipCenter defaultCenter] postTopTipWithMessage:tipString time:1.0 color:nil];
    }
}

-(void)LoginFailed:(NSNotification*)notify
{
    NSNumber* stageNumber = [notify object];
    if([stageNumber intValue]==Stage_LoginV2_Small)
    {
        bSmallLogining = NO;
        int requestCount = [self.weiboRequestList count];
        if (self.weiboRequestList&&requestCount>0) {
            for (int i=requestCount-1;i>=0;i--) {
                ASIFormDataRequest* request = [self.weiboRequestList objectAtIndex:i];
                [self failedHttpAPIRequst:request];
                [self.weiboRequestList removeObject:request];
            }
        }
    }
    else
    {
        NSString* tipString = nil;
        tipString = @"帐号登录失败了!";
        [[LKTipCenter defaultCenter] postTopTipWithMessage:tipString time:1.0 color:nil];
    }
}

-(void)LogoutSuccessed:(NSNotification*)notify
{
    self.loginedGroupID = nil;
    NSString* tipString = nil;
    tipString = @"帐号注销成功了!";
    [[LKTipCenter defaultCenter] postTopTipWithMessage:tipString time:1.0 color:nil];
}


-(void)restartHttpAPIRequst:(ASIFormDataRequest*)request
{
    NSString* method = request.requestMethod;
    if ([method.uppercaseString isEqualToString:@"POST"]) {
        NSString* token = [self.smallOAuthData objectForKey:LoginReturnKeyV2_Token];
        [request setPostValue:token forKey:OAUTH2_TOKEN];
    }
    else
    {
        NSString* token = [self.smallOAuthData objectForKey:LoginReturnKeyV2_Token];
        NSString* urlString = [request.url absoluteString];
        if ([urlString rangeOfString:@"?"].location!=NSNotFound) {
            urlString = [urlString stringByAppendingFormat:@"&%@=%@",OAUTH2_TOKEN,token];
        }
        else
        {
            urlString = [urlString stringByAppendingFormat:@"?%@=%@",OAUTH2_TOKEN,token];
        }
        NSURL* url = [NSURL URLWithString:urlString];
        request.url = url;
    }
    [self addRequestToLoginQueue:request];
}

-(void)failedHttpAPIRequst:(ASIFormDataRequest*)request
{
    [self requestFailed:request];
}

-(void)startCheckUpdate:(BOOL)forceShow
{
    NSString* updateURLString = @"http://m.sina.com.cn/js/5/20120514/31.json";
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

-(void)updateFailed:(ASIHTTPRequest*)request
{
    NSDictionary* userInfo = request.userInfo;
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
        
        [notifyDict setObject:notifyUserDict forKey:@"userInfo"];
        [notifyUserDict release];
        
        [self postNotificationWithObject:notifyDict];
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
    
    BOOL ingoreVersion = NO;
    if (!forceShow) {
        NSDictionary* oldVersion = [[RegValueSaver getInstance] readSystemInfoForKey:LastTipUpdateVersion];
        if (oldVersion) {
            NSString* lastUpdateVersion = [oldVersion valueForKey:@"version"];
            if ([lastUpdateVersion isEqualToString:version]) {
                ingoreVersion = YES;
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
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" 
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
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" 
                                                      message:errorTitle 
                                                     delegate:self
                                            cancelButtonTitle:@"确定"  
                                            otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [[RegValueSaver getInstance] saveSystemInfoValue:info forKey:LastTipUpdateVersion encryptString:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    BOOL needUpdate = NO;
    if (alertView.tag==1117657) {
        if (buttonIndex == 1){
            needUpdate = YES;
        }
    }
    else if(alertView.tag==122299)
    {
        needUpdate = YES;
    }
    
    if (needUpdate) {
        NSDictionary* info = [[RegValueSaver getInstance] readSystemInfoForKey:LastTipUpdateVersion];
        NSString* lastVersionUrl = [info objectForKey:@"url"];
        NSURL* url = [NSURL URLWithString:lastVersionUrl];
        [[UIApplication sharedApplication] openURL:url];
    }
}

-(BOOL)hasNewVersion:(NSString*)version
{
    BOOL rtval = NO;
    NSString* bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* appVersion = [NSString stringWithFormat:@"%@",bundleVersion];
    NSArray* newVersionList = [version componentsSeparatedByString:@"."];
    NSArray* oldVersionList = [appVersion componentsSeparatedByString:@"."];
    int lengthVersion = [oldVersionList count];
    if ([newVersionList count]==lengthVersion) {
        for (int i=0; i<lengthVersion; i++) {
            NSString* versionNumOld = [oldVersionList objectAtIndex:i];
            NSString* versionNumNew = [newVersionList objectAtIndex:i];
            if ([versionNumOld intValue]<[versionNumNew intValue]) {
                rtval = YES;
            }
            if ([versionNumOld intValue]!=[versionNumNew intValue]) {
                break;
            }
        }
    }
    return rtval;
}

-(void)startLogin:(NSDictionary*)loginData
{
    if (loginData==nil) {
        NSString* userID = [[RegValueSaver getInstance] readSystemInfoForKey:RegKey_CurrentAccount];
        if (userID) 
        {
            self.loginData = [[RegValueSaver getInstance] readUserInfoForKey:RegKey_UserData_LoginDict userID:userID];
            self.oAuthData = [[RegValueSaver getInstance] readUserInfoForKey:RegKey_UserData_TokenDict userID:userID];
        }
        if (!self.oAuthData) 
        {
            if (self.loginData) 
            {
                [self startRealLoginV2];
            }
        }
        else
        {
            int handlesecond = (int)[[NSDate date] timeIntervalSince1970];
            NSString* ReqoAuthDataTime = [self.oAuthData objectForKey:@"ReqoAuthDataTime"];
            if (ReqoAuthDataTime) 
            {
                int ReqoAuthDataTimeint = [ReqoAuthDataTime intValue];
                if (handlesecond - ReqoAuthDataTimeint > TokenRefreshTime) 
                {
                    NSLog(@"loginData1 = %@", self.loginData);
                    if (self.loginData) 
                    {
                        NSLog(@"loginData = %@", self.loginData);
                        [self startRealLoginV2];
                    }
                }
            }
            
            [self afterLoginSuccessed:Stage_LoginV2];
        }
    }
    else
    {
        if (loginData&&[loginData count]>0) {
            self.loginData = loginData;
            [self startRealLoginV2];
        }
    }
    
}
-(void)startRealLogin:(NSDictionary *)loginData
{
    if (loginData) 
    {    
        self.tmploginData = loginData;
        NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary* dict = [self rawAuth2DictRetOrder:orderArray loginDict:loginData];
        [self startLoginV2Request:dict order:orderArray httpAPI:HttpAPIV2_Login stage:Stage_RealLoginV2];
    }
}
-(void)startLoginUid:(NSString*)userID
{
    self.loginData = [[RegValueSaver getInstance] readUserInfoForKey:RegKey_UserData_LoginDict userID:userID];
    self.oAuthData = [[RegValueSaver getInstance] readUserInfoForKey:RegKey_UserData_TokenDict userID:userID];
    if (!self.oAuthData) {
        if (self.loginData) {
            [self startRealLoginV2];
        }
    }
    else
    {
        int handlesecond = (int)[[NSDate date] timeIntervalSince1970];
        NSString* ReqoAuthDataTime = [self.oAuthData objectForKey:@"ReqoAuthDataTime"];
        if (ReqoAuthDataTime) 
        {
            int ReqoAuthDataTimeint = [ReqoAuthDataTime intValue];
            if (handlesecond - ReqoAuthDataTimeint > TokenRefreshTime) 
            {
                if (self.loginData) 
                {
                    [self startRealLoginV2];
                }
            }
        }
        [self afterLoginSuccessed:Stage_LoginV2];
    }
}
-(void)startLogout
{
    self.hasLogined = NO;
    self.bAnExpertLogined = NO;
    self.loginData = nil;
    self.oAuthData = nil;
    [[RegValueSaver getInstance] saveSystemInfoValue:nil forKey:RegKey_CurrentAccount encryptString:NO];
    
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:LogoutSuccessedNotification forKey:@"postNotificationName"];
    
    [self postNotificationWithObject:notifyDict];
}

-(void)startSmallLogin
{
    if (!self.smallOAuthData) {
        if (!smallLoginData) {
            smallLoginData = [[NSDictionary alloc] initWithObjectsAndKeys:@"xinlanguc5@sina.cn",Key_Login_Username,@"xinlanguc5!@#",Key_Login_Password, nil];
        }
        NSString* userName = [self.smallLoginData objectForKey:Key_Login_Username];
        NSString* userID = [[RegValueSaver getInstance] findUIDFromAccount:userName];
        if (userID) {
            self.smallOAuthData = [[RegValueSaver getInstance] readUserInfoForKey:RegKey_UserData_TokenDict userID:userID];
        }
    }
    
    if (!self.smallOAuthData) {
        [self startRealSmallLoginV2];
    }
    else
    {
        [self afterLoginSuccessed:Stage_LoginV2_Small];
    }
}

-(void)startRealLoginV1
{
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [self rawAuthDictRetOrder:orderArray];
    NSString* str1 = [self urlParmFormatFromDict:dict order:orderArray useEncode:YES];
    NSMutableArray* array = [self baseStringArrayFromUrl:HttpAPI_Login CoreString:str1];
    NSString* baseString = [self urlParmFormatFromArray:array useEncode:YES];
    NSString* signature = [MyTool HMAC_SHA1:Login_HMACSHA1KEY text:baseString];
    [dict setObject:signature forKey:OAUTH_SIGNATURE];
    [orderArray addObject:OAUTH_SIGNATURE];
    [self startLoginRequest:dict order:orderArray httpAPI:HttpAPI_Login stage:Stage_Login];
}

-(void)startRealLoginV2
{
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [self rawAuth2DictRetOrder:orderArray loginDict:self.loginData];
    [self startLoginV2Request:dict order:orderArray httpAPI:HttpAPIV2_Login stage:Stage_LoginV2];
}

-(void)startRealSmallLoginV2
{
    if (!bSmallLogining) {
        bSmallLogining = YES;
        if (!self.smallOAuthData) {
            if (!smallLoginData) {
                smallLoginData = [[NSDictionary alloc] initWithObjectsAndKeys:@"xinlanguc3@sina.cn",Key_Login_Username,@"xinlanguc3!@#",Key_Login_Password, nil];
            }
        }
        NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary* dict = [self rawAuth2DictRetOrder:orderArray loginDict:self.smallLoginData];
        [self startLoginV2Request:dict order:orderArray httpAPI:HttpAPIV2_Login stage:Stage_LoginV2_Small];
    }
}

-(NSMutableDictionary*)sourceAPIDictRetOrder:(NSMutableArray*)orderArray
{
    [orderArray removeAllObjects];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:Login_APPVALUE forKey:OAUTH_CONSUMER_KEY];
    [orderArray addObject:OAUTH_CONSUMER_KEY];
    [dict setObject:[MyTool MD5RandomString] forKey:OAUTH_NONCE];
    [orderArray addObject:OAUTH_NONCE];
    [dict setObject:Login_HMACSHA1TYPE forKey:OAUTH_SIGNATURE_METHOD];
    [orderArray addObject:OAUTH_SIGNATURE_METHOD];
    NSDate* curDate = [NSDate date];
    NSString* curDateStr = [NSString stringWithFormat:@"%qi",(long long)[curDate timeIntervalSince1970]];
    [dict setObject:curDateStr forKey:OAUTH_TIMESTAMP];
    [orderArray addObject:OAUTH_TIMESTAMP];
    [dict setObject:@"1.0a" forKey:OAUTH_VERSION];
    [orderArray addObject:OAUTH_VERSION];
    return dict;
}

-(NSMutableDictionary*)rawAuthDictRetOrder:(NSMutableArray*)orderArray
{
    NSMutableDictionary* dict = [self sourceAPIDictRetOrder:orderArray];
    [dict setObject:@"client_auth" forKey:X_AUTH_MODE];
    [orderArray addObject:X_AUTH_MODE];
    NSString* password = [self.loginData objectForKey:Key_Login_Password];
    [dict setObject:password forKey:X_AUTH_PASSWORD];
    [orderArray addObject:X_AUTH_PASSWORD];
    NSString* userName = [self.loginData objectForKey:Key_Login_Username];
    [dict setObject:userName forKey:X_AUTH_USERNAME];
    [orderArray addObject:X_AUTH_USERNAME];
    
    return dict;
}

-(NSMutableDictionary*)rawAuth2DictRetOrder:(NSMutableArray*)orderArray loginDict:(NSDictionary*)loginDict
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:Login_APPVALUE forKey:OAUTH2_Client_ID];
    [orderArray addObject:OAUTH2_Client_ID];
    [dict setObject:Login_APPSECRET forKey:OAUTH2_Client_Secret];
    [orderArray addObject:OAUTH2_Client_Secret];
    [dict setObject:@"password" forKey:OAUTH2_Grant_Type];
    [orderArray addObject:OAUTH2_Grant_Type];
    NSString* userName = [loginDict objectForKey:Key_Login_Username];
    [dict setObject:userName forKey:OAUTH2_Username];
    [orderArray addObject:OAUTH2_Username];
    NSString* password = [loginDict objectForKey:Key_Login_Password];
    [dict setObject:password forKey:OAUTH2_Password];
    [orderArray addObject:OAUTH2_Password];
    
    return dict;
}

-(NSString*)urlParmFormatFromDict:(NSDictionary*)dict order:(NSArray*)orderArray useEncode:(BOOL)encoded
{
    NSString* rtval = nil;
    if (dict) {
        rtval = @"";
        NSArray* keyArray = [dict allKeys];
        int keyCount = [keyArray count];
        if (orderArray) {
            keyCount = [orderArray count];
        }
        for (int i = 0; i<keyCount; i++) {
            if (![rtval isEqualToString:@""]) {
                rtval = [rtval stringByAppendingFormat:@"&"];
            }
            NSString* oneKey = nil;
            if (orderArray) {
                oneKey = [orderArray objectAtIndex:i];
            }
            else
            {
                oneKey = [keyArray objectAtIndex:i];
            }
            
            NSString* oneValue = [dict objectForKey:oneKey];
            if (oneValue) {
                if (encoded) {
                    rtval = [rtval stringByAppendingFormat:@"%@=%@",[oneKey rawUrlEncode],[oneValue rawUrlEncode]];
                }
                else
                {
                    rtval = [rtval stringByAppendingFormat:@"%@=%@",oneKey,oneValue];
                }
            }
        }
    }
    return rtval;
}

-(NSMutableArray*)baseStringArrayFromUrl:(NSString*)urlStr CoreString:(NSString*)baseStr
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    [array addObject:@"POST"];
    [array addObject:urlStr];
    [array addObject:baseStr];
    
    return array;
}

-(NSString*)urlParmFormatFromArray:(NSArray*)array useEncode:(BOOL)encoded
{
    NSString* rtval = nil;
    if (array) {
        rtval = @"";
        int arrayCount = [array count];
        for (int i = 0; i<arrayCount; i++) {
            if (![rtval isEqualToString:@""]) {
                rtval = [rtval stringByAppendingString:@"&"];
            }
            NSString* oneValue = [array objectAtIndex:i];
            if (encoded) {
                rtval = [rtval stringByAppendingString:[oneValue rawUrlEncode]];
            }
            else
            {
                rtval = [rtval stringByAppendingString:oneValue];
            }
        }
    }
    return rtval;
}

-(void)clearLoginConnect
{
    
}

-(void)startLoginRequest:(NSDictionary*)dict order:(NSArray*)orderArray httpAPI:(NSString*)api stage:(NSInteger)stage
{
    [self clearLoginConnect];
    NSString *urlStr = [NSString stringWithFormat:@"%@?%@",api,[self urlParmFormatFromDict:dict order:orderArray useEncode:YES]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL :url];
    request.tag = stage;
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request startAsynchronous];
    [request release];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginStageChangedNotification object:[NSNumber numberWithInt:stage] userInfo:nil];
}

-(void)startLoginV2Request:(NSDictionary*)dict order:(NSArray*)orderArray httpAPI:(NSString*)api stage:(NSInteger)stage
{
    NSString *urlStr = [NSString stringWithFormat:@"%@?%@",api,[self urlParmFormatFromDict:dict order:orderArray useEncode:YES]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL :url];
    request.tag = stage;
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginStageChangedNotification object:[NSNumber numberWithInt:stage] userInfo:nil];
    [self addRequestToLoginQueue:request];
    [request release];
}


-(void)clearLoginRequestQueue
{
    [mLoginQueue cancelAllOperations];
    self.loginQueue = nil;
}

-(void)initalLoginQueue
{
    if (!mLoginQueue) {
        mLoginQueue = [[ASINetworkQueue alloc] init];
        [mLoginQueue setShouldCancelAllRequestsOnFailure:NO];
        [mLoginQueue setDelegate:self];
        [mLoginQueue setRequestDidFinishSelector:@selector(queueComplete:)];
    }
}

-(void)addRequestToLoginQueue:(ASIHTTPRequest*)request
{
    [self initalLoginQueue];
    [self.loginQueue addOperation:request];
    [self.loginQueue go];
}

-(void)startVerifier
{
    [self startVerifierRequest];
}

-(void)startVerifierRequest
{
    [self clearLoginConnect];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[self.oAuthData objectForKey:LoginReturnKey_Token] forKey:OAUTH_TOKEN];
    NSString *urlStr = [NSString stringWithFormat:@"%@?%@",HttpAPI_Verifier,[self urlParmFormatFromDict:dict order:nil useEncode:YES]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL :url];
    request.tag = Stage_Verifier;
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request startAsynchronous];
    [request release];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginStageChangedNotification object:[NSNumber numberWithInt:Stage_Verifier] userInfo:nil];
}



-(void)startPublish:(NSString*)aStatus
{
    if (aStatus!=nil) {
        NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary* dict = [self rawPublishDict:aStatus retOrder:orderArray];
        [self dictAddSignatureWithDict:dict order:orderArray api:HttpAPI_Publish];
        [self startHttpAPIRequest:@"POST" data:dict order:orderArray api:HttpAPI_Publish stage:Stage_Request_Publish userInfo:nil  bInback:NO];
    }
}

-(NSMutableDictionary*)rawPublishDict:(NSString*)aStatus retOrder:(NSMutableArray*)orderArray
{
    NSMutableDictionary* dict = [self sourceAPIDictRetOrder:orderArray];
    
    NSString* token = [self.oAuthData objectForKey:LoginReturnKey_Token];
    [dict setObject:token forKey:OAUTH_TOKEN];
    NSInteger versionIndex = [orderArray indexOfObject:OAUTH_VERSION];
    [orderArray insertObject:OAUTH_TOKEN atIndex:versionIndex];
    [dict setObject:aStatus forKey:X_AUTH_STATUS];
    [orderArray addObject:X_AUTH_STATUS];
    return dict;
}

-(void)startPublishV2:(NSString*)aStatus picUrl:(NSString*)url
{
    if (aStatus!=nil) {
        NSString* httpAPI = HttpAPIV2_Publish;
        NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary* dict = [self rawV2PublishWithRetOrder:orderArray status:aStatus];

        NSRange range = [url rangeOfString:@"http"];
        if(url&& range.location != NSNotFound )
        {
            NSString* idKey = @"url";
            [dict setObject:url forKey:idKey];
            [orderArray addObject:idKey];
        }

        NSMutableDictionary* userdict = [NSMutableDictionary dictionaryWithCapacity:0];
        [userdict setValue:[NSDate date] forKey:RequsetDate];
        [self startHttpAPIRequestV2:@"POST" data:dict order:orderArray api:httpAPI stage:Stage_RequestV2_Publish userInfo:userdict headerDict:nil needSmallLogin:NO bInback:NO];
    }
}

-(NSMutableDictionary*)rawV2PublishWithRetOrder:(NSMutableArray*)orderArray status:(NSString*)aStatus
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [self checkRefreshToken];
    NSString* token = [self.oAuthData objectForKey:LoginReturnKeyV2_Token];
    if (token) 
    {
        
        [dict setObject:token forKey:OAUTH2_TOKEN];
        [orderArray addObject:OAUTH2_TOKEN];
    }
    //[dict setObject:Login_APPVALUE forKey:OAUTH2_Source];
    //[orderArray addObject:OAUTH2_Source];
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    if (uid) {
        NSString* idKey = @"uid";
        [dict setObject:uid forKey:idKey];
        [orderArray addObject:idKey];
    }
    if (aStatus) {
        NSString* idKey = @"status";
        [dict setObject:aStatus forKey:idKey];
        [orderArray addObject:idKey];
    }
    return dict;
}


-(void)afterPublishWeiboSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:NetworkPublishSuccessNotification forKey:@"postNotificationName"];
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    
    [self postNotificationWithObject:notifyDict];
}

-(void)afterPublishWeiboFailed:(ASIHTTPRequest*)request
{

    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:QuizeFaildedNotification forKey:@"postNotificationName"];
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    
    NSMutableDictionary* notifyUserDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString* errorString = request.responseString;
    NSDictionary* jsonValue = [errorString JSONValue];


    NSNumber* errorValue = [jsonValue valueForKey:@"error_code"];
    if (errorValue) {
        [notifyUserDict setValue:errorValue forKey:@"error_code"];
    }
    [notifyDict setObject:notifyUserDict forKey:@"userInfo"];
    
    [self postNotificationWithObject:notifyDict];
    
    [notifyUserDict release];
}

-(void)startHttpAPIRequest:(NSString*)method data:(NSDictionary*)dict order:(NSArray*)orderArray api:(NSString*)HttpAPI stage:(NSInteger)stageInteger userInfo:(NSDictionary*)userData bInback:(BOOL)bInback
{
    NSString *urlStr = HttpAPI;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest* request = [[[ASIFormDataRequest alloc] initWithURL :url] autorelease];
    request.tag = stageInteger;
    request.userInfo = userData;
    
    int keyCount = [orderArray count];
    for (int i = 0; i<keyCount; i++) {
        NSString* oneKey = [orderArray objectAtIndex:i];
        NSString* oneValue = [dict objectForKey:oneKey];
        if (oneValue) {
            [request setPostValue:oneValue forKey:oneKey];
        }
    }
    
    if ([[method uppercaseString] isEqualToString:@"POST"]) {
        [request setRequestMethod:@"POST"];
    }
    [request setDelegate:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginStageChangedNotification object:[NSNumber numberWithInt:stageInteger] userInfo:nil];
    if (!bInback) {
        [self addRequestToDowloadQueue:request];
    }
    else
    {
        [self addRequestToOfflineQueue:request];
    }
}

-(void)startHttpAPIRequestV2:(NSString*)method data:(NSDictionary*)dict order:(NSArray*)orderArray api:(NSString*)HttpAPI stage:(NSInteger)stageInteger userInfo:(NSDictionary*)userData headerDict:(NSDictionary*)headerDict needSmallLogin:(BOOL)needLogin bInback:(BOOL)bInback
{
    NSString *urlStr = nil;
    if ([[method uppercaseString] isEqualToString:@"POST"]) {
        urlStr = HttpAPI;
    }
    else
    {
        if (dict&&orderArray) {
            if ([HttpAPI rangeOfString:@"?"].location!=NSNotFound) {
                urlStr = [NSString stringWithFormat:@"%@&%@",HttpAPI,[self urlParmFormatFromDict:dict order:orderArray useEncode:YES]];
            }
            else
            {
                urlStr = [NSString stringWithFormat:@"%@?%@",HttpAPI,[self urlParmFormatFromDict:dict order:orderArray useEncode:YES]];
            }
            
        }
        else
        {
            urlStr = HttpAPI;
        }
    }
    NSLog(@"url = %@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
   
    ASIFormDataRequest* request = [[[ASIFormDataRequest alloc] initWithURL :url] autorelease];
    request.tag = stageInteger;
    request.userInfo = userData;
    if ([[method uppercaseString] isEqualToString:@"POST"]) {
        [request setRequestMethod:@"POST"];
        for (NSString* onekey in orderArray) {
            NSString* oneValue = [dict objectForKey:onekey];
            [request setPostValue:oneValue forKey:onekey];
        }
    }
    if (headerDict) {
        NSArray* headerKey = [headerDict allKeys];
        for (NSString* oneKey in headerKey) {
            NSString* oneValue = [headerDict valueForKey:oneKey];
            [request addRequestHeader:oneKey value:oneValue];
        }
    } 
    [request setDelegate:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginStageChangedNotification object:[NSNumber numberWithInt:stageInteger] userInfo:nil];
    
    BOOL needDown = NO;
    if (needLogin)
    {
        BOOL foundToken = NO;
        for (NSString* orderKey in orderArray)
        {
            if ([orderKey isEqualToString:OAUTH2_TOKEN])
            {
                foundToken = YES;
                break;
            }
        }
        
        if (!foundToken)
        {
            if (!self.weiboRequestList)
            {
                mWeiboRequestList = [[NSMutableArray alloc] initWithCapacity:0];
            }
            [self.weiboRequestList addObject:request];
            [self startRealSmallLoginV2];
        }
        else
        {
            needDown = YES;
        }
    }
    else
    {   
        needDown = YES;
    }
    if (needDown)
    {
        if (!bInback)
        {
            [self addRequestToDowloadQueue:request];
        }
        else
        {
            [self addRequestToOfflineQueue:request];
        }
    }
}

-(void)dictAddSignatureWithDict:(NSMutableDictionary*)dict order:(NSMutableArray*)orderArray api:(NSString*)requestAPI
{
    NSString* str1 = [self urlParmFormatFromDict:dict order:orderArray useEncode:YES];
    NSMutableArray* array = [self baseStringArrayFromUrl:requestAPI CoreString:str1];
    NSString* baseString = [self urlParmFormatFromArray:array useEncode:YES];
    NSString* sha1Key = [NSString stringWithFormat:@"%@&%@",Login_APPSECRET,[self.oAuthData objectForKey:LoginReturnKey_Token_secret]];
    NSString* signature = [MyTool HMAC_SHA1:sha1Key text:baseString];
    [dict setObject:signature forKey:OAUTH_SIGNATURE];
    [orderArray addObject:OAUTH_SIGNATURE];
}


-(NSMutableDictionary*)rawObtainInfoDictRetOrder:(NSMutableArray*)orderArray
{
    NSMutableDictionary* dict = [self sourceAPIDictRetOrder:orderArray];
    
    NSString* token = [self.oAuthData objectForKey:LoginReturnKey_Token];
    [dict setObject:token forKey:OAUTH_TOKEN];
    NSInteger versionIndex = [orderArray indexOfObject:OAUTH_VERSION];
    [orderArray insertObject:OAUTH_TOKEN atIndex:versionIndex];
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    [dict setObject:uid forKey:X_AUTH_UID];
    [orderArray addObject:X_AUTH_UID];
    
    return dict;
}



-(void)mainThreadRunningNotification:(NSDictionary*)argInfo
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString* notifyName = [argInfo objectForKey:@"postNotificationName"];
    id object = [argInfo objectForKey:@"object"];
    NSDictionary* userInfo = [argInfo objectForKey:@"userInfo"];
 
    [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:object userInfo:userInfo];
    [pool release];
}

-(void)clearRequestQueue
{
    [mDownloadQueue cancelAllOperations];
    self.downloadQueue = nil;
}

-(void)initalDownloadQueue
{
    if (!mDownloadQueue) {
        mDownloadQueue = [[ASINetworkQueue alloc] init];
        [mDownloadQueue setShouldCancelAllRequestsOnFailure:NO];
        [mDownloadQueue setDelegate:self];
        [mDownloadQueue setRequestDidFinishSelector:@selector(queueComplete:)];
    }
}

-(void)addRequestToDowloadQueue:(ASIHTTPRequest*)request
{
    [self initalDownloadQueue];
    [self.downloadQueue addOperation:request];
    [self.downloadQueue go];
}

#pragma mark - Http Request Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    //1. login about
    NSData *responseData = [request responseData];
    
    if (request.tag==Stage_Login||request.tag==Stage_LoginV2||request.tag==Stage_LoginV2_Small)
    {
        NSString* resultString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        BOOL bSuccessed = YES;
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
        if (request.tag==Stage_Login)
        {
            NSArray* paramsArray = [resultString componentsSeparatedByString:@"&"];
            if (paramsArray) {
                for (int i=0; i<[paramsArray count]; i++) {
                    NSString* tempParam = [paramsArray objectAtIndex:i];
                    NSArray* tempArray = [tempParam componentsSeparatedByString:@"="];
                    if (tempArray&&[tempArray count]==2) {
                        [dict setObject:[tempArray objectAtIndex:1] forKey:[tempArray objectAtIndex:0]];
                    }
                    else
                    {
                        bSuccessed = NO;
                        break;
                    }
                }
            }
            else
                bSuccessed = NO;
        }
        else{
            dict = [resultString JSONValue];
        }
        
        
        if (bSuccessed&&![dict objectForKey:@"error"]) {
            NSString* userID = [dict objectForKey:LoginReturnKey_User_id];
            if (request.tag==Stage_LoginV2_Small) {
                self.smallOAuthData = dict;
                if (userID) {
                    int handlesecond = (int)[[NSDate date] timeIntervalSince1970];
                    NSString* ReqoAuthDataTime = [NSString stringWithFormat:@"%d", handlesecond];
                    [dict setObject:ReqoAuthDataTime forKey:@"ReqoAuthDataTime"];
                    
                    NSString* accountName = [self.smallLoginData objectForKey:Key_Login_Username];
                    [[RegValueSaver getInstance] saveAccountDictValue:userID forKey:accountName];
                    [[RegValueSaver getInstance] saveUserInfoValue:dict forKey:RegKey_UserData_TokenDict userID:userID encryptString:YES];
                    [[RegValueSaver getInstance] saveUserInfoValue:self.loginData forKey:RegKey_UserData_LoginDict userID:userID encryptString:YES];
                }
            }
            else
            {
                self.oAuthData = dict;
                if (userID) {
                    int handlesecond = (int)[[NSDate date] timeIntervalSince1970];
                    NSString* ReqoAuthDataTime = [NSString stringWithFormat:@"%d", handlesecond];
                    [dict setObject:ReqoAuthDataTime forKey:@"ReqoAuthDataTime"];
                    
                    NSString* accountName = [self.loginData objectForKey:Key_Login_Username];
                    [[RegValueSaver getInstance] saveAccountDictValue:userID forKey:accountName];
                    [[RegValueSaver getInstance] saveSystemInfoValue:userID forKey:RegKey_CurrentAccount encryptString:NO];
                    [[RegValueSaver getInstance] saveUserInfoValue:dict forKey:RegKey_UserData_TokenDict userID:userID encryptString:YES];
                    [[RegValueSaver getInstance] saveUserInfoValue:self.loginData forKey:RegKey_UserData_LoginDict userID:userID encryptString:YES];
                }
            }
            
            [self afterLoginSuccessed:request.tag];
        }
        else
        {
            [self requestFailed:request];
        }
        
        [resultString release];
    }
    else if(request.tag == Stage_RealLoginV2)
    {
        NSString* resultString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        BOOL bSuccessed = YES;
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:1];
        
        dict = [resultString JSONValue];
        [resultString release];
        
        if (bSuccessed && ![dict objectForKey:@"error"])
        {
            NSString* userID = [dict objectForKey:LoginReturnKey_User_id];
            self.loginData = tmploginData;
            self.oAuthData = dict;
            if (userID)
            {
                int handlesecond = (int)[[NSDate date] timeIntervalSince1970];
                NSString* ReqoAuthDataTime = [NSString stringWithFormat:@"%d", handlesecond];
                [dict setObject:ReqoAuthDataTime forKey:@"ReqoAuthDataTime"];
                
                NSString* accountName = [self.loginData objectForKey:Key_Login_Username];
                [[RegValueSaver getInstance] saveAccountDictValue:userID forKey:accountName];
                [[RegValueSaver getInstance] saveSystemInfoValue:userID forKey:RegKey_CurrentAccount encryptString:NO];
                [[RegValueSaver getInstance] saveUserInfoValue:dict forKey:RegKey_UserData_TokenDict userID:userID encryptString:YES];
                [[RegValueSaver getInstance] saveUserInfoValue:self.loginData forKey:RegKey_UserData_LoginDict userID:userID encryptString:YES];
                
                [[RegValueSaver getInstance] saveUserName:accountName];
            }
            
            [self afterLoginSuccessed:request.tag];
        }
        else
        {
            [self requestFailed:request];
        }
    }
    else if(request.tag==Stage_Verifier)
    {
    }
    else if(request.tag==Stage_Request_Publish||request.tag==Stage_RequestV2_Publish)
    {
        NSString* resultString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary* jsonDict = [resultString JSONValue];
        if (jsonDict&&[jsonDict isKindOfClass:[NSDictionary class]]) {
            NSString* errorStr = [jsonDict objectForKey:@"error"];
            if (!errorStr) {
                [self afterPublishWeiboSuccessed:jsonDict userRequst:request];
            }
            else
            {
                [self requestFailed:request];
            }
        }
        else
        {
            [self requestFailed:request];
        }
        [resultString release];
    }
    else if(request.tag==Stage_RequestV2_RepostWeibo)
    {
        NSString* resultString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [resultString JSONValue];
        if (jsonDict&&[jsonDict isKindOfClass:[NSDictionary class]]) {
            [self afterRepostWeiboSuccessed:jsonDict userRequst:request];
        }
        else
        {
            [self requestFailed:request];
        }
        [resultString release];
    }
    else if(request.tag==Stage_RequestV2_CommentWeibo)
    {
        NSString* resultString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [resultString JSONValue];
        if (jsonDict&&[jsonDict isKindOfClass:[NSDictionary class]]) {
            [self afterCommentWeiboSuccessed:jsonDict userRequst:request];
        }
        else
        {
            [self requestFailed:request];
        }
        [resultString release];
    }
    else if(request.tag==Stage_RequestV2_CommentListWeibo)
    {
        NSString* resultString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [resultString JSONValue];
        
        if (jsonDict&&[jsonDict isKindOfClass:[NSDictionary class]]) {
            [self afterCommentListWeiboSuccessed:jsonDict userRequst:request];
        }
        else
        {
            [self requestFailed:request];
        }
        [resultString release];
    }
    else if(request.tag ==  STage_UserInfo)
    {
        NSString* resultString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [resultString JSONValue];
        
        if (jsonDict&&[jsonDict isKindOfClass:[NSDictionary class]])
        {
            NSString* urlString = [jsonDict valueForKey:@"profile_image_url"];
            NSString* screenName = [jsonDict valueForKey:@"screen_name"];
            //save
            [[RegValueSaver getInstance] saveAccountDictValue:urlString forKey:@"profile_image_url"];
            [[RegValueSaver getInstance] saveAccountDictValue:screenName forKey:@"screen_name"];
            
            DataModel* userDict = [DataModel objectWithJsonDict:jsonDict];
            [self getUserInfoSuccessed :userDict];
        }
        else
        {
            [self requestFailed:request];
        }
        [resultString release];
    }
    else
    {
        //2. other
        NSDictionary* dic = [self isResultSuccessedOfHttpRequest:request];
        if (dic == nil) {
            return; //fail
        }
        if (request.tag == STage_QuestionNeedsReply) {
            [self afterGetQuestionsNeedReplySuccessed:dic userRequest:request];
        }
        else if (request.tag == STage_ExpertReplyQ) {
//            NSString* resultString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//            NSLog(@"replay successed");
            [self afterExpertReplySuccessed:dic userReqeust:request];
        }
        else if(request.tag==Stage_ExpertMsg)
        {
            [self afterGetExpertMsgSucessed:dic userRequest:request];
        }
        else if(request.tag==Stage_ExpertMsg_Active)
        {
            [self afterGetActiveExpertMsgSucessed:dic userRequest:request];
        }
        else if(request.tag==Stage_ExpertClass)
        {
            [self afterGetExpertClassSucessed:dic userRequest:request];
        }
        else if(request.tag==Stage_ExpertbyGroup)
        {
            [self afterGetExpertbyGroupSucessed:dic userRequest:request];
        }
        else if(request.tag==Stage_SearchGroup)
        {
            [self afterGetSearchGroupSucessed:dic userRequest:request];
        }
        else if(request.tag == Stage_GetHotwordsTop)
        {
            [self afterGetHotWordsTopSucessed:dic userRequest:request];
        }
        else if(request.tag==Stage_SearchCate || request.tag==STage_RelativeQAs)
        {
            [self afterSearchCateIdSucessed:dic userRequest:request];
        }
        else if(request.tag== Stage_MyQuestionList)
        {
            [self afterSearchCateIdSucessed:dic userRequest:request];
        }
        else if(request.tag==Stage_QuizeAdd)
        {
            [self afteraddQuizeSucessed:dic userRequest:request];
        }
        else if(request.tag==Stage_AllAns)
        {
            [self afterSearchCateIdSucessed:dic userRequest:request];
        }
        else if(request.tag==Stage_Favorite)
        {
            [self afterAddFavoriteSuccessed:dic userRequst:request];
        }
        else if(request.tag==Stage_Setting)
        {
            [self afterSettingSuccessed:dic userRequst:request];
        }
        else if(request.tag==Stage_NewRemind)
        {
            [self afterGetNewRemindSucessed:dic userRequst:request];
        }
        else if(request.tag==Stage_ExpertInfo)
        {
            self.bAnExpertLogined = YES;
            [self afterGetExpertInfoSucessed:dic userRequest:request];
        }
        else if(request.tag==Stage_SettingInfo)
        {
            [self afterGetSettingInfoSucessed:dic userRequest:request];
        }
        else if(request.tag==Stage_ClearSet)
        {
            [self afterSettingSuccessed:dic userRequst:request];
        }
        else if(request.tag==Stage_SearchExpert)
        {
            [self afterSearchWordsSucessed:dic userRequest:request];
        }
    }
}


//return nil , fail; other success
- (NSDictionary*) isResultSuccessedOfHttpRequest:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    NSString* resultString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    NSDictionary* jsonDict = [resultString JSONValue];
    
    if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* resultDict = [jsonDict valueForKey:@"result"];
        if (resultDict && [resultDict isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* status = [resultDict valueForKey:@"status"];
            if([[status valueForKey:@"code"]    intValue] == 0)
            {
                return resultDict;
            }
        }
    }
    
    [self requestFailed:request];
    return nil;
}

#pragma mark - Get User Info

- (void) getUserInfoSuccessed : (id)userDic  //userInfo
{// post a notification
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:2];
    [dic setValue:userDic forKey:@"userInfo"];
    [dic setValue:UserInfoSuccessGetNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject: dic];
}

- (void)requestFailed:(ASIHTTPRequest*)request
{
    
    NSString* resultString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"test requestFailed=%@,\nresponseData=%@\n,tag=%d",[request.error description],resultString,request.tag);
    [resultString release];
    if (request.tag==Stage_LoginV2_Small||request.tag==Stage_LoginV2||request.tag==Stage_Login||request.tag==Stage_RealLoginV2) 
    {
        NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
        [notifyDict setObject:LoginFailedNotification forKey:@"postNotificationName"];
        [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
        NSMutableDictionary* notifyUserDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSString* errorString = request.responseString;
        NSDictionary* jsonValue = [errorString JSONValue];
        NSNumber* errorValue = [jsonValue valueForKey:@"error_code"];
        if (errorValue) {
            [notifyUserDict setValue:errorValue forKey:@"error_code"];
        }
        [notifyDict setObject:notifyUserDict forKey:@"userInfo"];
        [notifyUserDict release];
        [self postNotificationWithObject:notifyDict];
    }
    else if(request.tag==Stage_RequestV2_Publish||request.tag==Stage_QuizeAdd)
    {
        [self afterPublishWeiboFailed:request];
    }
    else if(request.tag==Stage_RequestV2_RepostWeibo)
    {
        [self afterRepostWeiboFailed:request];
    }
    else if(request.tag==Stage_RequestV2_CommentWeibo)
    {
        [self afterCommentWeiboFailed:request];
    }
    else if(request.tag==Stage_Favorite)
    {
        [self afterAddFavoriteFailed:request];
    }
    else if(request.tag==Stage_Setting||request.tag == Stage_ClearSet)
    {
        [self afterSettingFailed:request];
    }
    else if(request.tag==Stage_NewRemind)
    {
        [self afterGetNewRemindFailed:request];
    }
    else if(request.tag==Stage_RequestV2_CommentListWeibo)
    {
        [self afterCommentListWeiboFailed:request];
    }
    else
    {
        [self afterFailed:request];
    }
    
}

-(void)queueComplete:(ASINetworkQueue *)queue
{
    
}

-(void)afterLoginSuccessed:(NSInteger)stage
{
    if (stage==Stage_LoginV2||stage == Stage_RealLoginV2) {
        self.hasLogined = YES;
    }
    
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:LoginSuccessedNotification forKey:@"postNotificationName"];
    [notifyDict setObject:[NSNumber numberWithInt:stage] forKey:@"object"];
    
    [self postNotificationWithObject:notifyDict];
}

- (void)afterFailed:(ASIHTTPRequest*)request
{
    NSDictionary* info = request.userInfo;
    NSArray* args = [info objectForKey:RequsetArgs];
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    if ([requestStage intValue] == Stage_ExpertMsg) {
        [notifyDict setObject:ExpertMsgFaildedNotification forKey:@"postNotificationName"];
    }
    else if([requestStage intValue] == Stage_ExpertInfo)
    {
         [notifyDict setObject:ExpertDetailsInfoFaildedNotification forKey:@"postNotificationName"];
    }
    else if([requestStage intValue] == Stage_SearchCate || request.tag==STage_RelativeQAs)
    {
        [notifyDict setObject:SearchFaildedNotification forKey:@"postNotificationName"];
    }
    else if([requestStage intValue] == Stage_MyQuestionList)
    {
        [notifyDict setObject:SearchFaildedNotification forKey:@"postNotificationName"];
    }
    else if([requestStage intValue] == Stage_ExpertbyGroup)
    {
        [notifyDict setObject:ExpertbyGroupFaildedNotification forKey:@"postNotificationName"];
    }
    else if([requestStage intValue] == Stage_SearchExpert)
    {
        [notifyDict setObject:SearchWordsFaildedNotification forKey:@"postNotificationName"];
    }
    else
    {
        [notifyDict setObject:NavObjectsFailedNotification forKey:@"postNotificationName"];
    }
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    
    
    NSNumber* page = [info objectForKey:RequsetPage];
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    if (sender) {
        [notifyinfodict setObject:sender forKey:RequsetSender];
    }
    if (args) {
        [notifyinfodict setObject:args forKey:@"args"];
    }
    if (page) {
        [notifyinfodict setObject:page forKey:@"page"];
    }
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    NSNumber* errorCode = [info objectForKey:RequsetError];
    if (errorCode) {
        [notifyinfodict setObject:errorCode forKey:@"error"];
    }
    NSNumber* typeNumber = [info objectForKey:RequsetType];
    if (typeNumber) {
        [notifyinfodict setObject:typeNumber forKey:@"type"];
    }
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    
    [self postNotificationWithObject:notifyDict];
}

-(void)afterLoginFailed
{
    
}

-(void)afterVerifierFailed
{
    
    
}

-(void)afterPublishFailed
{
    
}

#pragma Mark --
#pragma Mark location

-(void)startHttpAPIRequstByURL:(NSURL*)url headerDict:(NSDictionary*)headerDict userInfo:(NSDictionary*)info stage:(NSInteger)stageInt inBack:(BOOL)bInBack
{
    ASIFormDataRequest* request = [[[ASIFormDataRequest alloc] initWithURL :url] autorelease];
    request.tag = stageInt;
    request.userInfo = info;
    
    if (headerDict) {
        NSArray* headerKey = [headerDict allKeys];
        for (NSString* oneKey in headerKey) {
            NSString* oneValue = [headerDict valueForKey:oneKey];
            [request addRequestHeader:oneKey value:oneValue];
        }
    } 
    [request addRequestHeader:@"Accept-Encoding" value:@"gzip"];
    [request setDelegate:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginStageChangedNotification object:[NSNumber numberWithInt:stageInt] userInfo:nil];
    if (!bInBack) {
        [self addRequestToDowloadQueue:request];
    }
    else
    {
        [self addRequestToOfflineQueue:request];
    }
}

-(void)clearOhterRequestQueue
{
    [mOtherQueue cancelAllOperations];
    self.otherQueue = nil;
}

-(void)initalOtherQueue
{
    if (!mOtherQueue) {
        mOtherQueue = [[ASINetworkQueue alloc] init];
        [mOtherQueue setMaxConcurrentOperationCount:2];
        [mOtherQueue setShouldCancelAllRequestsOnFailure:NO];
        [mOtherQueue setDelegate:self];
        [mOtherQueue setRequestDidFinishSelector:@selector(ohterQueueComplete:)];
    }
}

-(void)addRequestToOhterQueue:(ASIHTTPRequest*)request
{
    [self initalOtherQueue];
    [self.otherQueue addOperation:request];
    [self.otherQueue go];
}

-(void)ohterQueueComplete:(ASINetworkQueue *)queue
{
    
}

-(void)addRequestToOfflineQueue:(ASIHTTPRequest*)request
{
    if ([offlineDelegate respondsToSelector:@selector(manager:OfflineWithRequest:)]) {
        [offlineDelegate manager:self OfflineWithRequest:request];
    }
}

//-(void)startLocationService
//{
//    if (!self.locManager) {
//        CLLocationManager* alocManager = [[CLLocationManager alloc] init];
//        self.locManager = alocManager;
//        [alocManager release];
//        
//        self.locManager.delegate = self;
//        self.locManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
//        
//        self.locManager.distanceFilter = 1000.0f; // in meters
//    }
//    
//    if (self.locManager.locationServicesEnabled)
//    {
//        startLocationUpdateCount = 0;
//        [self.locManager stopUpdatingLocation];
//        [self.locManager startUpdatingLocation];
//    }
//
//    /*
//     self.freshTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector: @selector(refreshLocationTimer:)
//     userInfo:nil repeats:YES];
//     */
//}

//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//	NSLog(@"test Location manager error: %@", [error description]);
////    [self startShowWeatherRequst];
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    NSLog(@"test self Location manager.location=%@, updated: %@",manager.location,[newLocation description]);
//    if (startLocationUpdateCount==0) {
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopLocationUpdate) object:nil];
//        [self performSelector:@selector(stopLocationUpdate) withObject:nil afterDelay:8.01];
//    }
//    BOOL canUseThisTime = NO;
//    if (self.myLocation==nil) {
//        canUseThisTime = YES;
//        self.myLocation = newLocation;
//    }
//    else if ((self.myLocation.coordinate.latitude!=newLocation.coordinate.latitude)||(self.myLocation.coordinate.longitude!=newLocation.coordinate.longitude)) {
//        canUseThisTime = YES;
//    }
//    
//    if (canUseThisTime) {
//        myLocationChanged = 1;
//        if (myLocation!=nil) {
//            self.myLocation = newLocation;
//            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopLocationUpdate) object:nil];
//            [self stopLocationUpdate];
//        }
//        else
//        {
//            self.myLocation = newLocation;
//        }
//    }
//    else
//    {
//        self.myLocation = newLocation;
//    }
//    startLocationUpdateCount++;
//}


-(void)startDownloadEmotionImage
{
    if (!emotionArray) {
        NSArray* documentPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentPath = [documentPathArray objectAtIndex:0];
        NSString* commentPath = [documentPath stringByAppendingPathComponent:@"emotions.json"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:commentPath]) {
            NSString* path = [[NSBundle mainBundle] bundlePath];
            commentPath = [path stringByAppendingPathComponent:@"emotions.json"];
        }
        
        NSError* error;
        NSString* commentStr = [NSString stringWithContentsOfFile:commentPath encoding:NSUTF8StringEncoding error:&error];
        if (!commentStr) {
            commentStr = [NSString stringWithContentsOfFile:commentPath encoding:NSUnicodeStringEncoding error:&error];
        }
        self.emotionArray = [commentStr JSONValue];
        for (int i=[self.emotionArray count]-1;i>=0;i--) {
            NSMutableDictionary* oneEmotion = [self.emotionArray objectAtIndex:i];
            NSNumber* bCommon = [oneEmotion valueForKey:@"common"];
            if (![bCommon boolValue]) {
                [self.emotionArray removeObjectAtIndex:i];
            }
        }
    }
    [self startEmotionRequst];
}

-(void)startEmotionRequst
{
    static int curIndex = 0;
    if (self.emotionArray&&[self.emotionArray count]>curIndex) {
        NSMutableDictionary* oneEmotion = [self.emotionArray objectAtIndex:curIndex];
        NSString *urlStr = [oneEmotion valueForKey:@"url"];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        ASIFormDataRequest* request = [[[ASIFormDataRequest alloc] initWithURL :url] autorelease];
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
        [userInfo setValue:[NSNumber numberWithBool:NO] forKey:@"thread"];
        [userInfo setValue:oneEmotion forKey:@"data"];
        request.userInfo = userInfo;
        [userInfo release];
        [request setDidFinishSelector:@selector(emotionRequstFinished:)];
        [request setDidFailSelector:@selector(emotionRequstFailed:)];
        [request setDelegate:self];
        [request startAsynchronous];
        curIndex++;
    }
    else
    {
        NSString* emotionString = [self.emotionArray JSONRepresentation];
        [MyTool writeToDocument:emotionString folder:@"emotions" fileName:@"emotions.json"];
    }
}

-(void)emotionRequstFailed:(ASIHTTPRequest*)requst
{
    
}

-(void)emotionRequstFinished:(ASIHTTPRequest*)requst
{
    NSDictionary* userInfo = requst.userInfo;
    NSMutableDictionary* data = [userInfo valueForKey:@"data"];
    NSString* urlString = [data valueForKey:@"url"];
    NSString* pathComponent = [[urlString pathComponents] lastObject];
    NSData* responseData = requst.responseData;
    [MyTool writeToDocument:responseData folder:@"emotions" fileName:pathComponent];
    [data setValue:pathComponent forKey:@"local"];
    [self startEmotionRequst];
    
}


-(NSString*)parseDateFromInformatDate:(NSString*)oldDateStr
{
    NSString* rtval = oldDateStr;
    NSDictionary* monthParseDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"jan",@"01",@"feb",@"02",@"mar",@"03",@"apr",@"04",@"may",@"05",@"jun",@"06",@"jul",@"07",@"aug",@"08",@"sep",@"09",@"oct",@"10",@"nov",@"11",@"dec",@"12", nil];
    if (oldDateStr) {
        NSArray* dateArray = [oldDateStr componentsSeparatedByString:@","];
        oldDateStr = [dateArray lastObject];
        oldDateStr = [oldDateStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        dateArray = [oldDateStr componentsSeparatedByString:@" "];
        NSMutableArray* mutableDateArray = [NSMutableArray arrayWithArray:dateArray];
        if ([mutableDateArray count]==5) {
            NSString* month = [mutableDateArray objectAtIndex:1];
            NSString* newMonth = [monthParseDict objectForKey:month.lowercaseString];
            if (newMonth) {
                [mutableDateArray replaceObjectAtIndex:1 withObject:newMonth];
            }
            
            rtval = [NSString stringWithFormat:@"%@-%@-%@ %@ %@",[mutableDateArray objectAtIndex:2],[mutableDateArray objectAtIndex:1],[mutableDateArray objectAtIndex:0],[mutableDateArray objectAtIndex:3],[mutableDateArray objectAtIndex:4]];
        }
        else
        {
            NSLog(@"parseDateFromInformatDate params not right");
        }
    }
    
    [monthParseDict release];
    
    return  rtval;
}

-(void)afterDefaultSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request dataname:(NSString*)dateName
{
    NSMutableArray* array = nil;
    if (!dateName) {
        array = [jsonDict objectForKey:@"data"];
    }
    else
    {
        array = [jsonDict objectForKey:dateName];
    }
//    NSMutableDictionary* info = request.userInfo;
    NSMutableDictionary* info = [NSMutableDictionary dictionaryWithDictionary:request.userInfo];
    int validCount = array?[array count]:0;
    NSNumber* removedNumber = [info objectForKey:RequsetRemoveFirst];
    if (removedNumber) {
        validCount = validCount -1;
    }
    if (!info) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        request.userInfo = dict;
        info = dict;
        [dict release];
    }
    else if(![info isKindOfClass:[NSMutableDictionary class]])
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dict addEntriesFromDictionary:info];
        request.userInfo = dict;
        info = dict;
        [dict release];
    }
    [info setValue:[NSNumber numberWithInt:validCount] forKey:@"count"];
    NSNumber* page = [info objectForKey:RequsetPage];
    NSString* orderString = [info objectForKey:RequsetOrder];
    NSDate* oldDate = [info objectForKey:RequsetLastDate];
    NSString* dateKey = [info objectForKey:RequsetDateKey];
    NSDateFormatter* dateFormatter = [info objectForKey:RequsetDateFormatter];
    if (oldDate&&dateKey&&dateFormatter) {
        for (int i=[array count]-1; i>=0; i--) {
            NSDictionary* tempDict = [array objectAtIndex:i];
            NSString* oneDateStr = [tempDict valueForKey:dateKey];
            NSDate* newFormatDate = [dateFormatter dateFromString:oneDateStr];
            if ([newFormatDate timeIntervalSinceDate:oldDate]>=0) {
                [array removeObjectAtIndex:i];
            }
        }
    }
    
    
    NSMutableArray* orderArray = nil;
    if (orderString&&![orderString isEqualToString:@""]) {
        orderArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
        for (int i=0; i<[array count]; i++) {
            NSMutableDictionary* oneObject = [array objectAtIndex:i];
            if ([oneObject isKindOfClass:[NSMutableDictionary class]]) {
                NSString* orderValue = [oneObject objectForKey:orderString];
                NSNumber* orderNumber = [NSNumber numberWithInt:[orderValue intValue]];
                [oneObject setValue:orderNumber forKey:orderString];
            }
            [orderArray addObject:oneObject];
        }
    }
    
    if (orderString&&![orderString isEqualToString:@""]) {
        if (removedNumber&&[removedNumber boolValue]) {
            if ([orderArray count]>0&&page&&[page intValue]>1) {
                [orderArray removeObjectAtIndex:0];
            }
        }
    }
    
    if (orderString&&![orderString isEqualToString:@""]) {
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:orderString ascending:NO]; 
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sorter count:1]; 
        [sorter release];
        [orderArray sortUsingDescriptors:sortDescriptors];
        [sortDescriptors release];
        array= orderArray;
    }
    
    NSMutableArray* defaultArray = [[NSMutableArray alloc] initWithCapacity:0];
    if ([array isKindOfClass:[NSArray class]]) 
    {
        NSEnumerator* enumerator = [array objectEnumerator];
        NSDictionary* newsDict = nil;
        while (newsDict = [enumerator nextObject]) 
        {            
//            NSArray* allkeys = [newsDict allKeys];
            if ([newsDict isKindOfClass:[NSDictionary class]]&&[[newsDict allKeys] count]>0) 
            {
                DataModel* defalutObject = [[DataModel alloc] initWithJsonDictionary:newsDict];
                [defaultArray addObject:defalutObject];
                [defalutObject release];
            }
        }
    }
    else if([array isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* newsDict = (NSDictionary*)array;
        DataModel* defalutObject = [[DataModel alloc] initWithJsonDictionary:newsDict];
        [defaultArray addObject:defalutObject];
        [defalutObject release];
    }
    
    [orderArray release];
    
    if (!(orderString&&![orderString isEqualToString:@""]))
    {
        if (removedNumber&&[removedNumber boolValue]) {
            if ([defaultArray count]>0&&page&&[page intValue]>1) {
                [defaultArray removeObjectAtIndex:0];
            }
        }
    }
    
    [self afterDefaultSuccessed:defaultArray userRequst:request];
    
    [defaultArray release];
}

-(void)afterDefaultSuccessed:(NSArray*)resultArray userRequst:(ASIHTTPRequest*)request
{
    NSDictionary* info = request.userInfo;
    NSArray* args = [info objectForKey:RequsetArgs];
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    NSNumber* page = [info objectForKey:RequsetPage];
    NSNumber* offlineType = [info objectForKey:RequsetType];
    CommentDataList* dataList = [info objectForKey:RequsetDataList];
    if ([requestStage intValue] == Stage_RequestV2_CommentListWeibo) {
        dataList = [[DataCenter getInstance]commentList];
    }
    if (dataList) {
        if (page&&[page intValue]>1) {
            [dataList addCommnetContents:resultArray IDList:args];
        }
        else
        {
            [dataList refreshCommnetContents:resultArray IDList:args];
        }
    }
    
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];

    if ([requestStage intValue] == Stage_ExpertMsg) 
    {
        [notifyDict setObject:ExpertMsgNotification forKey:@"postNotificationName"];
    }
    else
    {
        [notifyDict setObject:NavObjectsAddedNotification forKey:@"postNotificationName"];
    }

    
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    if (args) {
        [notifyinfodict setObject:args forKey:@"args"];
    }
    if (resultArray) {
        [notifyinfodict setObject:resultArray forKey:@"array"];
    }
    if (page) {
        [notifyinfodict setObject:page forKey:@"page"];
    }
    NSDate* date = [info objectForKey:RequsetDate];
    if (date) {
        [notifyinfodict setObject:date forKey:@"date"];
    }
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    if (offlineType) {
        [notifyinfodict setObject:offlineType forKey:@"type"];
    }
    if (info) {
        [notifyinfodict addEntriesFromDictionary:info];
    }
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    
    [self postNotificationWithObject:notifyDict];
}

-(void)startPushRequest:(BOOL)bStart token:(NSString*)deviceToken
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPushRequestWithToken:) object:nil];
    NSString *urlStr = [NSString stringWithFormat:@"http://roll.news.sina.com.cn/api/client/device.php",deviceToken];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc] initWithURL :url];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dict setValue:deviceToken forKey:@"token"];
    request.userInfo = dict;
    [request setRequestMethod:@"POST"];
    [request setPostValue:deviceToken forKey:@"token"];
    [request setPostValue:@"uuid" forKey:@"auth_type"];
    [request setPostValue:@"285efc5b-2ad5-f96f-31f4-20b5-4f3d7aee" forKey:@"auth_value"];
    
    [dict release];
    request.didFailSelector = @selector(pushFailed:);
    request.didFinishSelector = @selector(pushFinished:);
    [request setDelegate:self];
    [request startAsynchronous];
    [request release];
    
}

-(void)startPushRequestWithToken:(NSString*)deviceToken
{
    [self startPushRequest:YES token:deviceToken];
}

-(void)pushFailed:(ASIHTTPRequest*)request
{
    NSDictionary* info = request.userInfo;
    [self performSelector:@selector(startPushRequestWithToken:) withObject:[info objectForKey:@"token"] afterDelay:60.0];
}

-(void)pushFinished:(ASIHTTPRequest*)request
{
//    NSString* result = request.responseString;
    
}
-(void)checkRefreshToken
{
    int handlesecond = (int)[[NSDate date] timeIntervalSince1970];
    NSString* remind_in = [self.oAuthData objectForKey:@"remind_in"];
    NSString* ReqoAuthDataTime = [self.oAuthData objectForKey:@"ReqoAuthDataTime"];
    if (remind_in) 
    {
        int remind_int = [remind_in intValue];
        int ReqoAuthDataTimeint = [ReqoAuthDataTime intValue];
        if (handlesecond - ReqoAuthDataTimeint >= remind_int) 
        {
            if (self.loginData) 
            {
                [self startRealLoginV2];
            }
        }
    }
}
- (BOOL)isDataSourceAvailable
{
    
    BOOL _isDataSourceAvailable;
    
    // Since checking the reachability of a host can be expensive,
    // cache the result and perform the reachability check once.
    
    Boolean success;
    const char *host_name = "www.sina.com.cn";
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    _isDataSourceAvailable = success&&(flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    CFRelease(reachability);
    
    return _isDataSourceAvailable;
}

-(void)startGetExpertMsgWithSender:(id)sender args:(NSArray*)args
{
    if (sender) 
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    [codeArray addObject:HttpAPI_ExpertRecommend];
    
    [self startAPIRequest:sender withAPICode:codeArray pagename:nil pagevalue:0 countname:nil countvalue:0 args:args stage:Stage_ExpertMsg otherUserInfo:nil headerInfo:nil];
}


-(void)startGetActiveExpertMsgWithSender:(id)sender args:(NSArray*)args page:(NSInteger)page
{
    if (sender)
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    [codeArray addObject:HttpAPI_ExpertRecommend_Acitved];
    
    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:args stage:Stage_ExpertMsg_Active otherUserInfo:nil headerInfo:nil];
}

-(void)startGetUserInfo
{
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString* token = [self.oAuthData objectForKey:LoginReturnKeyV2_Token];
    if (token)
    {
        [dict setObject:token forKey:OAUTH2_TOKEN];
        [orderArray addObject:OAUTH2_TOKEN];
    }
    
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    if (uid)
    {
        NSString* idKey = @"uid";
        [dict setObject:uid forKey:idKey];
        [orderArray addObject:idKey];
    }
    
    NSMutableDictionary* headerDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [headerDict setValue:@"http://www.sina.com.cn" forKey:@"Referer"];
    
    [self startHttpAPIRequestV2:@"GET" data:dict order:orderArray api:HttpAPIV2_UserInfo stage:STage_UserInfo userInfo:nil headerDict:headerDict needSmallLogin:NO bInback:NO];
}

-(void)afterExpertReplySuccessed:(NSDictionary*)jsonDict userReqeust:(ASIHTTPRequest *)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:ExpertReplySuccessNotification forKey:@"postNotificationName"];
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    
    [self postNotificationWithObject:notifyDict];
}


-(void)afterGetExpertMsgSucessed:(NSDictionary*)jsonDict userRequest:(ASIHTTPRequest *)request
{
//    [self afterDefaultSuccessed:jsonDict userRequst:request dataname:@"data"];
    CommentDataList* DataList = [[DataCenter getInstance] expertList];
    NSMutableArray* dataID = [[DataCenter getInstance] expertID];
    NSMutableArray* expertArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray* dataArray = [jsonDict valueForKey:@"data"];
    
    for (int i =0 ; i < [dataArray count]; i++) 
    {
        NSDictionary* oneRecord = [dataArray objectAtIndex:i];
        NSString* Uid = [oneRecord objectForKey:@"uid"];
        if (!Uid) {
            continue;
        }
        if ([dataID count] > 0) {
            [dataID removeAllObjects];
        }
        [dataID addObject:Uid];
        DataModel* expertObject = [[DataModel alloc] initWithJsonDictionary:oneRecord];
        [expertArray addObject:expertObject];
        [expertObject release];
    }
    
    [DataList refreshCommnetContents:expertArray IDList:dataID];
    [expertArray release];
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    NSDictionary* info = request.userInfo;
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate* date = [info objectForKey:RequsetDate];
    if (date) {
        [notifyinfodict setObject:date forKey:@"date"];
    }
    
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict addEntriesFromDictionary:info];
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    [notifyDict setObject:ExpertMsgNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:notifyDict];
}


-(void)afterGetActiveExpertMsgSucessed:(NSDictionary*)jsonDict userRequest:(ASIHTTPRequest *)request
{
    CommentDataList* DataList = [[DataCenter getInstance] expertList];
    NSMutableArray* dataID = [[DataCenter getInstance] expertActived];
    NSMutableArray* expertArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSDictionary* dataDict = [jsonDict valueForKey:@"data"];
    NSArray* dataArray = [dataDict valueForKey:@"list"];
    NSDictionary* pageDict = [dataDict valueForKey:@"page"];
    
    NSString* totalPage = [pageDict valueForKey:@"totalpage"];
    NSString* page = [pageDict valueForKey:@"page"];
    NSString* pagesize = [pageDict valueForKey:@"pagesize"];
    NSString* total = [pageDict valueForKey:@"total"];
    
    if (![dataArray isKindOfClass:[NSArray class]] || dataArray.count == 0)
    {
        return;
    }
        
    for (int i =0 ; i < [dataArray count]; i++)
    {
        NSDictionary* oneRecord = [dataArray objectAtIndex:i];
        NSString* Uid = [oneRecord objectForKey:@"uid"];
        if (!Uid) {
            continue;
        }

        DataModel* expertObject = [[DataModel alloc] initWithJsonDictionary:oneRecord];
        [expertArray addObject:expertObject];
        [expertObject release];
    }
    
    if ([page intValue]== 1)
    {
        [DataList refreshCommnetContents:expertArray IDList:dataID];
    }
    else
    {
        [DataList addCommnetContents:expertArray IDList:dataID];
    }
    [expertArray release];
    
    
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    NSDictionary* info = request.userInfo;
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate* date = [info objectForKey:RequsetDate];
    if (date) {
        [notifyinfodict setObject:date forKey:@"date"];
    }
    
    [notifyinfodict setObject:totalPage forKey:@"totalPage"];
    [notifyinfodict setObject:page forKey:@"page"];
    [notifyinfodict setObject:pagesize forKey:@"count"];
    [notifyinfodict setObject:total forKey:@"total"];
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict addEntriesFromDictionary:info];
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    [notifyDict setObject:ExpertMsgNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:notifyDict];
}


-(void)startGetExpertClassWithSender:(id)sender args:(NSArray*)args
{
    if (sender) 
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    [codeArray addObject:HttpAPI_ExpertClass];
    
    [self startAPIRequest:sender withAPICode:codeArray pagename:nil pagevalue:0 countname:nil countvalue:0 args:args stage:Stage_ExpertClass otherUserInfo:nil headerInfo:nil];
}
-(void)afterGetExpertClassSucessed:(NSDictionary*)jsonDict userRequest:(ASIHTTPRequest *)request
{
    //    [self afterDefaultSuccessed:jsonDict userRequst:request dataname:@"data"];
    CommentDataList* DataList = [[DataCenter getInstance] classList];
    NSDictionary* info = request.userInfo;
    NSArray* args = [info objectForKey:RequsetArgs];

   
    NSArray* dataArray = [jsonDict valueForKey:@"data"];
    
    if (![dataArray isKindOfClass:[NSArray class]]) 
    {
        return;
    }
    
    NSMutableArray* expertArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i = 0; i < [dataArray count]; i++) {
        NSDictionary* oneRecord = [dataArray objectAtIndex:i];
        DataModel* expertObject = [[DataModel alloc] initWithJsonDictionary:oneRecord];
        [expertArray addObject:expertObject];
        [expertObject release];
    }

    [DataList refreshCommnetContents:expertArray IDList:args];
    [expertArray release];
    
    
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) 
    {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate* date = [info objectForKey:RequsetDate];
    if (date) 
    {
        [notifyinfodict setObject:date forKey:@"date"];
    }
    
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict addEntriesFromDictionary:info];
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    [notifyDict setObject:ExperClassNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:notifyDict];
}
-(void)startGetExpertbyGroupWithSender:(id)sender args:(NSArray *)args page:(NSInteger)page
{
    if (sender) 
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    if (args&&[args count]>0&&![[args objectAtIndex:0] isEqualToString:@"all"]) {
        NSString* urlStr = [NSString stringWithFormat:@"%@&cate_id=%@", HttpAPI_ExpertMsg, [args objectAtIndex:0]];
        [codeArray addObject:urlStr];
    }
    else
    {
         NSString* urlStr = [NSString stringWithFormat:@"%@&pagesize=10", HttpAPI_ExpertMsg];
        [codeArray addObject:urlStr];
    }
    [codeArray addObject:HttpAPI_ExpertMsg];
    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:args stage:Stage_ExpertbyGroup otherUserInfo:nil headerInfo:nil];

}
-(void)afterGetExpertbyGroupSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request
{
    //    [self afterDefaultSuccessed:jsonDict userRequst:request dataname:@"data"];
    CommentDataList* DataList = [[DataCenter getInstance] expertbyGroupList];
    NSDictionary* info = request.userInfo;
    NSArray* args = [info objectForKey:RequsetArgs];
    
    NSMutableArray* expertArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSDictionary* dataDict = [jsonDict valueForKey:@"data"];
    NSArray* dataArray = [dataDict valueForKey:@"list"];
    
    
    NSDictionary* pageDict = [dataDict valueForKey:@"page"];
    
    NSString* totalPage = [pageDict valueForKey:@"totalpage"];
    NSString* page = [pageDict valueForKey:@"page"];
    NSString* pagesize = [pageDict valueForKey:@"pagesize"];
    if (![dataArray isKindOfClass:[NSArray class]]) 
    {
        return;
    }
    for (int i = 0; i < [dataArray count]; i++) {
        NSDictionary* onerecord = [dataArray objectAtIndex:i];
//        NSNumber* cateid = [onerecord objectForKey:EXPERT_CATEID];
//        [dataID addObject:cateid];
        DataModel* expertObject = [[DataModel alloc] initWithJsonDictionary:onerecord];
        [expertArray addObject:expertObject];
        [expertObject release];
    }
    if ([page intValue]== 1) 
    {
        [DataList refreshCommnetContents:expertArray IDList:args];
    }
    else
    {
        [DataList addCommnetContents:expertArray IDList:args];
    }

    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate* date = [info objectForKey:RequsetDate];
    if (date) {
        [notifyinfodict setObject:date forKey:@"date"];
    }
    
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict addEntriesFromDictionary:info];
    
    [notifyinfodict setObject:totalPage forKey:@"totalPage"];
    [notifyinfodict setObject:page forKey:@"page"];
    [notifyinfodict setObject:pagesize forKey:@"count"];
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    [notifyDict setObject:ExpertbyGroupNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:notifyDict];
}
-(void)startGetSearchGroupWithSender:(id)sender
{
    if (sender) 
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];

    [codeArray addObject:HttpAPI_SearchGroup];
    
    [self startAPIRequest:sender withAPICode:codeArray pagename:nil pagevalue:0 countname:nil countvalue:0 args:nil stage:Stage_SearchGroup otherUserInfo:nil headerInfo:nil];
    

}

-(void)startGetHotwordsWithSender:(id)sender
{
    if (sender)
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    
    [codeArray addObject:HttpAPI_HotwordsTop];
    
    [self startAPIRequest:sender withAPICode:codeArray pagename:nil pagevalue:0 countname:nil countvalue:0 args:nil stage:Stage_GetHotwordsTop otherUserInfo:nil headerInfo:nil];
}

#pragma mark - After HttpRequest Successed, Handle Returned Data
-(void)afterGetSearchGroupSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request
{
    //    [self afterDefaultSuccessed:jsonDict userRequst:request dataname:@"data"];
    CommentDataList* DataList = [[DataCenter getInstance] searchgroupList];
    NSArray* dataID = [[DataCenter getInstance] searchgroupID];
    NSMutableArray* expertArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSArray* dataArray = [jsonDict valueForKey:@"data"];
    
    if (![dataArray isKindOfClass:[NSArray class]]) 
    {
        return;
    }

    
    for (int i = 0; i < [dataArray count]; i++) {
        NSDictionary* oneRecord = [dataArray objectAtIndex:i];
        DataModel* expertObject = [[DataModel alloc] initWithJsonDictionary:oneRecord];
        [expertArray addObject:expertObject];
        [expertObject release];
    }
    
    [DataList refreshCommnetContents:expertArray IDList:dataID];

    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    NSDictionary* info = request.userInfo;
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate* date = [info objectForKey:RequsetDate];
    if (date) {
        [notifyinfodict setObject:date forKey:@"date"];
    }
    
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict addEntriesFromDictionary:info];
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    [notifyDict setObject:SearchArrayNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:notifyDict];
}

-(void)afterGetHotWordsTopSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request
{
    CommentDataList* DataList = [[DataCenter getInstance] searchgroupList];
    NSArray* dataID = [[DataCenter getInstance] hotwordsGroupID];
    NSMutableArray* hotwordsArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSArray* dataArray = [jsonDict valueForKey:@"data"];
    
    if (![dataArray isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    
    for (int i = 0; i < [dataArray count]; i++) {
        NSDictionary* oneRecord = [dataArray objectAtIndex:i];
        DataModel* expertObject = [[DataModel alloc] initWithJsonDictionary:oneRecord];
        [hotwordsArray addObject:expertObject];
        [expertObject release];
    }
    
    [DataList refreshCommnetContents:hotwordsArray IDList:dataID];
    
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    NSDictionary* info = request.userInfo;
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate* date = [info objectForKey:RequsetDate];
    if (date) {
        [notifyinfodict setObject:date forKey:@"date"];
    }
    
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict addEntriesFromDictionary:info];
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    [notifyDict setObject:SearchHotwordsNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:notifyDict];
}

-(void)startSearchCateIdWithSender:(id)sender args:(NSDictionary *)args page:(NSInteger)page
{
    if (sender) 
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    
    if ( args && [args count] > 0)
    {
        NSString* url = HttpAPI_Search;
        
        for (id key in args)
        {
            url = [url stringByAppendingFormat:@"&%@=%@", key, [args valueForKey:key]];
        }
        
        [codeArray addObject:url];
    }
    else
    {
        return;
    }
    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:nil stage:Stage_SearchCate otherUserInfo:nil headerInfo:nil];
    
}

-(void)sendSearchword2ServerWithSender:(id)sender args:(NSString *)args
{
    NSString* keydata = args;
    NSDictionary* dic = nil;
    if (keydata) {
        dic = [NSDictionary dictionaryWithObject:keydata forKey:@"keyword"];
    }
    
    if (dic) {
        NSDictionary* headerDic = [NSDictionary dictionaryWithObject:@"http://www.sina.com.cn" forKey:@"Referer"];
        
        [self startHttpAPIRequestV2:@"POST" data:dic order:@[@"keyword"] api:HttpAPI_Send2ServerHotword stage:-1 userInfo:nil headerDict:headerDic needSmallLogin:NO bInback:NO];
    }
}

-(void)startSearchbyWordWithSender:(id)sender args:(NSString *)args page:(NSInteger)page
{
    if (sender) 
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    if (args) {
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
        NSString* keydata = [args rawUrlEncodeByEncoding:gbkEncoding];
        NSString* url = [NSString stringWithFormat:@"%@&keyword=%@", HttpAPI_Search, keydata];
        [codeArray addObject:url];
    }
    else
    {
        return;
    }
    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:nil stage:Stage_SearchCate otherUserInfo:nil headerInfo:nil];
    
}

-(void)afterSearchCateIdSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request
{
    CommentDataList* DataList = [[DataCenter getInstance] searchDateList];
    NSArray* dataID = [[DataCenter getInstance] searchArgs];
    
    NSMutableArray* expertArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSDictionary* dataDict = [jsonDict valueForKey:@"data"];

    NSDictionary* pageDict = nil;
    
    NSString* totalPage = nil;
    NSString* page = nil;
    NSString* pagesize = nil;
    NSString* total = nil;

    
    if (request.tag == STage_RelativeQAs) {
        totalPage = @"1";
        page = @"1";
        pagesize = @"2";
        total = @"2";
    }
    else
    {
        pageDict = [dataDict valueForKey:@"page"];
        
        totalPage = [pageDict valueForKey:@"totalpage"];
        page = [pageDict valueForKey:@"page"];
        pagesize = [pageDict valueForKey:@"pagesize"];
        total = [pageDict valueForKey:@"total"];
    }
    
    if (![dataDict isKindOfClass:[NSDictionary class]]) 
    {
        //STage_RelativeQAs find nothing
        if (request.tag == STage_RelativeQAs) {
            [self afterFailed:request];
        }
        return;
    }

    NSArray* ListArray = [dataDict valueForKey:@"list"];
    if (![ListArray isKindOfClass:[NSArray class]]) {
        return;
    }
    for (int i = 0; i < [ListArray count]; i++) 
    {
        NSArray* oneQuize = [ListArray objectAtIndex:i];
        for (int j = 0; j < [oneQuize count]; j++) 
        {
            NSDictionary* oneRecord = [oneQuize objectAtIndex:j];
            DataModel* expertObject = [[DataModel alloc] initWithJsonDictionary:oneRecord];
            if (oneQuize.count == 1) {
                expertObject.newsType = DataModelType_Single;
            }
            
            if (request.tag == Stage_MyQuestionList) {
                expertObject.tag = Stage_MyQuestionList;
            }
            [expertArray addObject:expertObject];
            [expertObject release];
        }
    }
    
    if ([page intValue] == 1) {
        [DataList refreshCommnetContents:expertArray IDList:dataID];
    }
    else
    {
        [DataList addCommnetContents:expertArray IDList:dataID];
    }

    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    NSDictionary* info = request.userInfo;
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate* date = [info objectForKey:RequsetDate];
    if (date) {
        [notifyinfodict setObject:date forKey:@"date"];
    }
    
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict addEntriesFromDictionary:info];
    

    
    [notifyinfodict setObject:totalPage forKey:@"totalPage"];
    [notifyinfodict setObject:page forKey:@"page"];
    [notifyinfodict setObject:pagesize forKey:@"count"];
    [notifyinfodict setObject:total forKey:@"total"];
    
    NSString* type = [info objectForKey:@"favourite"];
    if (type) {
         [notifyinfodict setObject:type forKey:@"favourite"];
    }
   
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    [notifyDict setObject:SearchNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:notifyDict];

}
-(void)startSearchWordsWithSender:(id)sender args:(NSString*)keywords page:(NSInteger)page;
{
    if (sender) 
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSString* keydata = [keywords rawUrlEncodeByEncoding:gbkEncoding];
    
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];

    NSString* url = [NSString stringWithFormat:@"%@&keyword=%@", HttpAPI_SearchName, keydata];
    [codeArray addObject:url];

    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:nil stage:Stage_SearchExpert otherUserInfo:nil headerInfo:nil];
}
-(void)afterSearchWordsSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request
{
    CommentDataList* DataList = [[DataCenter getInstance] EsearchDateList];
    
    NSArray* dataID = [[DataCenter getInstance] searchExpertArray];
    
    NSMutableArray* expertArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSDictionary* dataDict = [jsonDict valueForKey:@"data"];
    NSArray* dataArray= [dataDict valueForKey:@"list"];
    
    NSDictionary* pageDict = [dataDict valueForKey:@"page"];
    
    NSString* totalPage = [pageDict valueForKey:@"totalpage"];
    NSString* page = [pageDict valueForKey:@"page"];
    NSString* pagesize = [pageDict valueForKey:@"pagesize"];
    
    if (![dataArray isKindOfClass:[NSArray class]]) 
    {
        return;
    }

    for (int i = 0; i < [dataArray count]; i++) 
    {
        NSDictionary* oneExpert = [dataArray objectAtIndex:i];
        DataModel* expertObject = [[DataModel alloc] initWithJsonDictionary:oneExpert];
        [expertArray addObject:expertObject];
        [expertObject release];
    }
    if ([page intValue] > 1) {
        [DataList addCommnetContents:expertArray IDList:dataID];
    }
    else
    {
        [DataList refreshCommnetContents:expertArray IDList:dataID];
    }
    
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    NSDictionary* info = request.userInfo;
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate* date = [info objectForKey:RequsetDate];
    if (date) {
        [notifyinfodict setObject:date forKey:@"date"];
    }
    
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict addEntriesFromDictionary:info];
    

    
    [notifyinfodict setObject:totalPage forKey:@"totalPage"];
    [notifyinfodict setObject:page forKey:@"page"];
    [notifyinfodict setObject:pagesize forKey:@"count"];
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    [notifyDict setObject:SearchWordsNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:notifyDict];
}

-(void)startaddQuizeWithSender:(id)sender args:(NSString*)Content expert:(NSString*)expert_uid anonymouse:(NSString*)anonymouse
{
//    if (sender) {
//        sender = [NSNumber numberWithInt:((int)sender)];
//    }
    
    NSString* httpAPI = HttpAPI_QuizeAdd;
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [self rawV2PublishWithRetOrder:orderArray status:Content];
    
    // 收藏和提问的接口关键字不一样， 一个是status, 一个是text， 为了不改上面那个函数rawV2PublishWithRetOrder，我们在这里修改一下
    NSString* text = [dict valueForKey:@"status"];
    if ([text length] > 0) {
        [orderArray removeLastObject];
        [orderArray addObject:@"text"];
        
        [dict removeObjectForKey:@"status"];
        [dict setValue:text forKey:@"text"];
    }
    
    if(expert_uid)
    {
        NSString* idKey = @"expert_uid";
        [dict setObject:expert_uid forKey:idKey];
        [orderArray addObject:idKey];
    }
    
    if (anonymouse) {
        NSString* idKey = @"anonymouse";
        [dict setObject:anonymouse forKey:idKey];
        [orderArray addObject:idKey];
    }
    
    NSMutableDictionary* userdict = [NSMutableDictionary dictionaryWithCapacity:0];
    [userdict setValue:[NSDate date] forKey:RequsetDate];
    
    NSMutableDictionary* headerDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [headerDict setValue:@"http://www.sina.com.cn" forKey:@"Referer"];
    [self startHttpAPIRequestV2:@"POST" data:dict order:orderArray api:httpAPI stage:Stage_QuizeAdd userInfo:userdict headerDict:headerDict needSmallLogin:NO bInback:NO];

}
-(void)afteraddQuizeSucessed:(NSDictionary *)jsonDict userRequest:(ASIHTTPRequest *)request
{
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    NSDictionary* info = request.userInfo;
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict addEntriesFromDictionary:info];
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    [notifyDict setObject:QuizeNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:notifyDict];
}
-(void)startGetAllAnswerofExpertWithSender:(id)sender param:(NSDictionary*)param page:(NSInteger)page
{
    if (param.count < 1) {
        return;
    }
    
    if (sender) {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    
    NSString* url = HttpAPI_AllAnswer;
    if ( param && [param count] > 0)
    {
        for (id key in param)
        {
            url = [url stringByAppendingFormat:@"&%@=%@", key, [param valueForKey:key]];
        }
    }
    
    [codeArray addObject:url];
    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:nil stage:Stage_SearchCate otherUserInfo:nil headerInfo:nil];
}

-(void)startGetAllQAInWeiboWithSender:(id)sender page:(NSInteger)page
{
    if (sender) {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    
    NSString* url = [NSString stringWithFormat:@"%@", HttpAPI_AllQAInWeibo];
    [codeArray addObject:url];
    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:nil stage:Stage_SearchCate otherUserInfo:nil headerInfo:nil];
}

-(void)startGetQuestionsNeedReplyWithSender:(id)sender page:(NSInteger)page
{
    if (sender) {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    
    NSMutableDictionary* paramsDic = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    NSString* sid = mSubjectID;
    NSString* token = [self.oAuthData objectForKey:LoginReturnKeyV2_Token];
    NSString* ASK_TO_ME = @"1";
    
    [paramsDic setValue:uid forKey:LoginReturnKey_User_id];
    [paramsDic setValue:sid forKey:Subject_id];
    [paramsDic setValue:token forKey:LoginReturnKeyV2_Token];
    [paramsDic setValue:ASK_TO_ME forKey:@"ask_to_me"];

    
    NSString* url = [NSString stringWithFormat:@"%@", HttpAPI_QuestionsNeedReply];
    
    for (id key in paramsDic)
    {
        url = [url stringByAppendingFormat:@"&%@=%@", key, [paramsDic valueForKey:key]];
    }
    //other params
    [paramsDic  release];
    
    [codeArray addObject:url];
    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:nil stage:STage_QuestionNeedsReply otherUserInfo:nil headerInfo:nil];
}

-(void) afterReplyAnQuestionSuccessed
{
    [self postNotificationWithObject:[NSDictionary dictionaryWithObject:ReplyedAnQuestionNotification forKey:@"postNotificationName"]];
}

-(void) afterGetQuestionsNeedReplySuccessed:(NSDictionary*)jsonDict userRequest:(ASIHTTPRequest *)request
{
    CommentDataList* DataList = [[DataCenter getInstance] searchDateList];
    NSArray* dataID = [[DataCenter getInstance] searchArgs];
    
    NSDictionary* dataDict = [jsonDict valueForKey:@"data"];
    if (![dataDict isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    NSString* page = nil;
    NSString* total = nil;
    NSString* num = nil;

    page = [dataDict valueForKey:@"page"];
    total = [dataDict valueForKey:@"total"];
    num = [dataDict valueForKey:@"num"];
       
    NSArray* ListArray = [dataDict valueForKey:@"list"];
    if (![ListArray isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSMutableArray* QuestionsArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [ListArray count]; i++)
    {
        NSDictionary* oneRecord = [ListArray objectAtIndex:i];
        DataModel* question = [[DataModel alloc] initWithJsonDictionary:oneRecord];
        question.tag = STage_QuestionNeedsReply;
        [QuestionsArray addObject:question];
        [question release];
    }
    
    //may be updata db, see it
    if ([page intValue] == 1) {
        [DataList refreshCommnetContents:QuestionsArray IDList:dataID];
    }
    else
    {
        [DataList addCommnetContents:QuestionsArray IDList:dataID];
    }    
    [QuestionsArray release];
    
    NSMutableDictionary* bigNotifyDict = [NSMutableDictionary dictionaryWithCapacity:3];    
    NSDictionary* info = request.userInfo;
    id sender = [info objectForKey:RequsetSender];
    if (sender)
    {
        [bigNotifyDict setObject:sender forKey:@"object"];
    }
    
    NSMutableDictionary* smallNotifyDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate* date = [info objectForKey:RequsetDate];
    if (date)
    {
        [smallNotifyDict setObject:date forKey:@"date"];
    }
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    [smallNotifyDict setObject:requestStage forKey:@"stage"];
    [smallNotifyDict addEntriesFromDictionary:info];
    
    [smallNotifyDict setObject:page forKey:@"page"];
    [smallNotifyDict setObject:num forKey:@"num"];
    [smallNotifyDict setObject:total forKey:@"total"];
    
    NSString* type = [info objectForKey:@"favourite"];
    if (type)
    {
        [smallNotifyDict setObject:type forKey:@"favourite"];
    }
    
    
    [bigNotifyDict setObject:smallNotifyDict forKey:@"userInfo"];
    [bigNotifyDict setObject:NeedReplyQuestionNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:bigNotifyDict];
}

-(void)startGetFavoriteListWithSender:(id)sender page:(NSInteger)page
{
    if (sender) {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    NSString* url = [NSString stringWithFormat:@"%@&uid=%@", HttpAPI_FavoriteList, uid];
    [codeArray addObject:url];
    NSDictionary* fav = [NSDictionary dictionaryWithObject:@"favourite" forKey:@"favourite"];
    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:nil stage:Stage_SearchCate otherUserInfo:fav headerInfo:nil];
}

-(void)startGetRelativeQAsWithSender:(id)sender args:(NSDictionary*)params page:(NSInteger)page
{
    if (sender) {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    NSString* url = [NSString stringWithFormat:@"%@&uid=%@", HttpAPI_RecommendQA, uid];
    if (params) {
        
        NSString* urlString = nil;
        for (id strKey in params)
        {
            if ([strKey isEqualToString:@"sid"]) {
                int value = [[params valueForKey:strKey] intValue];
                urlString = [NSString stringWithFormat:@"%@&%@=%d", url, strKey, value];
            }
            else if([strKey isEqualToString:@"text"])
            {
                NSString* value = [params valueForKey:@"text"];
//                NSString* encodeText = [url rawUrlEncode];   or call below
                NSString* encodeText = [value rawUrlEncodeByEncoding:NSUTF8StringEncoding];
                urlString = [NSString stringWithFormat:@"%@&%@=%@", url, strKey, encodeText];
            }
            
            if (urlString) {
                url = urlString;
            }
        }
        
    }
    [codeArray addObject:url];
    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:nil stage:STage_RelativeQAs otherUserInfo:nil headerInfo:nil];
}

-(void)startRepostV2WeiboWithID:(NSString*)mID content:(NSString*)aText
{
    NSString* httpAPI = HttpAPIV2_RepostWeibo;
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString* token = [self.oAuthData objectForKey:LoginReturnKeyV2_Token];
    if (token) {
        [dict setObject:token forKey:OAUTH2_TOKEN];
        [orderArray addObject:OAUTH2_TOKEN];
    }
    
    if (mID) {
        NSString* idKey = @"id";
        [dict setObject:mID forKey:idKey];
        [orderArray addObject:idKey];
    }
    
    if (aText) {
        NSString* idKey = @"status";
        [dict setObject:aText forKey:idKey];
        [orderArray addObject:idKey];
    }
    NSMutableDictionary* headerDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [headerDict setValue:@"http://www.sina.com.cn" forKey:@"Referer"];
    [self startHttpAPIRequestV2:@"POST" data:dict order:orderArray api:httpAPI stage:Stage_RequestV2_RepostWeibo userInfo:nil headerDict:headerDict needSmallLogin:NO bInback:NO];
}

-(void)afterRepostWeiboSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:NetworkPublishSuccessNotification forKey:@"postNotificationName"];
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    
    [self postNotificationWithObject:notifyDict];
}

#pragma mark - Post Notification for Tracing this
-(void)postNotificationWithObject : (id)obj //for tracing notification
{
    [self performSelectorOnMainThread:@selector(mainThreadRunningNotification:) withObject:obj waitUntilDone:NO];
}

-(void)afterRepostWeiboFailed:(ASIHTTPRequest*)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:NetworkPublishFaildedNotification forKey:@"postNotificationName"];
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    
    [self postNotificationWithObject:notifyDict];
}

-(void)startCommentV2WeiboWithID:(NSString*)mID content:(NSString*)aText
{
    NSString* httpAPI = HttpAPIV2_CommentWeibo;
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString* token = [self.oAuthData objectForKey:LoginReturnKeyV2_Token];
    if (token) {
        [dict setObject:token forKey:OAUTH2_TOKEN];
        [orderArray addObject:OAUTH2_TOKEN];
    }
    
    if (mID) {
        NSString* idKey = @"id";
        [dict setObject:mID forKey:idKey];
        [orderArray addObject:idKey];
    }
    
    if (aText) {
        NSString* idKey = @"comment";
        [dict setObject:aText forKey:idKey];
        [orderArray addObject:idKey];
    }
    NSMutableDictionary* headerDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [headerDict setValue:@"http://www.sina.com.cn" forKey:@"Referer"];
    [self startHttpAPIRequestV2:@"POST" data:dict order:orderArray api:httpAPI stage:Stage_RequestV2_CommentWeibo userInfo:nil headerDict:headerDict needSmallLogin:NO bInback:NO];
}

-(void)startReplyQuestionWithObject : (NSDictionary*)params
{
    NSString* httpAPI = HttpAPI_ReplyAQuestion;
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString* token = [self.oAuthData objectForKey:LoginReturnKeyV2_Token];
    if (token)
    {
        [dict setObject:token forKey:OAUTH2_TOKEN];
        [orderArray addObject:OAUTH2_TOKEN];
    }
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    if (uid)
    {
        NSString* idKey = @"uid";
        [dict setObject:uid forKey:idKey];
        [orderArray addObject:idKey];
    }
    
    for (id key in params)
    {
        [dict setValue:[params valueForKey:key] forKey:key];
        [orderArray addObject:key];
    }

    NSMutableDictionary* headerDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [headerDict setValue:@"http://www.sina.com.cn" forKey:@"Referer"];
    [self startHttpAPIRequestV2:@"POST" data:dict order:orderArray api:httpAPI stage:STage_ExpertReplyQ userInfo:nil headerDict:headerDict needSmallLogin:NO bInback:NO];
}

-(void)afterCommentWeiboSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:NetworkPublishSuccessNotification forKey:@"postNotificationName"];
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    
    [self postNotificationWithObject:notifyDict];
}

-(void)afterCommentWeiboFailed:(ASIHTTPRequest*)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:NetworkPublishFaildedNotification forKey:@"postNotificationName"];
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    
    [self postNotificationWithObject:notifyDict];
}
-(void)startAddFavoriteWithID:(NSString*)mID
{
    NSString* httpAPI = HttpAPI_Favorite;
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString* token = [self.oAuthData objectForKey:LoginReturnKeyV2_Token];
    if (token) {
        [dict setObject:token forKey:OAUTH2_TOKEN];
        [orderArray addObject:OAUTH2_TOKEN];
    }
    
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    if (uid) {
        NSString* idKey = @"uid";
        [dict setObject:uid forKey:idKey];
        [orderArray addObject:idKey];
    }
    
    if (mID) {
        NSString* idKey = @"mid";
        [dict setObject:mID forKey:idKey];
        [orderArray addObject:idKey];
    }
    NSMutableDictionary* headerDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [headerDict setValue:@"http://www.sina.com.cn" forKey:@"Referer"];
    [self startHttpAPIRequestV2:@"POST" data:dict order:orderArray api:httpAPI stage:Stage_Favorite userInfo:nil headerDict:headerDict needSmallLogin:NO bInback:NO];
}
-(void)afterAddFavoriteSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:AddFavoriteNotification forKey:@"postNotificationName"];
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    
    [self postNotificationWithObject:notifyDict];
}
-(void)afterAddFavoriteFailed:(ASIHTTPRequest*)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:AddFavoriteFaildedNotification forKey:@"postNotificationName"];
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    
    [self postNotificationWithObject:notifyDict];
}
-(void)startAddSettingWithDate:(NSString*)mDate gender:(NSString*)gender baby_name:(NSString*)baby_name
{
    NSString* httpAPI = HttpAPI_Setting;
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString* token = [self.oAuthData objectForKey:LoginReturnKeyV2_Token];
    if (token) {
        [dict setObject:token forKey:OAUTH2_TOKEN];
        [orderArray addObject:OAUTH2_TOKEN];
    }
    
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    if (uid) {
        NSString* idKey = @"uid";
        [dict setObject:uid forKey:idKey];
        [orderArray addObject:idKey];
    }
    
    if (gender) {
        if (mDate) {
            NSString* idKey = @"birth_date";
            [dict setObject:mDate forKey:idKey];
            [orderArray addObject:idKey];
        }
        if (baby_name) {
            NSString* idKey = @"baby_name";
            [dict setObject:baby_name forKey:idKey];
            [orderArray addObject:idKey];
        }
        
        NSString* idKey = @"gender";
        [dict setObject:gender forKey:idKey];
        [orderArray addObject:idKey];
    }
    else
    {
        if (mDate) {
            NSString* idKey = @"edc_date";
            [dict setObject:mDate forKey:idKey];
            [orderArray addObject:idKey];
        }
    }
    NSMutableDictionary* headerDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [headerDict setValue:@"http://www.sina.com.cn" forKey:@"Referer"];
    [self startHttpAPIRequestV2:@"POST" data:dict order:orderArray api:httpAPI stage:Stage_Setting userInfo:nil headerDict:headerDict needSmallLogin:NO bInback:NO];
}
-(void)afterSettingSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    NSDictionary* info = request.userInfo;
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];

    
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];

    if ([requestStage intValue] == Stage_ClearSet) {
        [notifyDict setObject:SettingClearNotification forKey:@"postNotificationName"];
    }
    else
    {
        [notifyDict setObject:SettingNotification forKey:@"postNotificationName"];
    }
    
    [self postNotificationWithObject:notifyDict];
}
-(void)afterSettingFailed:(ASIHTTPRequest*)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    if (request.tag == Stage_ClearSet) {
        [notifyDict setObject:SettingClearFaildedNotification forKey:@"postNotificationName"];
    }
    else
    {
        [notifyDict setObject:SettingFaildedNotification forKey:@"postNotificationName"];
    }
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    
    [self postNotificationWithObject:notifyDict];
}
-(void)saveUserSetting:(NSDictionary*)dict
{
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    if (uid) {
        [[RegValueSaver getInstance] saveUserInfoValue:dict forKey:Key_User_Setting userID:uid encryptString:YES];
    }
    
}
-(void)removeUserSettinginfo
{
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    [[RegValueSaver getInstance] removeUserInfoValueforKey:Key_User_Setting userID:uid];
}
-(id)readUserSettinginfo
{
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    return [[RegValueSaver getInstance]readUserInfoForKey:Key_User_Setting userID:uid];
}
-(void)startClearSetting
{
    NSString* httpAPI = HttpAPI_ClearSetting;
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString* token = [self.oAuthData objectForKey:LoginReturnKeyV2_Token];
    if (token) {
        [dict setObject:token forKey:OAUTH2_TOKEN];
        [orderArray addObject:OAUTH2_TOKEN];
    }
    
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    if (uid) {
        NSString* idKey = @"uid";
        [dict setObject:uid forKey:idKey];
        [orderArray addObject:idKey];
    }
    NSMutableDictionary* headerDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [headerDict setValue:@"http://www.sina.com.cn" forKey:@"Referer"];
    [self startHttpAPIRequestV2:@"POST" data:dict order:orderArray api:httpAPI stage:Stage_ClearSet userInfo:nil headerDict:headerDict needSmallLogin:NO bInback:NO];
}
-(void)startGetNewRecomendWithSender:(id)sender
{
    if (sender) {
        sender = [NSNumber numberWithInt:((int)sender)];
    }

    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];

    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];

    NSString* url = [NSString stringWithFormat:@"%@&uid=%@", HttpAPI_Newremind, uid];
    [codeArray addObject:url];
    [self startAPIRequest:sender withAPICode:codeArray pagename:nil pagevalue:0 countname:nil countvalue:0 args:nil stage:Stage_NewRemind otherUserInfo:nil headerInfo:nil];
}

-(void)startGetNewRecomendBackground
{

    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    NSString* urlString = [NSString stringWithFormat:@"%@&uid=%@", HttpAPI_Newremind, uid];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* reqeust = [[NSMutableURLRequest alloc] initWithURL:url];
    [reqeust setValue:@"www.sina.com.cn" forHTTPHeaderField:@"Referer"];
//    [reqeust setNetworkServiceType:NSURLNetworkServiceTypeVoIP];
    
    [NSURLConnection connectionWithRequest:reqeust delegate:self];
    [reqeust release];
}


#pragma mark - NSURLConnection delegate, ASIHttpRequest also received this, why ? --to do
//数据加载过程中调用
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.remindData appendData:data];
}

//数据加载完成后调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString* resultString = [[[NSString alloc] initWithData:self.remindData encoding:NSUTF8StringEncoding] autorelease];
    NSDictionary* jsonDict = [resultString JSONValue];
    
    if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* resultDict = [jsonDict valueForKey:@"result"];
        if (resultDict && [resultDict isKindOfClass:[NSDictionary class]])
        {
            NSNumber* count = [resultDict valueForKey:@"data"];
                       
            //for local notification
            UIApplication* app = [UIApplication sharedApplication];
            if ([count intValue] > 0 && (app.applicationState == UIApplicationStateBackground) )
            {
                if ([app.delegate respondsToSelector:@selector(createLocalNotification:)]) {
                    NSLog(@"backgroud:connectionDidFinishLoading:notify");
                    [app.delegate createLocalNotification:[count intValue]];
                }
            }
        }
    }
    
    [_remindData setData:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"请求网络失败:%@",error);
}

-(void)afterGetNewRemindSucessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request
{
    NSNumber* count = [jsonDict valueForKey:@"data"];

    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    NSDictionary* info = request.userInfo;
    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict setObject:count forKey:@"count"];
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    
    [notifyDict setObject:NewRemendNotification forKey:@"postNotificationName"];
    
    [self postNotificationWithObject:notifyDict];
}

-(void)afterGetNewRemindFailed:(ASIHTTPRequest*)request
{
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [notifyDict setObject:[NSNumber numberWithInt:request.tag] forKey:@"object"];
    [notifyDict setObject:NewRemendFaildedNotification forKey:@"postNotificationName"];
    
    [self postNotificationWithObject:notifyDict];
}
-(void)startGetMyQuizeListWithSender:(id)sender param:(NSDictionary*)param page:(NSInteger)page
{
    if (sender) {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    NSString* url = [NSString stringWithFormat:@"%@&uid=%@", HttpAPI_MyQuizeList, uid];
    
    if ( param && [param count] > 0)
    {
        for (id key in param)
        {
            url = [url stringByAppendingFormat:@"&%@=%@", key, [param valueForKey:key]];
        }
    }

    [codeArray addObject:url];
    
    [codeArray addObject:url];
    [self startAPIRequest:sender withAPICode:codeArray pagename:@"page" pagevalue:page countname:nil countvalue:0 args:nil stage:Stage_MyQuestionList otherUserInfo:nil headerInfo:nil];

}
-(void)startCommentListV2WeiboWithSender:(id)sender ID:(NSString*)mID count:(NSInteger)countPerPage page:(NSInteger)npage max_id:(NSString*)maxID args:(NSArray*)args
{
    if (sender) {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableDictionary* userDict = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString* httpAPI = HttpAPIV2_CommentListWeibo;
    NSMutableArray* orderArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString* token = [self.oAuthData objectForKey:LoginReturnKeyV2_Token];
    if (token) {
        [dict setObject:token forKey:OAUTH2_TOKEN];
        [orderArray addObject:OAUTH2_TOKEN];
    }
    
    if (mID) {
        NSString* idKey = @"id";
        [dict setObject:mID forKey:idKey];
        [orderArray addObject:idKey];
    }
    
    if (maxID) {
        NSString* idKey = @"max_id";
        [dict setObject:maxID forKey:idKey];
        [orderArray addObject:idKey];
        countPerPage += 1;
        [userDict setObject:[NSNumber numberWithBool:YES] forKey:RequsetRemoveFirst];
    }
    
    if (countPerPage>0) {
        NSString* idKey = @"count";
        [dict setObject:[NSString stringWithFormat:@"%d",countPerPage] forKey:idKey];
        [orderArray addObject:idKey];
    }
    
    if (sender) {
        [userDict setObject:sender forKey:RequsetSender];
    }
    [userDict setObject:[NSString stringWithFormat:@"%d",npage] forKey:RequsetPage];
    [userDict setValue:[NSDate date] forKey:RequsetDate];
    if (args) {
        [userDict setValue:args forKey:RequsetArgs];
    }
    CommentDataList* datalist = [[DataCenter getInstance]commentList];
    [userDict setValue:datalist forKey:RequsetDataList];
    [userDict setValue:[NSNumber numberWithInt:RequestType_List] forKey:RequsetType];
    [self startHttpAPIRequestV2:@"GET" data:dict order:orderArray api:httpAPI stage:Stage_RequestV2_CommentListWeibo userInfo:userDict headerDict:nil needSmallLogin:NO bInback:NO];
}

-(void)afterCommentListWeiboSuccessed:(NSDictionary*)jsonDict userRequst:(ASIHTTPRequest*)request
{
    [self afterDefaultSuccessed:jsonDict userRequst:request dataname:@"comments"];
}

-(void)afterCommentListWeiboFailed:(ASIHTTPRequest*)request
{
    [self afterFailed:request];
}
-(void)startGetExpertInfoWithSender:(id)sender args:(NSArray*)args
{
    if (sender) 
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    NSString* url = [NSString stringWithFormat:@"%@&uid=%@", HttpAPI_ExpertInfo, [args objectAtIndex:0]];
    [codeArray addObject:url];
    
    [self startAPIRequest:sender withAPICode:codeArray pagename:nil pagevalue:0 countname:nil countvalue:0 args:args stage:Stage_ExpertInfo otherUserInfo:nil headerInfo:nil];
}
-(void)afterGetExpertInfoSucessed:(NSDictionary*)jsonDict userRequest:(ASIHTTPRequest *)request
{
    //    [self afterDefaultSuccessed:jsonDict userRequst:request dataname:@"data"];
    CommentDataList* DataList = [[DataCenter getInstance] infoList];
//    NSMutableArray* dataID = [[DataCenter getInstance] expertID];
    NSDictionary* info = request.userInfo;
    NSArray* dataID = [info objectForKey:RequsetArgs];
    NSMutableArray* expertArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSDictionary* dataDcit = [jsonDict valueForKey:@"data"];
    
    DataModel* expertObject = [[DataModel alloc] initWithJsonDictionary:dataDcit];
    [mSubjectID release], mSubjectID = nil;
    mSubjectID = [[expertObject valueForKey:@"subject_id"] copy];
    [expertArray addObject:expertObject];
    [expertObject release];
    
    [DataList refreshCommnetContents:expertArray IDList:dataID];
    [expertArray release];
    NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:3];
    

    NSNumber* requestStage = [NSNumber numberWithInt:request.tag];
    id sender = [info objectForKey:RequsetSender];
    if (sender) {
        [notifyDict setObject:sender forKey:@"object"];
    }
    NSMutableDictionary* notifyinfodict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDate* date = [info objectForKey:RequsetDate];
    if (date) {
        [notifyinfodict setObject:date forKey:@"date"];
    }
    
    [notifyinfodict setObject:requestStage forKey:@"stage"];
    [notifyinfodict addEntriesFromDictionary:info];
    
    [notifyDict setObject:notifyinfodict forKey:@"userInfo"];
    [notifyDict setObject:ExpertDetailsInfoNotification forKey:@"postNotificationName"];
    [self postNotificationWithObject:notifyDict];
}
-(void)startGetSettingInfoWithSender:(id)sender
{
    if (sender) 
    {
        sender = [NSNumber numberWithInt:((int)sender)];
    }
    NSString* uid = [self.oAuthData objectForKey:LoginReturnKey_User_id];
    
    if (!uid) 
    {
        return;
    }
    NSMutableArray* codeArray = [NSMutableArray arrayWithCapacity:1];
    
    NSString* url = [NSString stringWithFormat:@"%@&uid=%@", HttpAPI_SettingInfo, uid];
    [codeArray addObject:url];
    [self startAPIRequest:sender withAPICode:codeArray pagename:nil pagevalue:0 countname:nil countvalue:0 args:nil stage:Stage_SettingInfo otherUserInfo:nil headerInfo:nil];

}
-(void)afterGetSettingInfoSucessed:(NSDictionary*)jsonDict userRequest:(ASIHTTPRequest *)request
{
//    NSDictionary* info = request.userInfo;
    NSDictionary* dataDcit = [jsonDict valueForKey:@"data"];
    
    if (!dataDcit || ![dataDcit isKindOfClass:[NSDictionary class]]) 
    {
        return;
    }
    NSString* edc_date = [dataDcit objectForKey:@"edc_date"];
    NSString* birth_date = [dataDcit objectForKey:@"birth_date"];
    NSString* baby_name = [dataDcit objectForKey:@"baby_name"];
    
    if (edc_date&&![edc_date isEqualToString:@""]) 
    {
        NSDictionary* dict = [NSDictionary dictionaryWithObject:edc_date forKey:@"mDate"];
        [[MessageManager getInstance]removeUserSettinginfo];
        [[MessageManager getInstance] saveUserSetting:dict];
    }
    
    if (birth_date&&![birth_date isEqualToString:@""]) 
    {
        NSString* gender = [dataDcit objectForKey:@"gender"];
        

        NSArray* values = [NSArray arrayWithObjects:birth_date, gender, baby_name, nil];
        NSArray* keys = [NSArray arrayWithObjects:@"mDate", @"gender", @"baby_name", nil];
        NSDictionary* dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        [self removeUserSettinginfo];
        [self saveUserSetting:dict];
        NSMutableDictionary* notifyDict = [NSMutableDictionary dictionaryWithCapacity:1];
        [notifyDict setObject:SettingSuccessGetNotification forKey:@"postNotificationName"];
        [self postNotificationWithObject:notifyDict];
        
    }

}
@end

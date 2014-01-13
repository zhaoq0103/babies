//
//  defines.h
//  SinaNews
//
//  Created by shieh fabo on 11-9-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import <SystemConfiguration/SystemConfiguration.h>
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "ProjectLogUploader.h"

#pragma mark - 手机物理参数
// 是否高清屏
#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
// 是否iPad
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
// 是否模拟器
#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

// 屏幕尺寸
//1. common 
#define DeviceScreenWidth  [UIScreen mainScreen].bounds.size.width
#define DeviceScreenHeight  [UIScreen mainScreen].bounds.size.height
#define StatusBarHeight                     20
#define appNavigationBarHeight              44
#define appTabBarHeight                     49

//2.hompage
#define appSearchBarHeight                  44
#define QACellContentLineSpacing            7.0

// 背景图片
#define controllerBKImage                   @"bg.png"


#pragma mark - 外部 NSString 常量
extern NSString *NewsTable;
extern NSString *WeiboTable;
extern NSString *RelationTable;

//extern NSString* Key_Login_Username;
//extern NSString* Key_Login_Password;

extern NSString* PushEnabledKey;
extern NSString* OfflineWifiEnabledKey;
extern NSString* Offline3GEnabledKey;
extern NSString* PushStartupFailedNotification;
extern NSString* PushValueChangedNotification;
extern NSString* DeviceTokenSendedKey;
//extern NSString* RegKey_UserData_TokenDict;
//extern NSString* RegKey_UserData_LoginDict;
extern NSString* WeiboDefaultGroupName;
extern NSString* loginedKey;
extern NSString* unloginedKey;

extern NSString* Key_CustomWeatherCityID;


#pragma mark - Others

#define HttpRequstRefreshTime (60*5)

#define UpdateApi                                           @"http://m.sina.com.cn/js/5/20120514/31.json"

#define BabyWriteActionLog(x) [[ProjectLogUploader getInstance] writeDataString:x];

#define     APP_SINABABY_FIRSTRUN   @"FirstRun"


#pragma mark - 通知 常量
// from MessageManager moved here
#define LoginStageChangedNotification                       @"LoginStageChangedNotification"
#define LoginSuccessedNotification                          @"LoginSuccessedNotification"
#define LoginFailedNotification                             @"LoginFailedNotification"
#define LogoutSuccessedNotification                         @"LogoutSuccessedNotification"

#define NavObjectsAddedNotification                         @"NavObjectsAddedNotification"
#define NavObjectsFailedNotification                        @"NavObjectsFailedNotification"

#define NetworkPublishSuccessNotification                   @"NetworkPublishSuccessNotification"
#define NetworkPublishFaildedNotification                   @"NetworkPublishFaildedNotification"

#define ExpertReplySuccessNotification                   @"ExpertReplySuccessNotification"
#define ExpertReplyFaildedNotification                   @"ExpertReplyFaildedNotification"

#define UpdateCheckedNotification                           @"UpdateCheckedNotification"

#define LastTipUpdateVersion                                @"LastTipUpdateVersion"

#define ExpertDetailsInfoNotification                       @"ExpertDetailsInfoNotification"
#define ExpertDetailsInfoFaildedNotification                @"ExpertDetailsInfoFaildedNotification"

#define ExpertMsgNotification                               @"ExpertMsgNotification"
#define ExpertMsgFaildedNotification                        @"ExpertMsgFaildedNotification"

#define ExperClassNotification                              @"ExperClassNotification"
#define ExperClassFaildedNotification                       @"ExperClassFaildedNotification"

#define ExpertbyGroupNotification                           @"ExpertbyGroupNotification"
#define ExpertbyGroupFaildedNotification                    @"ExpertbyGroupFaildedNotification"
#define SearchArrayNotification                             @"SearchArrayNotification"
#define SearchArrayFaildedNotification                      @"SearchArrayFaildedNotification"

#pragma mark  3.search page 
#define SearchHotwordsNotification                          @"SearchHotwordsNotification"
#define SearchHotwordsFaildedNotification                   @"SearchHotwordsFaildedNotification"

#define NeedReplyQuestionNotification                       @"NeedReplyQuestionNotification"
#define NeedReplyQuestionFaildedNotification                @"NeedReplyQuestionFaildedNotification"

#define ReplyedAnQuestionNotification                       @"ReplyedAnQuestionNotification"
#define ReplyedAnQuestionFaildedNotification                @"ReplyedAnQuestionFaildedNotification"

#define SearchNotification                                  @"SearchNotification"
#define SearchFaildedNotification                           @"SearchFaildedNotification"

#define UserInfoSuccessGetNotification                      @"UserInfoSuccessGetNotification"
#define UserInfoSuccessGetFaildedNotification               @"UserInfoSuccessGetFaildedNotification"

#define SearchWordsNotification                             @"SearchWordsNotification"
#define SearchWordsFaildedNotification                      @"SearchWordsFaildedNotification"

#define QuizeNotification                                   @"QuizeNotification"
#define QuizeFaildedNotification                            @"QuizeFaildedNotification"

#define AddFavoriteFaildedNotification                      @"AddFavoriteFaildedNotification"
#define AddFavoriteNotification                             @"AddFavoriteNotification"

#define SettingFaildedNotification                          @"SettingFaildedNotification"
#define SettingNotification                                 @"SettingNotification"

#define NewRemendNotification                               @"NewRemendNotification"
#define NewRemendFaildedNotification                        @"NewRemendFaildedNotification"

#define NewRemendForSetNotification                         @"NewRemendForSetNotification"
#define NewRemendForSetFaildedNotification                  @"NewRemendForSetFaildedNotification"

#define SettingClearNotification                            @"SettingClearNotification"
#define SettingClearFaildedNotification                     @"SettingClearFaildedNotification"
#define SettingSuccessGetNotification                     @"SettingSuccessGetNotification"
#define CommentSuccessNotification                     @"CommentSuccessNotification"
#define ExpertCommentSuccessNotification                     @"ExpertCommentSuccessNotification"
//static int startLocationUpdateCount = 0;

#pragma mark - NSString 常量

#define Key_Login_Username  @"Login_Username"
#define Key_Login_Password  @"Login_Password"
#define RegKey_AccountOrder  @"accountorder"
#define RegKey_CurrentAccount  @"currentaccount"
#define RegKey_UserData_TokenDict  @"tokendict"
#define RegKey_UserData_LoginDict  @"logindict"

#define Key_User_Setting  @"usersetting"
//#define Login_APPVALUE = @"1705379563";
#define Login_APPVALUE  @"2746688278"
#define Login_APPSECRET  @"b4155d06529ff64b67105815925c89e6"
//#define Login_APPSECRET = @"4f756991dd74b1f5ddbcbfdfb143a981";
#define Login_HMACSHA1TYPE  @"HMAC-SHA1"
#define Login_HMACSHA1KEY  @"372d6e130db71fb327d7277f5b8d6cac&"

#define OAUTH_CONSUMER_KEY  @"oauth_consumer_key"
#define OAUTH_NONCE  @"oauth_nonce"
#define OAUTH_SIGNATURE_METHOD  @"oauth_signature_method"
#define OAUTH_SIGNATURE  @"oauth_signature"
#define OAUTH_TIMESTAMP  @"oauth_timestamp"
#define OAUTH_VERSION @"oauth_version"
#define OAUTH_TOKEN  @"oauth_token"
#define OAUTH_TOKEN_SECRET  @"oauth_token_secret"
#define X_AUTH_STATUS  @"status"
#define X_AUTH_MODE  @"x_auth_mode"
#define X_AUTH_PASSWORD  @"x_auth_password"
#define X_AUTH_USERNAME  @"x_auth_username"
#define X_AUTH_UID  @"user_id"

#define OAUTH2_Client_ID  @"client_id"
#define OAUTH2_Client_Secret  @"client_secret"
#define OAUTH2_Grant_Type  @"grant_type"
#define OAUTH2_Username  @"username"
#define OAUTH2_Password @"password"
#define OAUTH2_TOKEN  @"access_token"
#define OAUTH2_Source  @"source"

#define FAVORITE_TYPE  @"musicvideo"

#define LoginReturnKey_Token OAUTH_TOKEN
#define LoginReturnKey_Token_secret OAUTH_TOKEN_SECRET
#define LoginReturnKey_User_id                                          @"uid"
#define Subject_id                                                      @"sid"

#define LoginReturnKeyV2_Token OAUTH2_TOKEN
#define TokenRefreshTime (60*60*24)
#define RequsetSender  @"RequsetSender"
#define RequsetDate  @"RequsetDate"
#define RequsetArgs  @"RequsetArgs"
#define RequsetPage  @"RequsetPage"
#define RequsetRemoveFirst  @"RequsetRemoveFirst"
#define RequsetDataList  @"RequsetDataList"
#define RequsetOrder  @"RequsetOrder"
#define RequsetError  @"RequsetError"
#define RequsetType  @"RequsetType"
#define RequsetLastDate  @"RequsetLastDate"
#define RequsetDateKey  @"RequsetDateKey"
#define RequsetDateFormatter  @"RequsetDateFormatter"


#pragma mark - 接口 参数

#pragma mark 1.Weibo interface

#define HttpAPI_Login                                       @"http://api.t.sina.com.cn/oauth/access_token"
#define HttpAPIV2_Login                                     @"https://api.weibo.com/oauth2/access_token"
#define HttpAPI_Verifier                                    @"http://api.t.sina.com.cn/oauth/authorize"
#define HttpAPI_Publish                                     @"http://api.t.sina.com.cn/statuses/update.json"
//#define HttpAPIV2_Publish                                 @"https://api.weibo.com/2/statuses/update.json";
#define HttpAPIV2_Publish                                   @"https://api.weibo.com/2/statuses/update.json"

#define HtppAPIV2_FriendshipShow                            @"https://api.weibo.com/2/friendships/show.json"
#define HttpAPIV2_CommentListWeibo                          @"https://api.weibo.com/2/comments/show.json"
#define HttpAPIV2_RepostWeibo                               @"https://api.weibo.com/2/statuses/repost.json"
#define HttpAPIV2_CommentWeibo                              @"https://api.weibo.com/2/comments/create.json"
#define HttpAPIV2_UserInfo                                  @"https://api.weibo.com/2/users/show.json"

#pragma mark 2.SinaBaby interface
/************************************new interface **********************************************************/
//down load
//1.get expert categories
#define HttpAPI_ExpertClass                                 @"http://platform.sina.com.cn/baby_talk/get_cates?app_key=1490136503"

//2.get recommend expert
#define HttpAPI_ExpertRecommend                             @"http://platform.sina.com.cn/baby_talk/get_recommend_experts?app_key=1490136503"
#define HttpAPI_ExpertRecommend_Acitved                     @"http://platform.sina.com.cn/baby_talk/get_expert_by_reply_time?app_key=1490136503"

//3.get the category expert
#define HttpAPI_ExpertMsg                                   @"http://platform.sina.com.cn/baby_talk/get_experts?app_key=1490136503"

//4.get expert detail
#define HttpAPI_ExpertInfo                                  @"http://platform.sina.com.cn/baby_talk/get_expert_info?app_key=1490136503"

//5.get expert all answer
#define HttpAPI_AllAnswer                                   @"http://platform.sina.com.cn/baby_talk/get_answers?app_key=1490136503"

//6.jie duan (fen lei)sou suo
#define HttpAPI_SearchGroup                                 @"http://platform.sina.com.cn/baby_talk/get_search_cates?app_key=1490136503"

//7.weibo sou suo
#define HttpAPI_Search                                      @"http://platform.sina.com.cn/baby_talk/get_search?app_key=1490136503"
//#define HttpAPI_SearchQuize                                 @"http://platform.sina.com.cn/baby_talk/get_search?app_key=1490136503"

//8.expert sou suo
#define HttpAPI_SearchName                                  @"http://platform.sina.com.cn/baby_talk/search_expert?app_key=1490136503"


//9.all Qestion of user
#define HttpAPI_MyQuizeList                                 @"http://platform.sina.com.cn/baby_talk/get_asks?app_key=1490136503"

//10.get user info
#define HttpAPI_SettingInfo                                 @"http://platform.sina.com.cn/baby_talk/get_user_setting?app_key=1490136503"

//11.get user favorite
#define HttpAPI_FavoriteList                                @"http://platform.sina.com.cn/baby_talk/get_favorites?app_key=1490136503"

//12.get user remind
#define HttpAPI_Newremind                                   @"http://platform.sina.com.cn/baby_talk/get_new_answer_count?app_key=1490136503"

//13.get hot word
#define HttpAPI_HotwordsTop                                 @"http://platform.sina.com.cn/baby_talk/keyword_top?app_key=1490136503"

//14.get need reply
#define HttpAPI_QuestionsNeedReply                          @"http://platform.sina.com.cn/baby_talk/vip_get_asks?app_key=1490136503"

//15.get all QA about all expert
#define HttpAPI_AllQAInWeibo                                @"http://platform.sina.com.cn/baby_talk/ask_list?app_key=1490136503"

//16.recommend QA
#define HttpAPI_RecommendQA                                 @"http://platform.sina.com.cn/baby_talk/get_recommend_ask?app_key=1490136503"


//up load
//1.user setting
#define HttpAPI_Setting                                     @"http://platform.sina.com.cn/baby_talk/update_user_setting?app_key=1490136503"

//2.clear user setting
#define HttpAPI_ClearSetting                                @"http://platform.sina.com.cn/baby_talk/clear_user_setting?app_key=1490136503"

//3.send a question
#define HttpAPI_QuizeAdd                                    @"http://platform.sina.com.cn/baby_talk/add_ask?app_key=1490136503"

//4.add favorite
#define HttpAPI_Favorite                                    @"http://platform.sina.com.cn/baby_talk/add_favorite?app_key=1490136503"

//5.up load hot word
#define HttpAPI_Send2ServerHotword                          @"http://platform.sina.com.cn/baby_talk/upload_keyword?app_key=1490136503"

//6.reply question
#define HttpAPI_ReplyAQuestion                              @"http://platform.sina.com.cn/baby_talk/vip_add_answer?app_key=1490136503"
/************************************end of new interface**********************************************************/

#pragma mark - 数据库

#define ContentDatabase                                     @"content.db"
#define OfflineDatabase                                     @"feed.db"
#define OfflineDatabaseNM                                   @"feed"

#define OfflineDBFeedID                                     @"feedid"
#define OfflineDBFeedUrl                                    @"feedurl"
#define OfflineDBFeedTime                                   @"feedtime"
#define OfflineDBFeedKind                                   @"feedkind"
#define OfflineDBFeedTitle                                  @"feedtitle"
#define OfflineDBFeedResult                                 @"feedresult"


#pragma mark - Title String
#define QuizeListTitle                                      @"我的问题"


/****************************UMeng tongji****************************************************************************************/
 
#define kAppKeyFromUMeng                                    @"5226cbfd56240b1660073e0f"

/****************************End of UMeng tongji*********************************************************************************/

#define  OCSafeRelease(__v)          if((__v) != nil){[(__v) release]; (__v) = nil;}








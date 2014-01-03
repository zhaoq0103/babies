//
//  MessageManager.h
//  SinaNews
//
//  Created by shieh fabo on 11-9-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class ASIHTTPRequest;
@class ASINetworkQueue;
@class MKReverseGeocoder;
@class MKPlacemark;
@class CommentDataList;


enum RequestType
{
    RequestType_List,
    RequestType_content
};

enum LoginStage
{
    Stage_Login,
    Stage_LoginV2,
    Stage_LoginV2_Small,
    Stage_Verifier,
    Stage_Request_Publish,
    Stage_RequestV2_Publish,
    Stage_RealLoginV2,
    Stage_ExpertMsg,
    Stage_ExpertClass,
    Stage_ExpertbyGroup,
    Stage_SearchGroup,//10
    Stage_Search,
    Stage_SearchCate,
    Stage_QuizeAdd,
    Stage_AllAns,
    Stage_RequestV2_RepostWeibo,
    Stage_RequestV2_CommentWeibo,
    Stage_Favorite,
    Stage_Setting,
    Stage_ClearSet,
    Stage_NewRemind,
    Stage_RequestV2_CommentListWeibo,
    Stage_ExpertInfo,
    Stage_SearchExpert,
    Stage_SettingInfo,//24
    Stage_GetHotwordsTop,
    STage_UserInfo,
    STage_RelativeQAs,
    STage_QuestionNeedsReply,
    STage_ExpertReplyQ,
    Stage_MyQuestionList, //30
    Stage_ExpertMsg_Active
};

enum RequestError
{
    RequestError_Unknown,
    RequestError_List_Not_Exists,
    RequestError_User_Not_Exists
};


@class MessageManager;

@protocol MessageManagerOfflineDelegate <NSObject>

-(void)manager:(MessageManager*)manager OfflineWithRequest:(ASIHTTPRequest*)request;

@end

@interface MessageManager : NSObject<CLLocationManagerDelegate> {
    NSDictionary* mLoginData;
    NSDictionary* mOAuthData;
    ASINetworkQueue* mLoginQueue;
    ASINetworkQueue* mDownloadQueue;
    ASINetworkQueue* mOtherQueue;
    CLLocationManager* mLocManager;
    CLLocation* myLocation;
    NSInteger myLocationChanged;
    MKReverseGeocoder *reverseGeocoder;
    MKPlacemark *locPlacemark;
    NSLock* mLock;
    BOOL bSmallLogining;
    NSMutableArray* mWeiboRequestList;
    NSString* loginedGroupID;
    id offlineDelegate;

    NSMutableArray* emotionArray;
    NSString*       mSubjectID;
}

@property(assign)id<MessageManagerOfflineDelegate> offlineDelegate;
@property(assign)BOOL hasLogined;
@property(assign)BOOL bAnExpertLogined;
//@property(assign)NSString* loginedAccount;
//@property(assign)NSString* loginedID;
-(NSString*)loginedAccount;
-(NSString*)loginedID;
+(id)getInstance;
-(void)startPushRequest:(BOOL)bStart token:(NSString*)deviceToken;
//-(NSArray*)curWeiboIDListWithLogined:(BOOL)logined;

-(void)startCheckUpdate:(BOOL)forceShow;
-(BOOL)hasNewVersion:(NSString*)version;
-(void)clear;
-(void)startLogin:(NSDictionary*)loginData;
-(void)startRealLogin:(NSDictionary*)loginDaata;
-(void)startLoginUid:(NSString*)userID;
-(void)startLogout;

-(void)startPublishV2:(NSString*)aStatus picUrl:(NSString*)url;
-(void)startSmallLogin;

-(void)startGetExpertMsgWithSender:(id)sender args:(NSArray*)args;
-(void)startGetActiveExpertMsgWithSender:(id)sender args:(NSArray*)args page:(NSInteger)page;
-(void)startGetExpertClassWithSender:(id)sender args:(NSArray *)args;
-(void)startGetExpertbyGroupWithSender:(id)sender args:(NSArray *)args page:(NSInteger)page;
-(void)startGetSearchGroupWithSender:(id)sender;
-(void)startGetHotwordsWithSender:(id)sender;
//-(void)startSearchWithSender:(id)sender args:(NSArray *)args;
-(void)startSearchCateIdWithSender:(id)sender args:(NSDictionary *)args page:(NSInteger)page;
-(void)startSearchWordsWithSender:(id)sender args:(NSString *)keywords page:(NSInteger)page;
-(void)startaddQuizeWithSender:(id)sender args:(NSString*)Content expert:(NSString*)expert_uid anonymouse:(NSString*)anonymouse;
- (BOOL)isDataSourceAvailable;
-(void)startGetAllAnswerofExpertWithSender:(id)sender param:(NSDictionary*)param page:(NSInteger)page;
-(void)startGetAllQAInWeiboWithSender:(id)sender page:(NSInteger)page;
-(void)startRepostV2WeiboWithID:(NSString*)mID content:(NSString*)aText;
-(void)startCommentV2WeiboWithID:(NSString*)mID content:(NSString*)aText;
-(void)startAddFavoriteWithID:(NSString*)mID;
-(void)startGetFavoriteListWithSender:(id)sender page:(NSInteger)page;
-(void)startAddSettingWithDate:(NSString*)mDate gender:(NSString*)gender baby_name:(NSString*)baby_name;
-(void)saveUserSetting:(NSDictionary*)dict;
-(void)removeUserSettinginfo;
-(id)readUserSettinginfo;
-(void)startClearSetting;
-(void)startGetNewRecomendWithSender:(id)sender;
-(void)startGetNewRecomendBackground;
-(void)startGetMyQuizeListWithSender:(id)sender param:(NSDictionary*)param page:(NSInteger)page;
-(void)startCommentListV2WeiboWithSender:(id)sender ID:(NSString*)mID count:(NSInteger)countPerPage page:(NSInteger)npage max_id:(NSString*)maxID args:(NSArray*)args;
-(void)startGetExpertInfoWithSender:(id)sender args:(NSArray*)args;
-(void)startSearchbyWordWithSender:(id)sender args:(NSString *)args page:(NSInteger)page;
-(void)startGetSettingInfoWithSender:(id)sender;
-(void)startGetUserInfo;
-(void)startGetRelativeQAsWithSender:(id)sender args:(NSDictionary*)params page:(NSInteger)page;
//send searchword to server
-(void)sendSearchword2ServerWithSender:(id)sender args:(NSString *)args;
-(void)startGetQuestionsNeedReplyWithSender:(id)sender page:(NSInteger)page;
-(void)startReplyQuestionWithObject : (NSDictionary*)dict;
@end

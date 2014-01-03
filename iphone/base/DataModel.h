//
//  DataModel.h
//  SinaNews
//
//  Created by shieh exbice on 11-7-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//DataModelType_Normal
#define NEWS_ID @"id"
#define NEWS_URL @"url"
#define NEWS_CHANNEL @"channel-id"
#define NEWS_CREATETIME @"createdatetime"
#define NEWS_TITLE @"title"
#define NEWS_LEVEL @"level"
#define NEWS_SHORTTITLE @"short_title"
#define NEWS_MEDIA @"media"
#define NEWS_CONTENT @"content"
#define NEWS_TOTALCOMMENTS @"total_comments"
#define NEWS_Custom_ReadState @"custom_readstate"

#define NEWS_IMAGES_URL @"images|>0|>url"

#define NEWS_TYPE @"type"
#define NEWS_IMG @"img"
#define NEWS_VID @"vid"
#define NEWS_TIMELEN @"time_len"
#define NEWS_MEDIANAME @"media_name"
#define NEWS_FIRSTDATE @"first_date"
#define NEWS_COLUMNID @"column_id"
#define NEWS_COLUMNNAME @"column_name"
#define NEWS_COLUMNURL @"column_url"

#define NEWS_VideoVid @"video|>ipad"
#define NEWS_VideoImg @"video|>thumb"

//newscontent
#define EXPERT_UID @"uid"
#define EXPERT_NAME @"name"
#define EXPERT_HOSPITAL @"hospital"
#define EXPERT_POSITION @"position"
#define EXPERT_DESC @"description"
#define EXPERT_INTRO @"intro"
#define EXPERT_CATEID @"cate_id"
#define EXPERT_AREA @"expert_area"
#define EXPERT_SUBJECTID @"subject_id"
#define EXPERT_WEEKDAY @"weekday"
#define EXPERT_PROFILEIMG @"profile_image_url"
#define EXPERT_DISABLE @"disable"

#define Quize_TalkType @"talk_type"
#define Quize_CreateAt @"created_at"
#define Quize_Content @"text"
#define Quize_User @"user"
#define Quize_User_ScreenName @"screen_name"
#define Quize_User_Avatar @"profile_image_url"
#define Quize_RepostCount @"reposts_count"
#define Quize_CommentCount @"comments_count"
#define Quize_WeiboMid @"mid"
#define Quize_Verified @"verified"


#define WeiboObject_CreateDate @"created_at"
#define WeiboObject_id @"id"
#define WeiboObject_idstr @"idstr"
#define WeiboObject_text @"text"
#define WeiboObject_source @"source"
#define WeiboObject_comments_count @"comments_count"
#define WeiboObject_reposts_count @"reposts_count"
#define WeiboObject_favorited @"favorited"
#define WeiboObject_truncated @"truncated"
#define WeiboObject_in_reply_to_status_id @"in_reply_to_status_id"
#define WeiboObject_in_reply_to_user_id @"in_reply_to_user_id"
#define WeiboObject_in_reply_to_screen_name @"in_reply_to_screen_name"
#define WeiboObject_thumbnail_pic @"thumbnail_pic"
#define WeiboObject_bmiddle_pic @"bmiddle_pic"
#define WeiboObject_original_pic @"original_pic"
#define WeiboObject_geo @"geo"
#define WeiboObject_mid @"mid"
#define WeiboObject_user @"user"

#define WeiboUserObject_id @"id"
#define WeiboUserObject_idstr @"idstr"
#define WeiboUserObject_screen_name @"screen_name"
#define WeiboUserObject_name @"name"
#define WeiboUserObject_gender @"gender"
#define WeiboUserObject_avatar_large @"avatar_large"
#define WeiboUserObject_verified @"verified"
#define WeiboUserObject_verified_type @"verified_type"
#define WeiboUserObject_province @"province"
#define WeiboUserObject_city @"city"
#define WeiboUserObject_location @"location"
#define WeiboUserObject_description @"description"
#define WeiboUserObject_url @"url"
#define WeiboUserObject_profile_image_url @"profile_image_url"
#define WeiboUserObject_domain @"domain"
#define WeiboUserObject_gender @"gender"
#define WeiboUserObject_followers_count @"followers_count"
#define WeiboUserObject_friends_count @"friends_count"
#define WeiboUserObject_statuses_count @"statuses_count"
#define WeiboUserObject_favourites_count @"favourites_count"
#define WeiboUserObject_created_at @"created_at"
#define WeiboUserObject_following @"following"
#define WeiboUserObject_allow_all_act_msg @"allow_all_act_msg"
#define WeiboUserObject_geo_enabled @"geo_enabled"
#define WeiboUserObject_verified @"verified"
#define WeiboUserObject_retweeted_status @"retweeted_status"

#define WeiboCommentObject_created_at @"created_at"
#define WeiboCommentObject_id @"id"
#define WeiboCommentObject_text @"text"
#define WeiboCommentObject_source @"source"
#define WeiboCommentObject_user @"user"
#define WeiboCommentObject_mid @"mid"
#define WeiboCommentObject_idstr @"idstr"
#define WeiboCommentObject_reply_comment @"reply_comment"

enum QuizeViewType 
{
    QuizeViewType_QuizeAdd,
    QuizeViewType_Comment,
    QuizeViewType_Weiborepost,
    QuizeViewType_WeiboPublish,
    QuizeViewType_Reply
};
enum DataModelType
{
    DataModelType_News,
//    DataModelType_Picture,
//    DataModelType_Content,
//    DataModelType_NewsComment,
//    DataModelType_NewsFavorite
    DataModelType_Single, //only ask
    DataModelType_Pairs //ask and answer
};
enum SearchType 
{
    SearchbyGroup = 66,
    SearchbyWords,
    ExpertAllAns,
    FavoriteList,
    QuizeList,
    RelativeQA
};
enum CellType
{
    CellAsk,
    CellAns,
    CellSingle
};

@interface ImageURLData : NSObject {
@private
    NSString* _imageURL;
    CGSize _imageSize;
    NSString* _imageTitle;
    UIImage* _image;
}

@property(retain)NSString* imageURL;
@property(assign)CGSize imageSize;
@property(retain)NSString* imageTitle;
@property(retain)UIImage* image;
@end



@class CommentDataList;

@interface DataModel : NSObject
{
@private
    NSDictionary* mNewsData;
    NSInteger mNewsType;
    NSMutableDictionary* mUserInfo;
}
@property(assign)NSInteger newsType;
@property(assign)NSInteger tag;
@property(assign,readonly)NSString* dataString;
@property(assign,readonly)NSData* data;
@property(assign)CommentDataList* parentList;
@property(retain)NSArray* IDListInParentList;
@property(assign)NSInteger rowInParentList;

+(DataModel*)objectWithJsonDict:(NSDictionary*)aJson;
+(DataModel*)objectWithJsonString:(NSString*)aJson;
-(id)initWithDataModel:(DataModel*)object;
-(id)initWithJsonDictionary:(NSDictionary*)aJson;
-(id)initWithJsonString:(NSString*)aJson;
-(id)initWithNewsData:(NSData*)aData;

-(NSDictionary*)dataDict;
-(NSString*)valueForKey:(NSString*)newsKey;
-(void)setValue:(id)value forKey:(NSString *)key;
-(void)setUserInfoValue:(id)value forKey:(NSString *)key;
-(id)userInfoValueForKey:(NSString*)newsKey;
-(NSArray*)imageURLDataList;
-(void)refreshToDataBase;

@end

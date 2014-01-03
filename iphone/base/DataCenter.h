//
//  DataCenter.h
//  SinaNews
//
//  Created by shieh exbice on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommentDataList.h"

@interface DataCenter : NSObject
{
    NSMutableArray* expertID;
    CommentDataList* expertList;
//    NSArray* classIDList;
    CommentDataList* classList;
    NSMutableArray* GroupID;
    CommentDataList* expertbyGroupList;
    
    NSArray* searchgroupID;
    CommentDataList* searchgroupList;
    
    NSArray* searchArgs;
    CommentDataList* searchDateList;
    
    CommentDataList* commentList;
    
    CommentDataList* infoList;
    
    NSArray* searchExpertArray;
    CommentDataList* EsearchDateList;
}

@property(retain)CommentDataList* expertList;
@property(retain)CommentDataList* classList;
@property(retain)NSMutableArray* expertID;
@property(retain)NSMutableArray* expertActived;
//@property(retain)NSArray* classIDList;

@property(retain)CommentDataList* remindList;
@property(retain)NSArray* remindIDList;
@property(retain)NSMutableArray* GroupID;
@property(retain)CommentDataList* expertbyGroupList;
@property(retain)NSArray* searchgroupID;
@property(retain)CommentDataList* searchgroupList;
@property(retain)NSArray* searchArgs;
@property(retain)CommentDataList* searchDateList;
@property(retain)CommentDataList* commentList;
@property(retain)CommentDataList* infoList;
@property(retain)NSArray* searchExpertArray;
@property(retain)CommentDataList* EsearchDateList;

@property(retain)NSArray*                               hotwordsGroupID;

+ (id)getInstance;

@end

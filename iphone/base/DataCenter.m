//
//  DataCenter.m
//  SinaNews
//
//  Created by shieh exbice on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DataCenter.h"
#import "CommentDataList.h"

static DataCenter* s_dataCenter = nil;

@implementation DataCenter

@synthesize expertID, expertList, remindList,remindIDList, classList, expertbyGroupList, GroupID;
@synthesize searchgroupID,searchgroupList ,searchArgs, searchDateList, commentList, infoList;
@synthesize searchExpertArray, EsearchDateList;

+ (id)getInstance
{
	if (s_dataCenter == nil)
	{
		//没有创建则创建
		s_dataCenter = [[DataCenter alloc] init];
	}
	return s_dataCenter;
}

-(id)init
{
    self = [super init];
    if (self) {

        _expertActived = [[NSMutableArray alloc]initWithObjects:@"experts_actived", nil];
        expertID = [[NSMutableArray alloc] init];
        expertList = [[CommentDataList alloc] init];
        
        expertList.dataTableName = @"expertList";
        expertList.countPerPage = 10;
        
        remindList = [[CommentDataList alloc] init];
        remindList.dataTableName = @"remind";
        remindIDList = [[NSArray alloc] initWithObjects:@"remind", nil];
        
        classList = [[CommentDataList alloc]init];
        classList.dataTableName = @"classList";
        classList.countPerPage = 20;
//        classIDList = [[NSArray alloc] initWithObjects:@"expertclass", nil];
        
        expertbyGroupList = [[CommentDataList alloc]init];
        expertbyGroupList.dataTableName = @"expertbyGroupList";
        expertbyGroupList.countPerPage = 20;
        GroupID = [[NSMutableArray alloc]initWithObjects:@"all", nil];
        
        searchgroupList = [[CommentDataList alloc]init];
        searchgroupList.dataTableName = @"searchgroupList";
        searchgroupList.countPerPage = 20;
        
        searchgroupID = [[NSArray alloc]initWithObjects:@"search", nil];
        _hotwordsGroupID = [[NSArray alloc]initWithObjects:@"hotwords", nil];
        
        searchArgs = [[NSArray alloc]initWithObjects:@"search", nil];
        searchDateList = [[CommentDataList alloc]init];
        searchDateList.dataTableName = @"search";
        searchDateList.countPerPage = 30;
        
        commentList = [[CommentDataList alloc]init];
        commentList.dataTableName = @"commentList";
        commentList.countPerPage = 30;
        
        infoList = [[CommentDataList alloc]init];
        infoList.dataTableName = @"infoList";
        infoList.countPerPage = 20;
        
        searchExpertArray = [[NSArray alloc]initWithObjects:@"searchexpert", nil];
        EsearchDateList = [[CommentDataList alloc]init];
        EsearchDateList.dataTableName = @"searchexpert";
        EsearchDateList.countPerPage = 30;

    }
    return self;
}

-(void)dealloc
{
    [commentList release];
    [expertID release];
    [expertList release];
    
    [classList release];
//    [classIDList release];
    
    [remindList release];
    [remindIDList release];

    [GroupID release];
    [expertbyGroupList release];
    
    [searchgroupID release];
    [searchgroupList release];
    [searchArgs release];
    [searchDateList release];
    [infoList release];
    
    [searchExpertArray release];
    [EsearchDateList release];
    
    [_hotwordsGroupID release];
    [_expertActived release];
    
    [super dealloc];
}

@end

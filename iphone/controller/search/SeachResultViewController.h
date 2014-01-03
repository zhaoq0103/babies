//
//  SeachResultViewController.h
//  babyfaq
//
//  Created by PRO on 13-5-27.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "QandATableView.h"

@interface SeachResultViewController : RootViewController 
{

}

@property (retain, nonatomic) QandATableView            *searchResultTable;
@property (retain, nonatomic) IBOutlet UILabel          *nothingFind;

//for search
@property(nonatomic,retain)NSArray*                     searchArgs;
@property(nonatomic,assign)NSInteger                    searchType;
@property(nonatomic,retain)NSString*                    keyWords;
@property(nonatomic, retain)NSString*                   cateid;

@property (nonatomic)NSInteger                          curPage;
@property (nonatomic)NSInteger                          curPageOfOfflineData;

@property(nonatomic, retain)NSMutableArray*             searchResultArray;
@property(nonatomic)NSInteger                           searchResultCount;

@property(nonatomic, retain) IBOutlet UIImageView *noneImg;


//Relative QA, 专题ID
@property(nonatomic,retain)NSString*                    subjectID;

//flag for fenlei sousuo, or fenlei zi sousuo
@property(nonatomic)NSInteger                           searchBarTag;
@end

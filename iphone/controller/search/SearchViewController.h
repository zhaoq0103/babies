//
//  SearchViewController.h
//  babyfaq
//
//  Created by mayanwei on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "RootViewController.h"
#import "SearchList.h"
#import "CustomSearchBar.h"

@interface SearchViewController : RootViewController
{
    BOOL                        _bJieDuanDataReady;
    BOOL                        _bHotwordDataReady;
}

@property(nonatomic, retain) IBOutlet UIScrollView* jieduanSearchList;
@property(nonatomic, retain) IBOutlet UIScrollView* hotwordsSearchList;

@property(nonatomic, retain) NSMutableDictionary*    jieduanData;

@property(nonatomic, retain) NSMutableArray*       hotwordsSearchTimes;
@property(nonatomic, retain) NSMutableArray*       hotwordsValues;

@property (nonatomic)NSInteger              curPageOfOfflineData;

- (IBAction)btnClicked:(id)sender;

@end

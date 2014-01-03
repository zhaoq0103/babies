//
//  BaseTableView.h
//  babyfaq
//
//  Created by PRO on 13-6-9.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@protocol TableViewEvent_Delegate <NSObject>
@optional
-(void)pullDownToRefresh:(UITableView*) tableView;
-(void)pullUpToLoadMoreData:(UITableView*) tableView;

-(void)itemInnerCellClickedAction_PushViewController : (UIViewController*)controller animate:(BOOL) animate;
@end

@interface BaseTableView : UITableView <UITableViewDataSource,UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;	
	BOOL _reloading;
}

@property(nonatomic, assign) id<TableViewEvent_Delegate>    eventDelegate;
@property(nonatomic, retain) NSArray*   sourceData;
@property(nonatomic) BOOL   bNeedRefresh;
@property(nonatomic) BOOL   bIsThereMoreData;


- (void) dataLoadingFinish;

@end

//
//  RootViewController.h
//  babyfaq
//
//  Created by mayanwei on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSearchBar.h"
#import "BaseTableView.h"
#import "Reachability.h"

@interface RootViewController : UIViewController <TableViewEvent_Delegate, Event_Delegate>
{
    CustomSearchBar             *_searchBar;
    UIView*                     _offlineView;
    BOOL                        _uiInited;
}

@property(nonatomic, retain)UIButton*                   footerViewButton;
@property(nonatomic) BOOL                               isOffline;

- (void) showTableViewFooter : (BOOL)bshow;
- (BOOL)isThisNotificationWanted : (NSNotification*) notify;
- (void) hideSearchBarKeyBoard;
- (BOOL) updataUI4LineStatues; //返回网络状态，true 在线， false ,离线

- (void)reloadTableViewDataSource:(BOOL)needDown;//for refresh
@end

//
//  AppDelegate.h
//  babyfaq
//
//  Created by xie shuigeng on 13-5-22.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) Reachability *internetReach;
- (NetworkStatus) netWorkStatus;
@end

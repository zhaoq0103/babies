//
//  TasksViewController.h
//  babyfaq
//
//  Created by PRO on 14-1-3.
//  Copyright (c) 2014年 sina. All rights reserved.
//

#import "RootViewController.h"

@interface TasksViewController : RootViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) NSArray*                   tasksData;

@end

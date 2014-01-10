//
//  TutorTaskViewController.h
//  babyfaq
//
//  Created by PRO on 14-1-2.
//  Copyright (c) 2014年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "TutorSectionModel.h"
#import "TaskModel.h"

@interface TutorTaskViewController : RootViewController<UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView              *tutorTable;
@property (nonatomic)         int                               pageIndex;
@property (nonatomic, retain) TutorSectionModel*                tutorModel;
@property (nonatomic, retain) TaskModel*                        curTask;
@property (nonatomic, retain) NSMutableArray*                   tasksData;

@end

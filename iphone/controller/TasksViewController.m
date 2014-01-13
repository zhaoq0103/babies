//
//  TasksViewController.m
//  babyfaq
//
//  Created by PRO on 14-1-3.
//  Copyright (c) 2014年 sina. All rights reserved.
//

#import "TasksViewController.h"
#import "TaskModel.h"

@interface TasksViewController ()

@end

@implementation TasksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _searchBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"任务"];
}

- (void)initOfflineView
{
    //do nothing
}

- (void)dealloc
{
    OCSafeRelease(_tasksData);
    
    [super dealloc];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TaskModel* model = [self.tasksData objectAtIndex:section];
    return model.tasksData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int sec = indexPath.section;
    int row = indexPath.row;
    
    static NSString *userIdentifier = @"taskcell";
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
    if (cell==nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
    }

    TaskModel* model = [self.tasksData objectAtIndex:sec];
    TaskDetailModel* dModel = [model.tasksData objectAtIndex:row];
    
    cell.textLabel.text = dModel.name;
    
    return  cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tasksData.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    TaskModel* model = [self.tasksData objectAtIndex:section];
    int taskID = [model.weekID integerValue];
    
    return [NSString stringWithFormat:@"%d周任务", taskID];
}

@end

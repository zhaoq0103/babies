//
//  TutorTaskViewController.m
//  babyfaq
//
//  Created by PRO on 14-1-2.
//  Copyright (c) 2014年 sina. All rights reserved.
//

#import "TutorTaskViewController.h"
#import "TasksViewController.h"
#import "DetailsViewController.h"
#import "WebViewController.h"

@interface TutorTaskViewController ()

@end

@implementation TutorTaskViewController

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

#pragma mark - init navigation item

- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"全程指导"];
}

- (void)initOfflineView
{
 //do nothing
}

- (void)initNavigationLeftItem
{
    //nothing
}

- (void)initNavigationRightItem
{
    UIButton *spaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    spaceBtn.frame = CGRectMake(0, 13, 2, 2);
    UIBarButtonItem* leftItem = [[[UIBarButtonItem alloc] initWithCustomView:spaceBtn] autorelease];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 20, 20);
    
    [rightBtn setTitle:@"任务" forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"btn_setting"] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    NSArray* items = @[leftItem, rightBarButtonItem];
    
    
    float osVer = [[UIDevice currentDevice].systemVersion floatValue];
    if (osVer >= 5.0) {
        self.navigationItem.rightBarButtonItems = items;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    
    MW_RELEASE(rightBarButtonItem);
}

- (void) rightBtnClick : (UIButton*)sender
{
    TasksViewController* tasksVC = [[TasksViewController alloc] initWithNibName:@"TasksViewController" bundle:nil];
    [self.navigationController pushViewController:tasksVC animated:YES];
    [tasksVC release];
    
    //test webview
//    WebViewController* web = [[WebViewController alloc] initWithURL:@"http://www.baidu.com"];
//    [self.navigationController pushViewController:web animated:YES];
//    [web release];
}

@end

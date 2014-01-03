//
//  AboutViewController.m
//  babyfaq
//
//  Created by PRO on 13-6-3.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "AboutViewController.h"
#import "WindowsManager.h"
#import "HelpViewController.h"
#import "defines.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)dealloc
{
    [_btn_help release];
    [_viewBackGround release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    BOOL  isOnLine = [self updataUI4LineStatues];
    if (isOnLine)
    {
        
    }
}

-(void)initUI
{
    if (DeviceScreenHeight > 480) {
        [_viewBackGround setImage:[UIImage imageNamed:@"about_iphone5.png"]];
        _btn_help.frame = CGRectMake(71, DeviceScreenHeight-150, 177, 33);
    }
    else
    {
        [_viewBackGround setImage:[UIImage imageNamed:@"about.png"]];
        _btn_help.frame = CGRectMake(71, DeviceScreenHeight-150, 177, 33);
    }
}
- (BOOL) updataUI4LineStatues
{
    [self setIsOffline:NO];
    return YES;
}

- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"关于"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) layoutOfflineSubViews
{
    _searchBar.hidden = YES;
    [super layoutOfflineSubViews];
}

-(IBAction)btn_helpClicked:(id)sender
{
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    [self.navigationController pushViewController:helpViewController animated:YES];
    [helpViewController release];
    
}
@end

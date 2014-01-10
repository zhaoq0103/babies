//
//  DetailsViewController.m
//  babyfaq
//
//  Created by PRO on 14-1-3.
//  Copyright (c) 2014年 sina. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

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
    
    NSString* text = self.secModel.text;
    if (text != nil  && text.length > 0) {
        self.detailLabel.text = text;
    }
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
    [label setText:@"详情页"]; // replace this by section title;
}

- (void)initOfflineView
{
    //do nothing
}

- (void)dealloc {
    [_detailLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setDetailLabel:nil];
    [super viewDidUnload];
}
@end

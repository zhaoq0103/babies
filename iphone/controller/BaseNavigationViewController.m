//
//  BaseNavigationViewController.m
//  babyfaq
//
//  Created by PRO on 13-6-3.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "BaseNavigationViewController.h"

@interface UINavigationBar (setBackground)
@end

@implementation UINavigationBar (setBackground)

- (void) drawRect:(CGRect)rect
{
    [[UIImage imageNamed:CustomNavigationBackgroundImage] drawInRect:rect];	
}

@end


@interface BaseNavigationViewController ()

@end

@implementation BaseNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:CustomNavigationBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [self.navigationBar setNeedsDisplay];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

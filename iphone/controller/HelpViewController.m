//
//  HelpViewController.m
//  babyfaq
//
//  Created by PRO on 13-5-29.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "HelpViewController.h"
#import "WindowsManager.h"
#import "RegValueSaver.h"
#import "defines.h"

@interface HelpViewController ()

@end

@implementation HelpViewController


#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)quit:(id)sender {
////    [self.navigationController popViewControllerAnimated:YES];
//    [[WindowsManager sharedInstance] showTabbarViewController];
//}

- (void)dealloc
{
    [_galleryView release];
    [_pageControl release];
    [_pageView1 release];
    [_pageView2 release];
    [_pageView3 release];
    [_pageView4 release];
    
    //step1
    [_step1Label release];
    
    //step2
    [_step2Label release];
    
    self.closeButton = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    self.navigationController.toolbar.hidden = YES;
    [self.navigationController.toolbar setTranslucent:YES];
    self.navigationController.navigationBarHidden = YES;
    [super viewDidLoad];
    
    //step1
    self.step1Label.text = @"help me one !";
    self.step2Label.text = @"help me again";
    
    [self.closeButton setTitle:@"start" forState:UIControlStateNormal];
    
	
    NSArray *views = [NSArray arrayWithObjects:_pageView1, _pageView2, _pageView3, _pageView4, nil];
    
    [_galleryView initWithViews:views target:self action:@selector(pageChanged) width:-1 height:-1 autoChange:NO isRecycle:NO];
    [_pageControl setNumberOfPages:views.count];
    [_pageControl setCurrentPage:0];
    [_galleryView showView:0 offsetX:0 animation:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
#ifdef __IPAD
    return [UIApplication sharedApplication].statusBarOrientation;
#else
    return UIInterfaceOrientationPortrait;
#endif
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}


#pragma mark ------------ others 
- (void)pageChanged
{
    [_pageControl setCurrentPage:[_galleryView getCurrentIndex]];
}

- (IBAction)doneClicked:(id)sender
{

    [[RegValueSaver getInstance] saveSystemInfoValue:[NSNumber numberWithInt:YES]  forKey:APP_SINABABY_FIRSTRUN  encryptString:NO];
    [[WindowsManager sharedInstance] showTabbarViewController];
    
}

@end

//
//  WindowsManager.m
//  babyfaq
//
//  Created by mayanwei on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "WindowsManager.h"
#import "MWTabBarController.h"
#import "HomeViewController.h"
#import "ExpertViewController.h"
#import "SearchViewController.h"
#import "PersonCenterViewController.h"
#import "NewUserHelpScroll.h"
#import "RegValueSaver.h"
#import "defines.h"
#import "HelpViewController.h" 
#import "BaseNavigationViewController.h"
#import "RootViewController.h"
#import "Reachability.h"
#import "NewUserHelpScroll.h"
#import "TutorTaskViewController.h"

static WindowsManager *manager = nil;

@interface WindowsManager ()
{
    BaseNavigationViewController *homeNavgationController;
    BaseNavigationViewController *expertNavgationController;
    BaseNavigationViewController *searchNavgationController;
    BaseNavigationViewController *personalCenterNavgationController;
    BaseNavigationViewController *tutortaskController;
}
@end

@implementation WindowsManager

+ (WindowsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    });
    
    return manager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [super allocWithZone:zone];
        }
    });
    
    return manager;
}

- (void)showTabbarViewController
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    HomeViewController *homeViewController = MW_AUTORELEASE([[HomeViewController alloc] init]);
    ExpertViewController *expertViewController = MW_AUTORELEASE([[ExpertViewController alloc] init]);
    SearchViewController *searchViewController = MW_AUTORELEASE([[SearchViewController alloc] init]);
    PersonCenterViewController *personCenterViewController = MW_AUTORELEASE([[PersonCenterViewController alloc] init]);
    TutorTaskViewController *taskViewController = MW_AUTORELEASE([[TutorTaskViewController alloc] init]);
    
    
    NSMutableDictionary *imgDic1 = [NSMutableDictionary dictionaryWithCapacity:0];
	[imgDic1 setObject:[UIImage imageNamed:@"img_home_default.png"] forKey:@"Default"];
	[imgDic1 setObject:[UIImage imageNamed:@"img_home_select.png"] forKey:@"Seleted"];
	NSMutableDictionary *imgDic2 = [NSMutableDictionary dictionaryWithCapacity:0];
	[imgDic2 setObject:[UIImage imageNamed:@"img_ask_default.png"] forKey:@"Default"];
	[imgDic2 setObject:[UIImage imageNamed:@"img_ask_select.png"] forKey:@"Seleted"];
	NSMutableDictionary *imgDic3 = [NSMutableDictionary dictionaryWithCapacity:0];
	[imgDic3 setObject:[UIImage imageNamed:@"img_search_default.png"] forKey:@"Default"];
	[imgDic3 setObject:[UIImage imageNamed:@"img_serch_select.png"] forKey:@"Seleted"];
	NSMutableDictionary *imgDic4 = [NSMutableDictionary dictionaryWithCapacity:0];
	[imgDic4 setObject:[UIImage imageNamed:@"img_person_default.png"] forKey:@"Default"];
	[imgDic4 setObject:[UIImage imageNamed:@"img_person_select.png"] forKey:@"Seleted"];
    NSMutableDictionary *imgDic5 = [NSMutableDictionary dictionaryWithCapacity:0];
	[imgDic5 setObject:[UIImage imageNamed:@"img_person_default.png"] forKey:@"Default"];
	[imgDic5 setObject:[UIImage imageNamed:@"img_person_select.png"] forKey:@"Seleted"];
    
    homeNavgationController = MW_AUTORELEASE([[BaseNavigationViewController alloc] initWithRootViewController:homeViewController]);
    expertNavgationController = MW_AUTORELEASE([[BaseNavigationViewController alloc] initWithRootViewController:expertViewController]);
    searchNavgationController = MW_AUTORELEASE([[BaseNavigationViewController alloc] initWithRootViewController:searchViewController]);
    personalCenterNavgationController = MW_AUTORELEASE([[BaseNavigationViewController alloc] initWithRootViewController:personCenterViewController]);
    tutortaskController = MW_AUTORELEASE([[BaseNavigationViewController alloc] initWithRootViewController:taskViewController]);

    NSArray *ctrlArr = [NSArray arrayWithObjects:homeNavgationController,expertNavgationController,searchNavgationController,tutortaskController,personalCenterNavgationController,nil];
    for (BaseNavigationViewController *controller in ctrlArr)
    {
        controller.delegate = self;
    }
    
    NSArray *imgArr = [NSArray arrayWithObjects:imgDic1,imgDic2,imgDic3,imgDic4,imgDic5,nil];
    mwTabBarController = [[MWTabBarController alloc] initWithViewControllers:ctrlArr imageArray:imgArr];
    
    self.window.rootViewController = mwTabBarController;
    MW_RELEASE(mwTabBarController);

    // new user help
//    NSNumber* newUserFlag = [[RegValueSaver getInstance] readSystemInfoForKey:APP_SINABABY_FIRSTRUN];
//    if (!newUserFlag || ![newUserFlag boolValue]) {
//        _helpScroll = [[NewUserHelpScroll alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        _helpScroll.delegate = self;
//        [self.window addSubview:_helpScroll];
//        self.window.rootViewController.view.alpha = 0;
//    }
    
    [self.window makeKeyAndVisible];
}

- (void)hideNewUserHelpView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(closeUserHelp)];
    _helpScroll.userInteractionEnabled = NO;
    _helpScroll.alpha = 0.0;
    self.window.rootViewController.view.alpha = 1.0;
    [UIView commitAnimations];
}

-(void)closeUserHelp
{
    [_helpScroll removeFromSuperview];
    _helpScroll.delegate = nil;
    [_helpScroll release];
    _helpScroll = nil;
    [[RegValueSaver getInstance] saveSystemInfoValue:[NSNumber numberWithInt:YES]  forKey:APP_SINABABY_FIRSTRUN  encryptString:NO];
}

#pragma mark - UIScrollView Delegate -- for user help
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > scrollView.frame.size.width*3 + 40) {
        _endHelp = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_endHelp) {
        [self hideNewUserHelpView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_endHelp) {
        [self hideNewUserHelpView];
    }
}

- (void)showHelperViewController
{
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    self.window = MW_AUTORELEASE([[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]);
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = helpViewController;
    [self.window makeKeyAndVisible];
    
    MW_RELEASE(helpViewController);
    

}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{   
    if (navigationController.viewControllers.count == 1) {
        mwTabBarController.tabBar.hidden = NO;
        
        if ([navigationController.viewControllers[0] isKindOfClass:[HomeViewController class]]) {
            [navigationController.viewControllers[0] hideFastMemuAndKeyBoard];
        }
        else
        {
            [navigationController.viewControllers[0] hideSearchBarKeyBoard];
        }
        
    }
    else {
        mwTabBarController.tabBar.hidden = YES;        
    }
}
@end

//
//  MWTabBarController.m
//  babyfaq
//
//  Created by mayanwei on 13-5-24.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "MWTabBarController.h"
#import "MWTabBar.h"
#import "Reachability.h"
#import "RootViewController.h"


@implementation UIViewController (MWTabBarControllerSupport)

- (MWTabBarController *)mwTabBarController
{
    id obj = self;
    while ([obj isKindOfClass:[MWTabBarController class]]) {
        obj = [obj nextResponder];
    }
	return obj;
}

@end

@interface MWTabBarController (private)
- (void)displayViewAtIndex:(NSUInteger)index;
@end

@implementation MWTabBarController

#pragma mark -
#pragma mark lifecycle
- (id)initWithViewControllers:(NSArray *)controllers imageArray:(NSArray *)images;
{
	self = [super init];
	if (self != nil)
	{
		_viewControllers = [[NSMutableArray arrayWithArray:controllers] retain];
		
		_containerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        
        _containerView.backgroundColor =[UIColor clearColor];
		
		_transitionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _containerView.frame.size.width, _containerView.frame.size.height)];
        
        _transitionView.backgroundColor =[UIColor clearColor];
		
        CGRect mainRect = [[UIScreen mainScreen] applicationFrame];
		_tabBar = [[MWTabBar alloc] initWithFrame:CGRectMake(0, mainRect.size.height - kTabBarHeight, _containerView.frame.size.width, kTabBarHeight) buttonImages:images];
        
		_tabBar.delegate = self;
	}
	return self;
}

- (void)loadView
{
	[super loadView];
	
	[_containerView addSubview:_transitionView];
    
//    UIImageView* bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 411, 320, 49)];
//    bg.image =[UIImage imageNamed:@"bg_bar.png"];
//    [_containerView addSubview:bg];
//    [bg release];
    
	[_containerView addSubview:_tabBar];
	self.view = _containerView;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.selectedIndex = 0;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	_tabBar = nil;
	_viewControllers = nil;
}

- (void)dealloc
{
	[_tabBar release];
    [_containerView release];
    [_transitionView release];
	[_viewControllers release];
    [super dealloc];
}

#pragma mark - instant methods

- (MWTabBar *)tabBar
{
	return _tabBar;
}

- (NSUInteger)selectedIndex
{
	return _selectedIndex;
}
- (UIViewController *)selectedViewController
{
    return [_viewControllers objectAtIndex:_selectedIndex];
}

-(void)setSelectedIndex:(NSUInteger)index
{
    [self displayViewAtIndex:index];
    [_tabBar selectTabAtIndex:index];
}

#pragma mark - Private methods

- (void)displayViewAtIndex:(NSUInteger)index
{
    if (_selectedIndex == index && [[_transitionView subviews] count] != 0)
    {
        return;
    }
    _selectedIndex = index;
    
	UIViewController *selectedVC = [self.viewControllers objectAtIndex:index];
    
   
	
	selectedVC.view.frame = _transitionView.frame;
	if ([selectedVC.view isDescendantOfView:_transitionView])
	{
        [(RootViewController*)((UINavigationController*)selectedVC).viewControllers[0] updataUI4LineStatues];
		[_transitionView bringSubviewToFront:selectedVC.view];
	}
	else
	{
		[_transitionView addSubview:selectedVC.view];
	}
        
}

#pragma mark -
#pragma mark tabBar delegates

- (void)tabBar:(MWTabBar *)tabBar didSelectIndex:(NSInteger)index
{
	[self displayViewAtIndex:index];
}

@end

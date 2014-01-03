//
//  MWTabBarController.h
//  babyfaq
//
//  Created by mayanwei on 13-5-24.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWTabBar.h"

@interface MWTabBarController : UIViewController <MWTabBarDelegate>
{
	MWTabBar        *_tabBar;
//	UIView          *_containerView;
//	UIView          *_transitionView;
//	NSMutableArray  *_viewControllers;
	NSUInteger      _selectedIndex;
}
@property(nonatomic, copy) NSMutableArray *viewControllers;
@property(nonatomic, readonly) UIViewController *selectedViewController;
@property(nonatomic) NSUInteger selectedIndex;
@property (nonatomic, readonly) MWTabBar *tabBar;
@property (nonatomic ,retain) UIView *containerView;
@property (nonatomic ,retain) UIView *transitionView;

- (id)initWithViewControllers:(NSArray *)controllers imageArray:(NSArray *)images;

@end


@interface UIViewController (MWTabBarControllerSupport)
@property(nonatomic, retain, readonly) MWTabBarController *mwTabBarController;
@end



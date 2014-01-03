#import "BCTabBar.h"
#import "BCNavigationController.h"
@class BCTabBarView;

@interface BCTabBarController : UIViewController <BCTabBarDelegate>
{
    BCTabBar *tabBar;
    BOOL showFullZone;
    float mtabBarHeight; 
}
@property (nonatomic, assign) float tabBarHeight; 
@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) BCTabBar *tabBar;
@property (nonatomic, retain) UIViewController *selectedViewController;
@property (nonatomic, retain) BCTabBarView *tabBarView;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, readonly) BOOL visible;
@property (nonatomic, assign) BOOL showFullZone;

- (void)setViewControllers:(NSArray *)array selectedController:(UIViewController*)controller;

@end

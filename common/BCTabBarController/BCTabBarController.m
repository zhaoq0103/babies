#import "BCTabBarController.h"
#import "BCTabBar.h"
#import "BCTab.h"
#import "BCTabBarView.h"

@interface BCTabBarController ()

- (void)loadTabs;

@property (nonatomic, retain) UIImageView *selectedTab;
@property (nonatomic, readwrite) BOOL visible;

@end


@implementation BCTabBarController
@synthesize tabBarHeight=mtabBarHeight;
@synthesize viewControllers, tabBar, selectedTab, selectedViewController, tabBarView, visible,selectedIndex,showFullZone;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        tabBar = [[BCTabBar alloc] initWithFrame:CGRectZero];
    }
    
    return self;
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    BCTabBarView* tempView = [[BCTabBarView alloc] initWithFrame:appRect];
	self.tabBarView = tempView;
	self.view = self.tabBarView;
    [tempView release];

	CGFloat tabBarHeight = 44; // tabbar + arrow
    if (mtabBarHeight>0) {
        tabBarHeight = mtabBarHeight;
    }
    if (CGRectEqualToRect(self.tabBar.frame, CGRectZero)) {
        self.tabBar.frame = CGRectMake(0, self.view.bounds.size.height - tabBarHeight, self.view.bounds.size.width, tabBarHeight);
    }
	self.tabBar.delegate = self;
	
	self.tabBarView.backgroundColor = [UIColor clearColor];
	self.tabBarView.tabBar = self.tabBar;
    self.tabBarView.showFullZone = self.showFullZone;
	[self loadTabs];
	
	UIViewController *tmp = selectedViewController;
	selectedViewController = nil;
	[self setSelectedViewController:tmp];
}

- (void)tabBar:(BCTabBar *)aTabBar didSelectTabAtIndex:(NSInteger)index {
	UIViewController *vc = [self.viewControllers objectAtIndex:index];
    
	if (self.selectedViewController == vc) {
		if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
			[(UINavigationController *)self.selectedViewController popToRootViewControllerAnimated:YES];
		}
	} else {
        [(UINavigationController *)self.selectedViewController popToRootViewControllerAnimated:YES];
		self.selectedViewController = vc;
	}
	
}

-(void)dealloc
{
    [viewControllers release];
    [tabBar release];
    [selectedViewController release];
    [tabBarView release];
    
    [super dealloc];
}

- (void)setSelectedViewController:(UIViewController *)vc {
	UIViewController *oldVC = selectedViewController;
	if (selectedViewController != vc) {
		selectedViewController = [vc retain];
        if (self.viewControllers && visible) {
			[oldVC viewWillDisappear:NO];
			[selectedViewController viewWillAppear:NO];
		}
		self.tabBarView.contentView = vc.view;
        if (self.viewControllers && visible) {
			[oldVC viewDidDisappear:NO];
			[selectedViewController viewDidAppear:NO];
		}
        
        [oldVC release];
        
        if (self.tabBar&&[self.tabBar.tabs count]>0&&self.selectedIndex!=NSNotFound) {
            [self.tabBar setSelectedTab:[self.tabBar.tabs objectAtIndex:self.selectedIndex] animated:NO];
        }
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    if (self.viewControllers)
        [self.selectedViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    if (self.viewControllers)
        [self.selectedViewController viewDidAppear:animated];
    
	visible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    if (self.viewControllers)
        [self.selectedViewController viewWillDisappear:animated];	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    
    if (![self respondsToSelector:@selector(addChildViewController:)])
        [self.selectedViewController viewDidDisappear:animated];
	visible = NO;
}



- (NSUInteger)selectedIndex {
	return [self.viewControllers indexOfObject:self.selectedViewController];
}

- (void)setSelectedIndex:(NSUInteger)aSelectedIndex {
	if (self.viewControllers.count > aSelectedIndex)
    {
		self.selectedViewController = [self.viewControllers objectAtIndex:aSelectedIndex];
    }
}

- (void)loadTabs {
	NSMutableArray *tabs = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
	for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:[BCNavigationController class]]) {
            BCNavigationController* nav = (BCNavigationController*)vc;
            BCTab* oneTab = [[BCTab alloc] init];
            oneTab.nameLabel.text = nav.tabBarTitle;
            if (nav.tabBarTitleColor) {
                oneTab.nameLabel.textColor = nav.tabBarTitleColor;
            }
            if (nav.tabBarTitleHighlyColor) {
                oneTab.nameLabel.highlightedTextColor = nav.tabBarTitleHighlyColor;
            }
            oneTab.mainImageView.image = nav.tabBarImage;
            oneTab.mainImageView.highlightedImage = nav.tabBarHighlyImage;
            
            oneTab.bubbleView.backgroundColor = [UIColor clearColor];
            oneTab.bubbleImageView.image = nav.bubbleImage;
            [tabs addObject:oneTab];
            [oneTab release];
        }
	}
	self.tabBar.tabs = tabs;
    if ([tabs count]>0&&self.selectedIndex!=NSNotFound) {
        [self.tabBar setSelectedTab:[self.tabBar.tabs objectAtIndex:self.selectedIndex] animated:NO];
    }
}

- (void)viewDidUnload {
	self.tabBar = nil;
	self.selectedTab = nil;
}

- (void)setViewControllers:(NSArray *)array {
	if (array != viewControllers) {
        NSArray* oldviewControllers = viewControllers;
		viewControllers = [array retain];
        [oldviewControllers release];
		
		if (viewControllers != nil) {
			[self loadTabs];
		}
	}
	
	self.selectedIndex = 0;
}

- (void)setViewControllers:(NSArray *)array selectedController:(UIViewController*)controller
{
    if (array != viewControllers) {
        NSArray* oldviewControllers = viewControllers;
		viewControllers = [array retain];
        [oldviewControllers release];
		
		if (viewControllers != nil) {
			[self loadTabs];
		}
	}
    if (controller) {
        NSInteger index = [array indexOfObject:controller];
        if (index>=0) {
            self.selectedIndex = index;
        }
        else
        {
            self.selectedIndex = 0;
        }
    }
    else
    {
        self.selectedIndex = 0;
    }
}

-(void)setShowFullZone:(BOOL)bShowFullZone
{
    showFullZone = bShowFullZone;
    tabBarView.showFullZone = showFullZone;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.selectedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.selectedViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[self.selectedViewController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.selectedViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.selectedViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
//-(void)tabBar:(BCTabBar *)aTabBar didcoverimageAppear:(float)offset
//{
//    
//}
//-(void)tabBar:(BCTabBar *)aTabBar didCoverArrowHideChanged:(BOOL)bHided
//{
//    
//}


@end

#import "BCTabBarView.h"
#import "BCTabBar.h"

@implementation BCTabBarView
@synthesize tabBar, contentView,showFullZone;

- (void)setTabBar:(BCTabBar *)aTabBar {
    if (tabBar != aTabBar) {
        [tabBar removeFromSuperview];
        BCTabBar* oldTabBar = tabBar;
        tabBar = [aTabBar retain];
        [oldTabBar release];
        [self addSubview:tabBar];
    }
}

- (void)setContentView:(UIView *)aContentView {
	[contentView removeFromSuperview];
    UIView* oldParams = contentView;
	contentView = [aContentView retain];
    [oldParams release];
	contentView.frame = CGRectMake(0, 0, self.bounds.size.width, self.tabBar.frame.origin.y);

	[self addSubview:contentView];
	[self sendSubviewToBack:contentView];
}

- (void)layoutSubviews {
	[super layoutSubviews];
    if (showFullZone) {
        CGRect f = contentView.frame;
        f.size.height = self.bounds.size.height;
        contentView.frame = f;
    }
    else
    {
        CGRect f = contentView.frame;
        f.size.height = self.tabBar.frame.origin.y;
        contentView.frame = f;
    }
	[contentView layoutSubviews];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
    UIColor* tempColor = [UIColor colorWithRed:(230)/255.0 green:(230)/255.0 blue:(230)/255.0 alpha:1];
	[tempColor set];
	CGContextFillRect(c, self.bounds);
}

@end

//
//  LKLoadingCenter.m
//  SK
//
//  Created by luke on 10-11-22.
//  Copyright 2010 pica.com. All rights reserved.
//

#import "LKLoadingCenter.h"
#import "LKLoadingView.h"
 
@interface LKLoadingCenter ()
@property (nonatomic, retain) LKLoadingView *loadingView;

@end


@implementation LKLoadingCenter

@synthesize loadingView;




+ (LKLoadingCenter *)defaultCenter {
	
	static LKLoadingCenter *shareCenter = nil;
	if (!shareCenter) {
		shareCenter = [[LKLoadingCenter alloc] init];
	}
	return shareCenter;
}

-(id)init
{
    self = [super init]; 
    if (self!=nil) {
        loadingView = nil;
        ignoreTouched = NO;
    }
    return self;
}

- (void)postLoadingWithTitle:(NSString *)title message:(NSString *)msg {
	
	[self postLoadingWithTitle:title message:msg ignoreTouch:YES];
}

-(void)reversalLoadingView:(UIInterfaceOrientation)interfaceOrientation{
	
	CGFloat degrees = 0;
	CGRect rc = [[UIScreen mainScreen] bounds];
	
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) 
	{  
		float h = rc.size.height;
		float w = rc.size.width;
		loadingView.center = CGPointMake(w/2, h/2);
		
		degrees = -90;
	} 
	else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) 
	{		
		float h = rc.size.height;
		float w = rc.size.width;
		loadingView.center = CGPointMake(w/2, h/2);
		degrees = 90;
	} 
	else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
	{
		
		float h = rc.size.height;
		float w = rc.size.width;
		loadingView.center = CGPointMake(w/2, h/2);
		degrees = 180;
	}
	else 
	{   
		float h = rc.size.height;
		float w = rc.size.width;
		loadingView.center = CGPointMake(w/2, h/2);
		degrees = 0;
	}
	
	loadingView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	
}

- (void)postLoadingWithTitle:(NSString *)title message:(NSString *)msg ignoreTouch:(BOOL)ignore {
	
    [self disposeLoadingView];
	if (ignore&&!ignoreTouched) {
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        ignoreTouched = YES;
	}
    
	if (self.loadingView) {
        [self.loadingView removeFromSuperview];
		self.loadingView = nil;
	}
	loadingView = [[LKLoadingView alloc] initWithTitle:title message:msg];	
	loadingView.center = [UIApplication sharedApplication].keyWindow.center;
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	CGRect rc = [[UIScreen mainScreen] bounds];
//	NSLog(@"UIScreen:%f,%f,width=%f,height=%f",rc.origin.x,rc.origin.y,rc.size.width,rc.size.height);
	if (o == UIInterfaceOrientationLandscapeLeft) 
	{  
		float h = rc.size.height;
		float w = rc.size.width;
		//loadingView.center = CGPointMake(260.0, 240.0);
		loadingView.center = CGPointMake(w/2, h/2);

		degrees = -90;
	} 
	else if (o == UIInterfaceOrientationLandscapeRight) 
	{		
		float h = rc.size.height;
		float w = rc.size.width;
		loadingView.center = CGPointMake(w/2, h/2);
		//loadingView.center = CGPointMake(60.0, 240.0);
		degrees = 90;
	} 
	else if (o == UIInterfaceOrientationPortraitUpsideDown) 
	{
 
		float h = rc.size.height;
		float w = rc.size.width;
		loadingView.center = CGPointMake(w/2, h/2);
		degrees = 180;
	}
	else 
	{   
		float h = rc.size.height;
		float w = rc.size.width;
		loadingView.center = CGPointMake(w/2, h/2);
		degrees = 0;
	}
	
	loadingView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	
	
	[[UIApplication sharedApplication].keyWindow addSubview:loadingView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:loadingView];
	loadingView.tag = 2010;
    loadingView.hidden = NO;
	loadingView.alpha = 1.0;
	[loadingView startAnimating];
}

- (void)disposeLoadingView {
	[self disposeLoadingViewAndIgnoreTouch:YES];
}

- (void)disposeLoadingViewAndIgnoreTouch:(BOOL)ignore {
	if (loadingView) {
        loadingView.hidden = YES;
		if (ignore&&ignoreTouched) {
            ignoreTouched = NO;
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		
		[loadingView stopAnimating];
		[loadingView removeFromSuperview];
        }
		self.loadingView = nil;
	}
}

- (void)dealloc {
	
	self.loadingView = nil;
	[super dealloc];
}

@end

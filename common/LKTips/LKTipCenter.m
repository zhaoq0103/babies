//
//  LKTipCenter.m
//  SK
//
//  Created by luke on 10-11-17.
//  Copyright 2010 pica.com. All rights reserved.
//

#import "LKTipCenter.h"
#import "LKTipView.h"
#import "LKTip.h"
#import <QuartzCore/QuartzCore.h>
#ifdef FIXFIX
#import "BabyAppDelegate.h"
#endif

/*
@protocol LKTipDelegate <NSObject>

@optional
- (void)LKTipPressed:(NSString *)message;

@end
*/
 
static int widthPerSecond = 75;

@interface LKTipCenter ()

@property (nonatomic, retain) NSMutableArray *tips;
@property (nonatomic, retain) LKTipView *tipView;
@property (nonatomic, assign) LKTip *curTip;
@property (nonatomic, retain) UILabel *topTop;

- (void)disposeTip;
- (void)animationFadeout:(NSTimer *)theTimer;
- (void)showTips;
- (void)fallingTips;
-(void)realShowTopTipWithMessage;
-(void)stopedToptipHide;
-(void)postTophalfTipWithMessage:(NSString*)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore parentView:(UIView*)view font:(UIFont*)font;
@end


@implementation LKTipCenter

@synthesize tips, tipView, curTip,topTop,LogWindow;
@synthesize centertipView;
@synthesize curStatusBarHidden;
- (id)init {
	
	if (!(self=[super init]))
		return nil;
	
	self.tips = [NSMutableArray array];
	active = NO;
    topTop = nil;
    LogWindow = nil;
    mStatusFrame = CGRectZero;
    showingTopTip = NO;
	
	return self;
}

- (void)dealloc {
	[LogWindow release];
    [centertipView release];
	[tips release];
	[tipView release];
    [topTop release];
    [topMessageArray release];
	[super dealloc];
}

- (void)disposeTip {
	
	[tipView removeFromSuperview];
	[tips removeObjectAtIndex:0];
	[self showTips];
}

- (void)animationDrawup:(NSTimer *)theTimer {
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelay:1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(disposeTip)];
	
	tipView.frame = CGRectMake(tipView.frame.origin.x, tipView.frame.origin.y - 40, tipView.frame.size.width, tipView.frame.size.height);
	tipView.alpha = 0;
	[UIView commitAnimations];
}

- (void)timedDrawup {
	
	LKTip *aTip = [tips objectAtIndex:0];
	if (aTip && aTip.time) {
		[NSTimer scheduledTimerWithTimeInterval:aTip.time target:self selector:@selector(animationDrawup:) userInfo:nil repeats:NO];
	} else {
		[self animationDrawup:nil];
	}
}

- (void)animationFadeout:(NSTimer *)theTimer {
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelay:1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(disposeTip)];
#if 0
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if (o == UIInterfaceOrientationLandscapeLeft) 
	{
		degrees = -90;
	} 
	else if (o == UIInterfaceOrientationLandscapeRight) 
	{
		degrees = 90;
	} else if (o == UIInterfaceOrientationPortraitUpsideDown) 
	{
		degrees = 180;
	}
#endif
	//tipView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	//tipView.transform = CGAffineTransformScale(tipView.transform, 0.5, 0.5);
	
	tipView.alpha = 0;
	[UIView commitAnimations];
}

- (void)timedFadeout {
	
	LKTip *aTip = [tips objectAtIndex:0];
	if (aTip && aTip.time) {
		[NSTimer scheduledTimerWithTimeInterval:aTip.time target:self selector:@selector(animationFadeout:) userInfo:nil repeats:NO];
	} else {
		[self animationFadeout:nil];
	}
}

- (void)showTips {
	
	if ([self.tips count] < 1) {
		active = NO;
		return;
	}
	
	active = YES;
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	CGRect rc = [[UIScreen mainScreen] bounds];
	
	if (o == UIInterfaceOrientationLandscapeLeft) 
	{
		CGRect f = CGRectMake(0, -20, rc.size.height, 40);
		self.tipView = [[[LKTipView alloc] initWithFrame:f] autorelease];
		float h = rc.size.height/2;

		tipView.center = CGPointMake(0, h);//  240); 
		degrees = -90;
	} 
	else if (o == UIInterfaceOrientationLandscapeRight) 
	{
		CGRect f = CGRectMake(0, -20, rc.size.height, 40);
		self.tipView = [[[LKTipView alloc] initWithFrame:f] autorelease];
		float h =  rc.size.height/2;

		float w =  rc.size.width;
		tipView.center = CGPointMake(w,h); //(320, 240); 
		degrees = 90;
	} 
	else if (o == UIInterfaceOrientationPortraitUpsideDown) 
	{
		CGRect f = CGRectMake(0, -20, rc.size.width, 40);
		self.tipView = [[[LKTipView alloc] initWithFrame:f] autorelease];
		float h = rc.size.height;
		tipView.center = CGPointMake(rc.size.width/2, h);////480);
		degrees = 180;
	}
	else 
	{
		CGRect f = CGRectMake(0, 0, rc.size.width, 40);
		self.tipView = [[[LKTipView alloc] initWithFrame:f] autorelease];
		tipView.center = CGPointMake(rc.size.width/2, 0); 
	}
	
	tipView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	//tipView.transform = CGAffineTransformScale(tipView.transform, 1, 1);
	tipView.alpha = 1;
	[[UIApplication sharedApplication].keyWindow addSubview:tipView];
	tipView.tag = 2011;
	
	LKTip *aTip = [self.tips objectAtIndex:0];
	
	if(aTip.message)
		[tipView setText:aTip.message];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(timedDrawup)];
	
	tipView.alpha = 1;
	if (o == UIInterfaceOrientationLandscapeLeft) 
	{
		tipView.frame = CGRectMake(tipView.frame.origin.x+ 40, tipView.frame.origin.y , tipView.frame.size.width, tipView.frame.size.height);
		
	} 
	else if (o == UIInterfaceOrientationLandscapeRight) 
	{
		tipView.frame = CGRectMake(tipView.frame.origin.x - 40, tipView.frame.origin.y , tipView.frame.size.width, tipView.frame.size.height);
		//tipView.frame = CGRectMake(0, 20, rc.size.height, 40);
	} 
	else if (o == UIInterfaceOrientationPortraitUpsideDown) 
	{
		tipView.frame = CGRectMake(tipView.frame.origin.x, tipView.frame.origin.y - 40, tipView.frame.size.width, tipView.frame.size.height);
		
	}
	else 
	{ 
		tipView.frame = CGRectMake(tipView.frame.origin.x, tipView.frame.origin.y + 40, tipView.frame.size.width, tipView.frame.size.height);
		
		//tipView.frame = CGRectMake(0, 20, rc.size.width, 40);
		
	}
	
	[UIView commitAnimations];
}

- (void)fallingTips {
	
	if ([self.tips count] < 1) {
		active = NO;
		return;
	}
	
	active = YES;
	tipView.transform = CGAffineTransformIdentity;
	//[UIApplication sharedApplication].keyWindow.center;
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	CGRect rc = [[UIScreen mainScreen] bounds];

	if (o == UIInterfaceOrientationLandscapeLeft) 
	{
		CGRect f = CGRectMake(0, -20, rc.size.height, 40);
		self.tipView = [[[LKTipView alloc] initWithFrame:f] autorelease];
		float h = rc.size.height/2;
		
		tipView.center = CGPointMake(0, h);//  240); 
		degrees = -90;
	} 
	else if (o == UIInterfaceOrientationLandscapeRight) 
	{
		CGRect f = CGRectMake(0, -20, rc.size.height, 40);
		self.tipView = [[[LKTipView alloc] initWithFrame:f] autorelease];
		float h =  rc.size.height/2;
		
		float w =  rc.size.width;
		tipView.center = CGPointMake(w,h); //(320, 240); 

		degrees = 90;
	} 
	else if (o == UIInterfaceOrientationPortraitUpsideDown) 
	{
		CGRect f = CGRectMake(0, -20, rc.size.width, 40);
		self.tipView = [[[LKTipView alloc] initWithFrame:f] autorelease];
		float h = rc.size.height;
		tipView.center = CGPointMake(rc.size.width/2, h);////480);
		degrees = 180;
	}
	else 
	{
		CGRect f = CGRectMake(0, 0, rc.size.width, 40);
		self.tipView = [[[LKTipView alloc] initWithFrame:f] autorelease];
		tipView.center = CGPointMake(rc.size.width/2, 0); 
	}

	tipView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	//tipView.transform = CGAffineTransformScale(tipView.transform, 1, 1);
	tipView.alpha = 1;
	[[UIApplication sharedApplication].keyWindow addSubview:tipView];
	
	LKTip *aTip = [self.tips objectAtIndex:0];
	
	if(aTip.message)
		[tipView setText:aTip.message];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(timedDrawup)];
	
	tipView.alpha = 1;
	if (o == UIInterfaceOrientationLandscapeLeft) 
	{
	  tipView.frame = CGRectMake(tipView.frame.origin.x+ 40, tipView.frame.origin.y , tipView.frame.size.width, tipView.frame.size.height);
		
	} 
	else if (o == UIInterfaceOrientationLandscapeRight) 
	{
		 tipView.frame = CGRectMake(tipView.frame.origin.x - 40, tipView.frame.origin.y , tipView.frame.size.width, tipView.frame.size.height);
		//tipView.frame = CGRectMake(0, 20, rc.size.height, 40);
	} 
	else if (o == UIInterfaceOrientationPortraitUpsideDown) 
	{
		tipView.frame = CGRectMake(tipView.frame.origin.x, tipView.frame.origin.y - 40, tipView.frame.size.width, tipView.frame.size.height);
		
	}
	else 
	{ 
		tipView.frame = CGRectMake(tipView.frame.origin.x, tipView.frame.origin.y + 40, tipView.frame.size.width, tipView.frame.size.height);
		
		//tipView.frame = CGRectMake(0, 20, rc.size.width, 40);
		
	}
	
	[UIView commitAnimations];
}

#pragma mark -
+ (LKTipCenter *)defaultCenter {
	
	static LKTipCenter *defaultCenter = nil;
	if (!defaultCenter) {
		defaultCenter = [[LKTipCenter alloc] init];
	}
	return defaultCenter;
}

- (void)postTipWithMessage:(NSString *)message image:(UIImage *)image time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore {
	
	if (ignore && [tips count] > 0) {
		return;
	}
	LKTip *aTip = [[LKTip alloc] initWithMsg:message img:image durationTime:dTime];
	if (aTip) {
		self.curTip = aTip;
		[self.tips addObject:aTip];
		[aTip release];
		if (!active)
			[self showTips];
	}
}


- (void)postTipWithMessage:(NSString *)message time:(NSTimeInterval)dTime {
	
	[self postTipWithMessage:message image:nil time:dTime ignoreAddition:NO];
}

- (void)postTipWithMessage:(NSString *)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore {
	
	[self postTipWithMessage:message image:nil time:dTime ignoreAddition:ignore];
}

- (void)postFallingTipWithMessage:(NSString *)message time:(NSTimeInterval)dTime 
{
    
}
- (void)postFallingTipWithMessage2:(NSString *)message time:(NSTimeInterval)dTime
{
	
	LKTip *aTip = [[LKTip alloc] initWithMsg:message img:nil durationTime:dTime];
	if (aTip) {
		self.curTip = aTip;
		[self.tips addObject:aTip];
		[aTip release];
		if (!active)
			[self fallingTips];
	}
}

-(void)postTopTipWithMessage:(NSString *)message time:(NSTimeInterval)dTime color:(UIColor*)aColor
{
    if (!topMessageArray) {
        topMessageArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (message) {
        [dict setObject:message forKey:@"text"];
    }
    [dict setObject:[NSNumber numberWithInt:dTime] forKey:@"time"];
    if (aColor) {
        [dict setObject:aColor forKey:@"color"];
    }
    [topMessageArray addObject:dict];
    [dict release];
    [self realShowTopTipWithMessage];
}

-(void)realShowTopTipWithMessage
{
    if (!showingTopTip&&topMessageArray&&[topMessageArray count]>0) {
        showingTopTip = YES;
        NSDictionary* dict = [topMessageArray objectAtIndex:0];
        NSString* message = [dict objectForKey:@"text"];
        NSTimeInterval dTime = [(NSNumber*)[dict objectForKey:@"time"] doubleValue];
        UIColor* aColor = [dict objectForKey:@"color"];
        CGRect statusFrame = mStatusFrame;
        if (CGRectEqualToRect(statusFrame,CGRectZero))
        {
            statusFrame = [[UIApplication sharedApplication] statusBarFrame];
        }
        if (!CGRectEqualToRect(statusFrame,CGRectZero)) {
            mStatusFrame = statusFrame;
            CGRect labelRect = statusFrame;
            labelRect.origin.x = labelRect.origin.x + 20;
            labelRect.size.width = labelRect.size.width - 20;
            if (!topTop) {
                UILabel *tempLabel = [[UILabel alloc] initWithFrame:labelRect];
                self.topTop = tempLabel;
                tempLabel.backgroundColor = [UIColor clearColor];
                tempLabel.font = [UIFont systemFontOfSize:12];
                [tempLabel release];
            }
            if (aColor) {
                topTop.textColor = aColor;
            }
            else
            {
                topTop.textColor = [UIColor whiteColor];
            }
            if (!LogWindow) {
                UIImageView* tempImageView = [[UIImageView alloc] initWithFrame:statusFrame];
                tempImageView.backgroundColor = [UIColor clearColor];
                UIImage* tempImage = [UIImage imageNamed:@"statusback.png"];
                tempImage = [tempImage stretchableImageWithLeftCapWidth:100.0 topCapHeight:2];
                tempImageView.image = tempImage;
                tempImageView.tag = 11331;
                UIView* tempWindow = [[UIView alloc] initWithFrame:statusFrame];
                UIView* tempView = [[UIView alloc] initWithFrame:statusFrame];
                tempView.backgroundColor = [UIColor clearColor];
                tempView.tag = 22331;
                topTop.tag = 11332;
                [tempView addSubview:tempImageView];
                [tempView addSubview:topTop];
                [tempWindow addSubview:tempView];
                self.LogWindow = tempWindow;
                tempWindow.backgroundColor = [UIColor clearColor];
#ifdef FIXFIX
                BabyAppDelegate* appDelegate = (BabyAppDelegate*)[[UIApplication sharedApplication] delegate];
                [appDelegate.window addSubview:tempWindow];
#endif
                [tempImageView release];
                [tempWindow release];
            }
            self.curStatusBarHidden = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            UIView* backgroundView = [LogWindow viewWithTag:11331];
            UIView* parentView = [LogWindow viewWithTag:22331];
            topTop.text = message;
            [topTop sizeToFit];
            CGRect textframe = topTop.frame;
            textframe.size.height = labelRect.size.height;
            textframe.origin = labelRect.origin;
            topTop.frame = textframe;
            if (dTime>0)
            {
                curTopTipDuration = dTime;
            }
            else
            {
                curTopTipDuration = 3.0;
            }
            if(textframe.size.width>labelRect.size.width)
            {
                extraTopTipWidth = textframe.size.width - labelRect.size.width;
            }
            else
            {
                extraTopTipWidth = 0;
            }
            CGRect extraBackgroundRect = mStatusFrame;
            extraBackgroundRect.size.width += extraTopTipWidth;
            backgroundView.frame = extraBackgroundRect;
            parentView.frame = extraBackgroundRect;
            LogWindow.hidden = NO;
            LogWindow.alpha = 0.0;
            [UIView beginAnimations:@"tip" context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(stopedToptipShowed)];
            [UIView setAnimationDuration:0.5];
            LogWindow.alpha = 1.0;
            [UIView commitAnimations];
            
        }
        [topMessageArray removeObjectAtIndex:0];
    }
}

-(void)stopedToptipShowed
{
    if (extraTopTipWidth>0) {
        [self performSelector:@selector(startExtraShow) withObject:nil afterDelay:curTopTipDuration/3];
    }
    else
    {
        [self performSelector:@selector(startToptipHide) withObject:nil afterDelay:curTopTipDuration];
    }
}

-(void)startExtraShow
{
    UIView* parentView = [LogWindow viewWithTag:22331];
    NSTimeInterval scrollTime = extraTopTipWidth*1.0/widthPerSecond;
    NSTimeInterval totalDuration = curTopTipDuration/3>scrollTime ? curTopTipDuration/3 : scrollTime;
    [UIView beginAnimations:@"tipmove" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(stopExtraShow)];
    [UIView setAnimationDuration:totalDuration];
    CGRect topTipRect = parentView.frame;
    topTipRect.origin.x -= extraTopTipWidth;
    parentView.frame = topTipRect;
    [UIView commitAnimations];
}

-(void)stopExtraShow
{
    [self performSelector:@selector(startToptipHide) withObject:nil afterDelay:curTopTipDuration/3];
}

-(void)startToptipHide
{
    if (topMessageArray&&[topMessageArray count]>0) {
        [self stopedToptipHide];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.curStatusBarHidden = NO;
        [UIView beginAnimations:@"tip" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(stopedToptipHide)];
        [UIView setAnimationDuration:0.5];
        LogWindow.alpha = 0.0;
        [UIView commitAnimations];
    }
    
}

-(void)stopedToptipHide
{
    showingTopTip = NO;
    LogWindow.alpha = 0.0;
    [LogWindow removeFromSuperview];
    self.LogWindow = nil;
    
    [self realShowTopTipWithMessage];
}

-(void)postCenterTipWithMessage:(NSString*)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore parentView:(UIView*)view
{
    [self postCenterTipWithMessage:message time:dTime ignoreAddition:ignore parentView:view font:nil];
}

-(void)postSmallCenterTipWithMessage:(NSString*)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore parentView:(UIView*)view
{
    [self postCenterTipWithMessage:message time:dTime ignoreAddition:ignore parentView:view font:[UIFont systemFontOfSize:16.0]];
}
-(void)postSmallTophalfTipWithMessage:(NSString*)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore parentView:(UIView*)view
{
    [self postTophalfTipWithMessage:message time:dTime ignoreAddition:ignore parentView:view font:[UIFont systemFontOfSize:16.0]];
}
-(void)postTophalfTipWithMessage:(NSString*)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore parentView:(UIView*)view font:(UIFont*)font
{
    if (!centertipView) {
        UIView* aTipView = [[UIView alloc] init];
        aTipView.backgroundColor = [UIColor clearColor];
        self.centertipView = aTipView;
        self.centertipView.alpha = 1.0;
        CGRect bounds = CGRectZero;
        if (view) {
            bounds = view.bounds;
            aTipView.frame = bounds;
            [view addSubview:self.centertipView];
            [view  bringSubviewToFront:self.centertipView];
        }
        else
        {
            bounds = [[UIScreen mainScreen] bounds];
            aTipView.frame = bounds;
            [[UIApplication sharedApplication].keyWindow addSubview:centertipView];
        }
        
        [aTipView release];
        CGRect backRect = CGRectMake(0, 0, 200, 100);
        backRect.origin.x = bounds.size.width/2 - backRect.size.width/2;
//        backRect.origin.y = bounds.size.height/2 - backRect.size.height/2 - 50;
        backRect.origin.y = 40;
        UIView* aBackView = [[UIView alloc] initWithFrame:backRect];
        aBackView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        [self.centertipView addSubview:aBackView];
        aBackView.layer.masksToBounds=YES; 
        aBackView.layer.cornerRadius=10.0; 
        aBackView.tag = 11111;
        [aBackView release];
        UILabel* textLabel = [[UILabel alloc ]init];
        textLabel.backgroundColor = [UIColor clearColor];
        if (font) {
            textLabel.font = font;
        }
        else
        {
            textLabel.font = [UIFont systemFontOfSize:25];
        }
        
        textLabel.tag = 12222;
        textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        textLabel.numberOfLines = 0;
        textLabel.textColor = [UIColor whiteColor];
        [aBackView addSubview:textLabel];
    }
    else
    {
        
    }
    self.centertipView.alpha = 1.0;
    self.centertipView.userInteractionEnabled = ignore;
    UIView* aBackView = (UIView*)[self.centertipView viewWithTag:11111];
    UILabel* textLabel = (UILabel*)[self.centertipView viewWithTag:12222];
    textLabel.text = message;
    textLabel.adjustsFontSizeToFitWidth = NO;
    [textLabel sizeToFit];
    if (NO) {
        CGRect textLabelRect = aBackView.bounds;
        textLabel.adjustsFontSizeToFitWidth = YES;
        textLabel.frame = textLabelRect;
    }
    else
    {
        CGRect textLabelRect = aBackView.bounds;
        textLabelRect.size = textLabel.frame.size;
        textLabelRect.origin.x = aBackView.bounds.size.width/2 - textLabelRect.size.width/2;
        textLabelRect.origin.y = aBackView.bounds.size.height/2 - textLabelRect.size.height/2;
        textLabel.frame = textLabelRect;
    }
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startHideCenterTip) object:nil];
    [self performSelector:@selector(startHideCenterTip) withObject:nil afterDelay:dTime];
}
-(void)postCenterTipWithMessage:(NSString*)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore parentView:(UIView*)view font:(UIFont*)font
{
    if (!centertipView) {
        UIView* aTipView = [[UIView alloc] init];
        aTipView.backgroundColor = [UIColor clearColor];
        self.centertipView = aTipView;
        self.centertipView.alpha = 1.0;
        CGRect bounds = CGRectZero;
        if (view) {
            bounds = view.bounds;
            aTipView.frame = bounds;
            [view addSubview:self.centertipView];
            [view  bringSubviewToFront:self.centertipView];
        }
        else
        {
            bounds = [[UIScreen mainScreen] bounds];
            aTipView.frame = bounds;
            [[UIApplication sharedApplication].keyWindow addSubview:centertipView];
        }
        
        [aTipView release];
        CGRect backRect = CGRectMake(0, 0, 200, 100);
        backRect.origin.x = bounds.size.width/2 - backRect.size.width/2;
        backRect.origin.y = bounds.size.height/2 - backRect.size.height/2 - 50;
        UIView* aBackView = [[UIView alloc] initWithFrame:backRect];
        aBackView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        [self.centertipView addSubview:aBackView];
        aBackView.layer.masksToBounds=YES; 
        aBackView.layer.cornerRadius=10.0; 
        aBackView.tag = 11111;
        [aBackView release];
        UILabel* textLabel = [[UILabel alloc ]init];
        textLabel.backgroundColor = [UIColor clearColor];
        if (font) {
            textLabel.font = font;
        }
        else
        {
            textLabel.font = [UIFont systemFontOfSize:25];
        }
        
        textLabel.tag = 12222;
        textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        textLabel.numberOfLines = 0;
        textLabel.textColor = [UIColor whiteColor];
        [aBackView addSubview:textLabel];
    }
    else
    {
        
    }
    self.centertipView.alpha = 1.0;
    self.centertipView.userInteractionEnabled = ignore;
    UIView* aBackView = (UIView*)[self.centertipView viewWithTag:11111];
    UILabel* textLabel = (UILabel*)[self.centertipView viewWithTag:12222];
    textLabel.text = message;
    textLabel.adjustsFontSizeToFitWidth = NO;
    [textLabel sizeToFit];
    if (NO) {
        CGRect textLabelRect = aBackView.bounds;
        textLabel.adjustsFontSizeToFitWidth = YES;
        textLabel.frame = textLabelRect;
    }
    else
    {
        CGRect textLabelRect = aBackView.bounds;
        textLabelRect.size = textLabel.frame.size;
        textLabelRect.origin.x = aBackView.bounds.size.width/2 - textLabelRect.size.width/2;
        textLabelRect.origin.y = aBackView.bounds.size.height/2 - textLabelRect.size.height/2;
        textLabel.frame = textLabelRect;
    }
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startHideCenterTip) object:nil];
    [self performSelector:@selector(startHideCenterTip) withObject:nil afterDelay:dTime];
}

-(void)startHideCenterTip
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];		
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(stopHideCenterTip)];
    self.centertipView.alpha = 0.0;
    [UIView commitAnimations];
}

-(void)stopHideCenterTip
{
    if (self.centertipView.alpha==0.0) {
        self.centertipView = nil;
    }
}

#pragma mark touch handle

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
}

@end

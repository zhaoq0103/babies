//
//  LKLoadingView.m
//  SK
//
//  Created by luke on 10-11-18.
//  Copyright 2010 pica.com. All rights reserved.
//

#import "LKLoadingView.h"
#import "UIView+LKAddition.h"

#define WIDTH_MARGIN 20
#define HEIGHT_MARGIN 20

@interface LKLoadingView ()
- (CGSize)calculateHeightOfTextFromWidth:(NSString *)text font:(UIFont *)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode;
@end

@implementation LKLoadingView

@synthesize radius, title, message, activity;
/*
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
    }
    return self;
}
 */

- (id)initWithTitle:(NSString *)ttl message:(NSString *)msg {
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 320, 200)]) {
		
		self.center = [UIApplication sharedApplication].keyWindow.center;
		self.title = ttl;
		self.message = msg;
		self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[self addSubview:activity];
		[activity release];
		myhidden = YES;
        self.hidden = myhidden;
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (id)initWithTitle:(NSString *)ttl {
	
	if (![self initWithTitle:ttl message:nil]) 
		return nil;
	return self;	
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	
	if(myhidden) 
		return;
	
	CGFloat width, rWidth, rHeight, x;
	UIFont *titleFont = [UIFont boldSystemFontOfSize:16];
	UIFont *messageFont = [UIFont systemFontOfSize:12];
	
	CGSize sTitle   = [self calculateHeightOfTextFromWidth:title font:titleFont width:200 linebreak:UILineBreakModeTailTruncation];
	CGSize sMessage = [self calculateHeightOfTextFromWidth:message font:messageFont width:200 linebreak:UILineBreakModeCharacterWrap];
	
	if ([title length] < 1) 
		sTitle.height = 0;
	if ([message length] < 1) 
		sMessage.height = 0;
	
	rHeight = (sTitle.height + sMessage.height + (HEIGHT_MARGIN*2) + 10 + activity.frame.size.height);
	rWidth = width = (sMessage.width > sTitle.width) ? sMessage.width : sTitle.width;
	rWidth += WIDTH_MARGIN * 2;
	x = (320 - rWidth) / 2;
	
	activity.center = CGPointMake(320/2, HEIGHT_MARGIN + activity.frame.size.height/2);
	
	//NSLog(@"DRAW RECT %d %f",rHeight,self.frame.size.height);
	
	// DRAW ROUNDED RECTANGLE
	[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9] set];
	CGRect r = CGRectMake(x, 0, rWidth, rHeight);
	[UIView drawRoundRectangleInRect:r 
						  withRadius:10.0 
							   color:[UIColor colorWithRed:0.0 green:0 blue:0 alpha:0.6]];
	
	// DRAW FIRST TEXT
	[[UIColor whiteColor] set];
	r = CGRectMake(x+WIDTH_MARGIN, activity.frame.size.height + 10 + HEIGHT_MARGIN, width, sTitle.height);
	CGSize s = [title drawInRect:r withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	// DRAW SECOND TEXT
	r.origin.y += s.height;
	r.size.height = sMessage.height;
	[message drawInRect:r withFont:messageFont lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentCenter];
}

- (void)dealloc {
	
	[activity release];
	[title release];
	[message release];
    [super dealloc];
}

#pragma mark -
- (void)setTitle:(NSString *)str {
	
	[title release];
	title = [str copy];
	[self setNeedsDisplay];
}

- (void)setMessage:(NSString *)str {
	
	[message release];
	message = [str copy];
	[self setNeedsDisplay];
}

- (void)setRadius:(float)f {
	
	if (f==radius)
		return;
	
	radius = f;
	[self setNeedsDisplay];
}


- (void)startAnimating {
	
	if(!myhidden)
		return;
	myhidden = NO;
    self.hidden = myhidden;
	[self setNeedsDisplay];
	[activity startAnimating];
}

- (void)stopAnimating {
	
	if(myhidden) 
		return;
	myhidden = YES;
    self.hidden = myhidden;
	[self setNeedsDisplay];
	[activity stopAnimating];
    activity.hidesWhenStopped = YES;
}

#pragma mark -

- (CGSize)calculateHeightOfTextFromWidth:(NSString *)text font:(UIFont *)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode {
	
	return [text sizeWithFont:withFont 
			constrainedToSize:CGSizeMake(width, FLT_MAX) 
				lineBreakMode:lineBreakMode];
}
/*
- (CGSize)heightWithString:(NSString *)str font:(UIFont *)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode {
	
	CGSize suggestedSize = [str sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	
	return suggestedSize;
}


- (void)adjustHeight {
	
	CGSize sTitle = [self heightWithString:title font:[UIFont boldSystemFontOfSize:16.0] 
								 width:200.0 
							 linebreak:UILineBreakModeTailTruncation];
	
	CGSize sMessage = [self heightWithString:message font:[UIFont systemFontOfSize:12.0] 
								 width:200.0 
							 linebreak:UILineBreakModeCharacterWrap];
	
	CGRect r = self.frame;
	r.size.height = sTitle.height + sMessage.height + 20;
	self.frame = r;
}
*/

@end

//
//  BCNavigationBar.m
//  SinaNews
//
//  Created by shieh exbice on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BCNavigationBar.h"
#import "TitleView.h"

@implementation BCNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    NSArray* subViews = self.subviews;
    for (UIView* oneView in subViews) {
        if ([oneView isKindOfClass:[TitleView class]]) {
            TitleView* oneTitleView = (TitleView*)oneView;
            [oneTitleView sizeToFit];
            CGRect titleFrame = oneTitleView.frame;
            titleFrame.origin.x = self.bounds.size.width/2 - titleFrame.size.width/2;
            titleFrame.origin.y = self.bounds.size.height/2 - titleFrame.size.height/2;
            oneTitleView.frame = titleFrame;
        }
    }
}

-(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
}

@end

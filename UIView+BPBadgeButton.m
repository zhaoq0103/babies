//
//  UIButton+BPBadgeButton.m
//  Anchor3
//
//  Created by liuqiang on 12-3-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIView+BPBadgeButton.h"
#import "MKNumberBadgeView.h"
#import <objc/runtime.h>
#import "MyTool.h"

static char const * const badgeKey = "badge";

@implementation UIView (BPBadgeButton)

-(void)setBadge:(NSUInteger)newBadge
{
    MKNumberBadgeView *badgeView = [self badgeView];
    badgeView.value = newBadge;
    CGRect frame = CGRectMake(self.frame.size.width-badgeView.badgeSize.width,
                              0,
                              badgeView.badgeSize.width,
                              badgeView.badgeSize.height);
    badgeView.frame = frame;
    badgeView.hidden = (newBadge == 0);
    

    badgeView.shadow = YES;
    badgeView.shine = YES;
    badgeView.pad = 0;
    
    badgeView.textColor = [MyTool colorWithHexString:@"0xb55601"];//RGBACOLOR(0xb55601ff);
    badgeView.fillColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.0 alpha:1.0];
    badgeView.strokeColor = [UIColor clearColor];
}

-(NSUInteger)badge
{
    MKNumberBadgeView *badgeView = [self badgeView];
    return badgeView.value;
}

-(MKNumberBadgeView *)badgeView
{
    MKNumberBadgeView *badgeView = (MKNumberBadgeView *)objc_getAssociatedObject(self, badgeKey);
    if(!badgeView){
        badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        badgeView.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
        [self addSubview:badgeView];
        badgeView.hidden = YES;
        objc_setAssociatedObject(self, badgeKey, badgeView, OBJC_ASSOCIATION_RETAIN);
    }
    return badgeView;
}

@end

//
//  UITouchScrollView.m
//  babyfaq
//
//  Created by PRO on 13-7-29.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "UITouchScrollView.h"

@implementation UITouchScrollView

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    self.touchTimer = [touch timestamp];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    self.touchTimer = [touch timestamp] - self.touchTimer;
    
    NSInteger tapCount = [touch tapCount];
    CGPoint touchPoint = [touch locationInView:self];
    
    //判断单击，touch时间，touch区域
    if (tapCount == 1 && self.touchTimer < 3 && CGRectContainsPoint(self.frame, touchPoint) )
    {
        //handle tap
        if ([_tapDelegate respondsToSelector:@selector(scrollviewTaped)])
        {
            NSLog(@"hide keyboard");
            [_tapDelegate scrollviewTaped];
        }
    }
}

@end

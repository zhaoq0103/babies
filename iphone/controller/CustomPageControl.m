//
//  CustomPageControl.m
//  babyfaq
//
//  Created by PRO on 13-7-30.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "CustomPageControl.h"

@implementation CustomPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initSubView];
}


- (void) initSubView
{
    _activeImage = [[UIImage  imageNamed:kSelectedPageControlIndexImage] retain];
    _inactiveImage = [[UIImage    imageNamed:kUnSelectedPageControlIndexImage] retain];
}

- (void)updateDots
{
    for(int i = 0; i<self.subviews.count; i++)
    {        
        UIImageView* dot = [self.subviews objectAtIndex:i];
        if (![dot isKindOfClass:[UIImageView class]]) {
            return;
        }
    
        if(i == self.currentPage)
        {
            dot.image = _activeImage;
        }
        else
        {
            dot.image = _inactiveImage;
        }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage
{    
    [super  setCurrentPage:currentPage];
    [self updateDots];
}

- (void) dealloc
{
    [_activeImage release];
    [_inactiveImage release];
    [super dealloc];
}

@end

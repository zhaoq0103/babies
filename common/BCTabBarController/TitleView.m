//
//  TitleView.m
//  sinaUC
//
//  Created by shieh fabo on 11-8-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TitleView.h"

#define TitleView_ImageView  1010
#define TitleView_TextView  1020
#define TitleView_TextFrameView  1030
#define TitleView_Space 2

@interface TitleView ()

@property(nonatomic,retain)UIImageView* titleImageView;
@end

@implementation TitleView

@synthesize titleImage,title,titleColor,titleFont,titleImageView,textLabel;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    UIColor* defaultColor = [UIColor blackColor];
    titleColor = [defaultColor retain];
    UIFont* defaultFont = [UIFont boldSystemFontOfSize:20.0];
    titleFont = [defaultFont retain];
    
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

-(void)sizeToFit
{
    CGSize totalSize = CGSizeZero;
    if (title&&![title isEqualToString:@""]) {
        CGSize titleSize = [title sizeWithFont:titleFont];
        totalSize.width += titleSize.width;
        totalSize.height += titleSize.height;
    }
    if (titleImage) {
        totalSize.width += TitleView_Space;
        totalSize.width += titleImage.size.width;
        totalSize.height = titleImage.size.height>totalSize.height?titleImage.size.height:totalSize.height;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, totalSize.width, totalSize.height);
}

-(void)initTitleLabel
{
    if (title&&![title isEqualToString:@""])
    {
        if (!textLabel) {
            textLabel = [[UILabel alloc] init];
            textLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:textLabel];
        }
        if (textLabel) {
            textLabel.text = title;
            textLabel.font = titleFont;
            textLabel.textColor = titleColor;
        }
    }
    else
    {
        if (textLabel) {
            [textLabel removeFromSuperview];
            [textLabel release];
            textLabel = nil;
        }
    }
}

-(void)setTitleColor:(UIColor *)aTitleColor
{
    if (titleColor!=aTitleColor) {
        UIColor* oldColor = titleColor;
        titleColor = aTitleColor;
        [titleColor retain];
        [oldColor release];
    }
    textLabel.textColor = titleColor;
}

-(void)initTitleImageView
{
    if (titleImage)
    {
        if (!titleImageView) {
            titleImageView = [[UIImageView alloc] init];
            [self addSubview:titleImageView];
        }
        if (titleImageView&&titleImageView.image!=titleImage) {
            titleImageView.image = titleImage;
        }
    }
    else
    {
        if (titleImageView) {
            [titleImageView removeFromSuperview];
            [titleImageView release];
            titleImageView = nil;
        }
    }
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self initTitleImageView];
    [self initTitleLabel];
    CGRect titleRect = self.bounds;
    
    int xOffset = 0;
    if (titleImageView) {
        CGRect imageFrame = titleImageView.frame;
        imageFrame.size = titleImageView.image.size;
        imageFrame.origin.x = xOffset;
        imageFrame.size.height = imageFrame.size.height>titleRect.size.height?titleRect.size.height:imageFrame.size.height;
        imageFrame.origin.y = titleRect.size.height/2 - imageFrame.size.height/2;
        imageFrame.size.width = (imageFrame.size.height*titleImageView.image.size.width*1.0)/titleImageView.image.size.height;
        titleImageView.frame = imageFrame;
        xOffset += imageFrame.size.width;
        xOffset += TitleView_Space;
    }
    
    if (textLabel) {
        [textLabel sizeToFit];
        CGRect textFrame = textLabel.frame;
        textFrame.origin.x = xOffset;
        textFrame.origin.y = titleRect.size.height/2 - textFrame.size.height/2 - 4;
        textFrame.size.width = (textFrame.size.width)>(titleRect.size.width-xOffset)?(titleRect.size.width-xOffset):(textFrame.size.width);
        textLabel.frame = textFrame;
    }
}

- (void)dealloc
{
    [titleImageView release];
    [titleImage release];
    [title release];
    [titleColor release];
    [titleFont release];
    
    [super dealloc];
}

@end

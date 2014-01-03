//
//  NewUserHelpScroll.m
//  babyfaq
//
//  Created by PRO on 13-5-28.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "NewUserHelpScroll.h"

@implementation NewUserHelpScroll

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.scrollEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        NSString* executablePath = [[NSBundle mainBundle] bundlePath];
        
        NSString* newhandPath = [executablePath stringByAppendingPathComponent:@"iphone/guide_page1_img.png"];
        UIImage* newhandImage = [[UIImage alloc] initWithContentsOfFile:newhandPath];
        CGRect imageRect = frame;
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:imageRect];
        imageView.image = newhandImage;
        [self addSubview:imageView];
        [newhandImage release];
        [imageView release];
        
        newhandPath = [executablePath stringByAppendingPathComponent:@"iphone/guide_page2_img.png"];
        newhandImage = [[UIImage alloc] initWithContentsOfFile:newhandPath];
        imageRect.origin.x = imageRect.origin.x+320;
        imageView = [[UIImageView alloc] initWithFrame:imageRect];
        imageView.image = newhandImage;
        [self addSubview:imageView];
        [newhandImage release];
        [imageView release];
        
        newhandPath = [executablePath stringByAppendingPathComponent:@"iphone/guide_page3_img.png"];
        newhandImage = [[UIImage alloc] initWithContentsOfFile:newhandPath];
        imageRect.origin.x = imageRect.origin.x+320;
        imageView = [[UIImageView alloc] initWithFrame:imageRect];
        imageView.image = newhandImage;
        [self addSubview:imageView];
        [newhandImage release];
        [imageView release];
        
        newhandPath = [executablePath stringByAppendingPathComponent:@"iphone/guide_page4_img.png"];
        newhandImage = [[UIImage alloc] initWithContentsOfFile:newhandPath];
        imageRect.origin.x = imageRect.origin.x+320;
        imageView = [[UIImageView alloc] initWithFrame:imageRect];
        imageView.image = newhandImage;
        [self addSubview:imageView];
        [newhandImage release];
        [imageView release];
        [self setContentSize:CGSizeMake(imageRect.origin.x+imageRect.size.width, imageRect.size.height)];
    }
    return self;
}
@end

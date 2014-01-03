//
//  CustomPageControl.h
//  babyfaq
//
//  Created by PRO on 13-7-30.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSelectedPageControlIndexImage              @"pagecontrol_deepbluedot.png"
#define kUnSelectedPageControlIndexImage            @"pagecontrol_lightbluedot.png"

@interface CustomPageControl : UIPageControl
{
    UIImage             *_activeImage;
    UIImage             *_inactiveImage;
}

@end

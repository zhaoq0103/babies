//
//  UITouchScrollView.h
//  babyfaq
//
//  Created by PRO on 13-7-29.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIScrollViewTapDelegate

-(void) scrollviewTaped;

@end


@interface UITouchScrollView : UIScrollView


@property(nonatomic, assign)NSTimeInterval  touchTimer;
@property(nonatomic, assign)id<UIScrollViewTapDelegate> tapDelegate;

@end

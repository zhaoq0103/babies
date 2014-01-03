//

//  CustomViewGallery.h
//  SinaVideo
//
//  Created by 明 刘 on 12-1-6.
//  Copyright 2012年 hengzhun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomViewGallery : UIView
{
    int _width;
    int _height;
    id _target;
    SEL _action;
    
    CGPoint _startPoint;
    
    BOOL _autoChange;
    
    NSTimer *_timer;
}

@property (nonatomic, readonly, getter = getCurrentIndex) int currentIndex;
@property (nonatomic, retain) NSArray *views;
@property (nonatomic) BOOL isRecycle;

- (void)initWithViews:viewArray target:(id)target action:(SEL)action width:(int)width height:(int)height autoChange:(BOOL)autoChange isRecycle:(BOOL)recycle;
- (void)showView:(int)index offsetX:(float)offsetX animation:(BOOL)animated;
- (void)autoChangeIndex;
- (void)stopTimer;
- (int)getWidth;
- (int)getHeight;

@end

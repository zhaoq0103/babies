//
//  CustomViewGallery.m
//  SinaVideo
//
//  Created by 明 刘 on 12-1-6.
//  Copyright 2012年 hengzhun. All rights reserved.
//

#import "CustomViewGallery.h"
#import "WindowsManager.h"
#import "RegValueSaver.h"
#import "defines.h"
#import "HelpViewController.h"
#import "PersonCenterViewController.h"

@implementation CustomViewGallery

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
- (void)initWithViews:viewArray target:(id)target action:(SEL)action width:(int)width height:(int)height;
{
    
    [self initWithViews:viewArray target:target action:action width:width height:height autoChange:YES isRecycle:YES];
}

- (void)initWithViews:viewArray target:(id)target action:(SEL)action width:(int)width height:(int)height autoChange:(BOOL)autoChange isRecycle:(BOOL)recycle;
{
    if(_views)
    {
        [_views release];
        _views = nil;
    }
    
    _views = [viewArray retain];
    _width = width;
    _height = height;
    _target = target;
    _action = action;
    _autoChange = autoChange;
    _isRecycle = recycle;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    for (UIView *view in _views) {
        [self addSubview:view];
    }
    
    [self setClipsToBounds:YES];
    
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
        
    }
    
    if(_autoChange)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(autoChangeIndex) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:4]];
        //[_timer fire];
    }
}

- (void)dealloc
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    if(_views)
        [_views release];
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    [super dealloc];
}

- (void)stopTimer
{
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)autoChangeIndex
{
    int nextIndex = (_currentIndex + 1) % _views.count;
    [self showView:_currentIndex offsetX:-0.1 animation:NO];
    [self showView:nextIndex offsetX:0 animation:YES];
    if(_target && [_target respondsToSelector:_action])
        [_target performSelector:_action withObject:nil];
}

- (int)getWidth
{
    if(_width > 0)
        return _width;
    else
        return self.frame.size.width;
}
- (int)getHeight
{
    if(_height > 0)
        return _height;
    else
        return self.frame.size.height;
}

- (void)showView:(int)index offsetX:(float)offsetX animation:(BOOL)animated
{
    int width = [self getWidth];
    int height = [self getHeight];
    _currentIndex = index;
    int x = 0, y =0;
    int i;
    UIView *pageView;
    if(!animated || abs(offsetX) > 0)
    { 
        for (i = 0; i < _views.count; i++) {
            pageView = [_views objectAtIndex:i];
            if(index == 0)
            {
                pageView.tag = (i+1) % _views.count;
                x = (pageView.tag - index -1) * width + offsetX;
            }
            else if(index == (_views.count - 1))
            {
                pageView.tag = (i - 1 + _views.count) % _views.count;
                x = (pageView.tag - index + 1) * width + offsetX;
            }
            else
            {
                pageView.tag = i;
                x = width * (i - index) + offsetX;
            }
            [pageView setFrame:CGRectMake(x, y, width, height)];
        }
    }
    else
    {
        CGContextRef context = UIGraphicsGetCurrentContext(); 
        [UIView beginAnimations:@"Curl" context:context]; 
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; 
        [UIView setAnimationDuration:0.5]; 
        
        for (i = 0; i < _views.count; i++) {
            pageView = [_views objectAtIndex:i];
            if(pageView.tag == i)
            {
                x = width * (i - index);
            }
            else if(pageView.tag == (i+1) % _views.count)
            {
                if(index == 0)
                    x = (pageView.tag - index -1) * width;
                else if(index == (_views.count -1))
                    x =  pageView.tag * width;
                else
                    x =  (pageView.tag - index - 1) * width;
            }
            else
            {
                if(index == (_views.count -1))
                    x = (pageView.tag - index + 1) * width;
                else if(index == 0)
                    x = (pageView.tag - index -_views.count +1) * width;
                else
                    x = (pageView.tag - index + 1) * width;
            }
            [pageView setFrame:CGRectMake(x, y, width, height)];
        }
        
        [UIView commitAnimations];
    }
}

#pragma touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    //LOGD(@"touchesBegan: %d", touches.count);
    for (UITouch *touch in touches) {
		
		_startPoint = [touch locationInView: self];
    }
    //[super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{    
    //LOGD(@"touchesCancelled: %d", touches.count);
    [self showView:_currentIndex offsetX:0 animation:YES];
    //[super touchesCancelled:touches withEvent:event];
    if([self.superview.superview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *superView = (UIScrollView *)self.superview.superview;
        [superView setCanCancelContentTouches:YES];
    }
    
    if(!_timer && _autoChange)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(autoChangeIndex) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        //[_timer fire];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //LOGD(@"touchesEnded: %d", touches.count);
    if(touches.count == 0)
        return;
    CGPoint endPoint = _startPoint;
    for (UITouch *touch in touches) {
		
		endPoint = [touch locationInView: self];
    }
    
    if(abs(endPoint.x - _startPoint.x) > 60 )
    {
        if(endPoint.x < _startPoint.x)
        {
            if(_isRecycle)
                _currentIndex = (_currentIndex + 1) % _views.count;
            else
            {
                _currentIndex = _currentIndex + 1;
                if(_currentIndex >= _views.count)
                {
                    // _currentIndex = _views.count -1;
                    //滑到最后一页，进入
                    UIResponder* responder = [self nextResponder];
                    while (responder) {
                        if ( [responder isKindOfClass:[UIViewController class]] ) {
                            break;
                        }
                        
                        responder = [responder nextResponder];
                    }
                    
                    if ( [responder isKindOfClass:[HelpViewController class]] )
                    {
                         HelpViewController* viewVC = (HelpViewController*)responder;
                        if ([viewVC.navigationController.viewControllers[0] isKindOfClass:[PersonCenterViewController class]]) {
                            [viewVC.navigationController   popViewControllerAnimated:YES];
                            
                        }
                        else
                        {
                            [[RegValueSaver getInstance] saveSystemInfoValue:[NSNumber numberWithInt:YES]  forKey:APP_SINABABY_FIRSTRUN  encryptString:NO];
                            [[WindowsManager sharedInstance] showTabbarViewController];

                        }
                    }
                
                }
                   
            }
                
        }
        else
        {
            if(_isRecycle)
                _currentIndex = (_currentIndex - 1 + _views.count) % _views.count;
            else
            {
                _currentIndex = _currentIndex - 1;
                if(_currentIndex < 0)
                    _currentIndex = 0;
            }
              
        }
        if(_target && [_target respondsToSelector:_action])
            [_target performSelector:_action withObject:nil];
        [self showView:_currentIndex offsetX:0 animation:YES];
    }
    else
        [self showView:_currentIndex offsetX:0 animation:YES];
    //[super touchesEnded:touches withEvent:event];
    if([self.superview.superview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *superView = (UIScrollView *)self.superview.superview;
        [superView setCanCancelContentTouches:YES];
    }
    if(!_timer && _autoChange)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(autoChangeIndex) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        //[_timer fire];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count == 0)
        return;
    CGPoint currentPoint = _startPoint;
    for (UITouch *touch in touches) {
		
		currentPoint = [touch locationInView: self];
    }
    
    if(abs(currentPoint.x - _startPoint.x) > 10 )
    {
        if([self.superview.superview isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *superView = (UIScrollView *)self.superview.superview;
            [superView setCanCancelContentTouches:NO];
        }
        float offsetX = currentPoint.x - _startPoint.x;
        //if((_pageControl.currentPage == 0 && offsetX > 0) || (_pageControl.currentPage == (_pageControl.numberOfPages - 1) && offsetX < 0))
        //offsetX = offsetX / 2;
        [self showView:_currentIndex offsetX:offsetX animation:NO];
    }
    //[super touchesMoved:touches withEvent:event];
}

@end

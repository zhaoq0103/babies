//
//  UIView+ParentLayout.m
//  SinaNews
//
//  Created by shieh exbice on 11-11-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

//#import "ScrollButton.h"

@interface UIView ()

-(void)setAdaptiveParentLayoutWithSubviewSize:(CGSize)size subView:(UIView*)view;

@end

@implementation UIView (ParentLayout)

-(void)setAdaptiveParentLayoutWithSize:(CGSize)size
{
    UIView* superView = self.superview;
    if (superView) {
        [superView setAdaptiveParentLayoutWithSubviewSize:size subView:self];
    }
}

-(void)setAdaptiveParentLayoutWithSubviewSize:(CGSize)size subView:(UIView*)view
{
    if (view) {
        CGRect oldSubviewFrame = view.frame;
        BOOL resizeSub = NO;
        UIViewAutoresizing autoSizing = view.autoresizingMask;
        CGSize parenSize = self.bounds.size;
        BOOL resizeParent = NO;
        if (size.width!=oldSubviewFrame.size.width) {
            UIViewAutoresizing autoSizingW = autoSizing&((UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth)|UIViewAutoresizingFlexibleRightMargin);
            
            if((autoSizingW&UIViewAutoresizingFlexibleWidth)>0)
            {
                if ((autoSizingW&UIViewAutoresizingFlexibleLeftMargin)==0&&(autoSizingW&UIViewAutoresizingFlexibleRightMargin)==0) {
                    resizeParent = YES;
                    parenSize.width = size.width * parenSize.width / oldSubviewFrame.size.width;
                }
                else if((autoSizingW&UIViewAutoresizingFlexibleLeftMargin)>0&&(autoSizingW&UIViewAutoresizingFlexibleRightMargin)==0) {
                    float maxWidth = oldSubviewFrame.origin.x + oldSubviewFrame.size.width;
                    if (maxWidth>=0) {
                        if (size.width>maxWidth) {
                            resizeParent = YES;
                            parenSize.width = (size.width + (parenSize.width - (oldSubviewFrame.origin.x + oldSubviewFrame.size.width)));
                            resizeSub = YES;
                            oldSubviewFrame.origin.x = 0;
                        }
                        else
                        {
                            resizeSub = YES;
                            oldSubviewFrame.origin.x = oldSubviewFrame.origin.x + oldSubviewFrame.size.width - size.width;
                            oldSubviewFrame.size.width = size.width;
                        }
                    }
                    else
                    {
                        resizeSub = YES;
                        oldSubviewFrame.origin.x = oldSubviewFrame.origin.x + oldSubviewFrame.size.width - size.width;
                        oldSubviewFrame.size.width = size.width;
                    }
                    
                }
                else if((autoSizingW&UIViewAutoresizingFlexibleLeftMargin)==0&&(autoSizingW&UIViewAutoresizingFlexibleRightMargin)>0) {
                    float maxWidth = parenSize.width - oldSubviewFrame.origin.x;
                    if (maxWidth>0) {
                        if (size.width>maxWidth) {
                            resizeParent = YES;
                            parenSize.width = (size.width + oldSubviewFrame.origin.x);
                            resizeSub = YES;
                            oldSubviewFrame.size.width = maxWidth;
                        }
                        else
                        {
                            resizeSub = YES;
                            oldSubviewFrame.size.width = size.width;
                        }
                    }
                    else
                    {
                        resizeSub = YES;
                        oldSubviewFrame.size.width = size.width;
                    }
                    
                }
                else if((autoSizingW&UIViewAutoresizingFlexibleLeftMargin)>0&&(autoSizingW&UIViewAutoresizingFlexibleRightMargin)>0) {
                    float maxWidth = parenSize.width;
                    if (oldSubviewFrame.origin.x>0&&(oldSubviewFrame.origin.x+oldSubviewFrame.size.width<parenSize.width)) {
                        if (size.width>maxWidth) {
                            resizeParent = YES;
                            parenSize.width = size.width;
                            resizeSub = YES;
                            oldSubviewFrame.origin.x = 0;
                            oldSubviewFrame.size.width = maxWidth;
                        }
                        else
                        {
                            resizeSub = YES;
                            oldSubviewFrame.size.width = size.width;
                            oldSubviewFrame.origin.x = (parenSize.width - oldSubviewFrame.size.width)/2;
                            
                        }
                    }
                    else if(((oldSubviewFrame.origin.x==0)&&(oldSubviewFrame.origin.x+oldSubviewFrame.size.width==parenSize.width))||((oldSubviewFrame.origin.x<0)&&(oldSubviewFrame.origin.x+oldSubviewFrame.size.width>parenSize.width)))
                    {
                        resizeSub = YES;
                        oldSubviewFrame.origin.x = oldSubviewFrame.origin.x - (size.width - oldSubviewFrame.size.width)/2;
                        oldSubviewFrame.size.width = size.width;
                    }
                    else if(oldSubviewFrame.origin.x<=0)
                    {
                        resizeSub = YES;
                        oldSubviewFrame.origin.x = oldSubviewFrame.origin.x - (size.width - oldSubviewFrame.size.width);
                        oldSubviewFrame.size.width = size.width;
                    }
                    else
                    {
                        resizeSub = YES;
                        oldSubviewFrame.size.width = size.width;
                    }
                    
                }
            }
            else
            {
                if ((autoSizingW&UIViewAutoresizingFlexibleLeftMargin)==0&&(autoSizingW&UIViewAutoresizingFlexibleRightMargin)==0)
                {
                    resizeSub = YES;
                    oldSubviewFrame.size.width = size.width;
                }
                else if ((autoSizingW&UIViewAutoresizingFlexibleLeftMargin)>0&&(autoSizingW&UIViewAutoresizingFlexibleRightMargin)==0)
                {
                    resizeSub = YES;
                    oldSubviewFrame.origin.x = oldSubviewFrame.origin.x + oldSubviewFrame.size.width - size.width;
                    oldSubviewFrame.size.width = size.width;
                }
                else if ((autoSizingW&UIViewAutoresizingFlexibleLeftMargin)==0&&(autoSizingW&UIViewAutoresizingFlexibleRightMargin)>0)
                {
                    resizeSub = YES;
                    oldSubviewFrame.size.width = size.width;
                }
                else if ((autoSizingW&UIViewAutoresizingFlexibleLeftMargin)>0&&(autoSizingW&UIViewAutoresizingFlexibleRightMargin)>0)
                {
                    resizeSub = YES;
                    oldSubviewFrame.origin.x = oldSubviewFrame.origin.x - (size.width - oldSubviewFrame.size.width)/2;
                    oldSubviewFrame.size.width = size.width;
                }
            }
        }
        
        
        if (size.height!=oldSubviewFrame.size.height) {
            UIViewAutoresizing autoSizingW = autoSizing&((UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight)|UIViewAutoresizingFlexibleBottomMargin);
            
            if((autoSizingW&UIViewAutoresizingFlexibleHeight)>0)
            {
                if ((autoSizingW&UIViewAutoresizingFlexibleTopMargin)==0&&(autoSizingW&UIViewAutoresizingFlexibleBottomMargin)==0) {
                    resizeParent = YES;
                    parenSize.height = size.height * parenSize.height / oldSubviewFrame.size.height;
                }
                else if((autoSizingW&UIViewAutoresizingFlexibleTopMargin)>0&&(autoSizingW&UIViewAutoresizingFlexibleBottomMargin)==0) {
                    float maxWidth = oldSubviewFrame.origin.y + oldSubviewFrame.size.height;
                    if (maxWidth>=0) {
                        if (size.height>maxWidth) {
                            resizeParent = YES;
                            parenSize.height = (size.height + (parenSize.height - (oldSubviewFrame.origin.y + oldSubviewFrame.size.height)));
                            resizeSub = YES;
                            oldSubviewFrame.origin.y = 0;
                        }
                        else
                        {
                            resizeSub = YES;
                            oldSubviewFrame.origin.y = oldSubviewFrame.origin.y + oldSubviewFrame.size.height - size.height;
                            oldSubviewFrame.size.height = size.height;
                        }
                    }
                    else
                    {
                        resizeSub = YES;
                        oldSubviewFrame.origin.y = oldSubviewFrame.origin.y + oldSubviewFrame.size.height - size.height;
                        oldSubviewFrame.size.height = size.height;
                    }
                    
                }
                else if((autoSizingW&UIViewAutoresizingFlexibleTopMargin)==0&&(autoSizingW&UIViewAutoresizingFlexibleBottomMargin)>0) {
                    float maxWidth = parenSize.height - oldSubviewFrame.origin.y;
                    if (maxWidth>0) {
                        if (size.height>maxWidth) {
                            resizeParent = YES;
                            parenSize.height = (size.height + oldSubviewFrame.origin.y);
                            resizeSub = YES;
                            oldSubviewFrame.size.height = maxWidth;
                        }
                        else
                        {
                            resizeSub = YES;
                            oldSubviewFrame.size.height = size.height;
                        }
                    }
                    else
                    {
                        resizeSub = YES;
                        oldSubviewFrame.size.height = size.height;
                    }
                    
                }
                else if((autoSizingW&UIViewAutoresizingFlexibleTopMargin)>0&&(autoSizingW&UIViewAutoresizingFlexibleBottomMargin)>0) {
                    float maxWidth = parenSize.height;
                    if (oldSubviewFrame.origin.y>0&&(oldSubviewFrame.origin.y+oldSubviewFrame.size.height<parenSize.height)) {
                        if (size.height>maxWidth) {
                            resizeParent = YES;
                            parenSize.height = size.height;
                            resizeSub = YES;
                            oldSubviewFrame.origin.y = 0;
                            oldSubviewFrame.size.height = maxWidth;
                        }
                        else
                        {
                            resizeSub = YES;
                            oldSubviewFrame.size.height = size.height;
                            oldSubviewFrame.origin.y = (parenSize.height - oldSubviewFrame.size.height)/2;
                            
                        }
                    }
                    else if(((oldSubviewFrame.origin.y==0)&&(oldSubviewFrame.origin.y+oldSubviewFrame.size.height==parenSize.height))||((oldSubviewFrame.origin.y<0)&&(oldSubviewFrame.origin.y+oldSubviewFrame.size.height>parenSize.height)))
                    {
                        resizeSub = YES;
                        oldSubviewFrame.origin.y = oldSubviewFrame.origin.y - (size.height - oldSubviewFrame.size.height)/2;
                        oldSubviewFrame.size.height = size.height;
                    }
                    else if(oldSubviewFrame.origin.y<=0)
                    {
                        resizeSub = YES;
                        oldSubviewFrame.origin.y = oldSubviewFrame.origin.y - (size.height - oldSubviewFrame.size.height);
                        oldSubviewFrame.size.height = size.height;
                    }
                    else
                    {
                        resizeSub = YES;
                        oldSubviewFrame.size.height = size.height;
                    }
                    
                }
            }
            else
            {
                if ((autoSizingW&UIViewAutoresizingFlexibleTopMargin)==0&&(autoSizingW&UIViewAutoresizingFlexibleBottomMargin)==0)
                {
                    resizeSub = YES;
                    oldSubviewFrame.size.height = size.height;
                }
                else if ((autoSizingW&UIViewAutoresizingFlexibleTopMargin)>0&&(autoSizingW&UIViewAutoresizingFlexibleBottomMargin)==0)
                {
                    resizeSub = YES;
                    oldSubviewFrame.origin.y = oldSubviewFrame.origin.y + oldSubviewFrame.size.height - size.height;
                    oldSubviewFrame.size.height = size.height;
                }
                else if ((autoSizingW&UIViewAutoresizingFlexibleTopMargin)==0&&(autoSizingW&UIViewAutoresizingFlexibleBottomMargin)>0)
                {
                    resizeSub = YES;
                    oldSubviewFrame.size.height = size.height;
                }
                else if ((autoSizingW&UIViewAutoresizingFlexibleTopMargin)>0&&(autoSizingW&UIViewAutoresizingFlexibleBottomMargin)>0)
                {
                    resizeSub = YES;
                    oldSubviewFrame.origin.y = oldSubviewFrame.origin.y - (size.height - oldSubviewFrame.size.height)/2;
                    oldSubviewFrame.size.height = size.height;
                }
            }
        }
        
        if (resizeSub) {
            view.frame = oldSubviewFrame;
        }
        if (resizeParent) {
            UIView* superView = self.superview;
            CGRect newSuperRect = superView.frame;
            if (parenSize.width!=newSuperRect.size.width||parenSize.height!=newSuperRect.size.height) {
                 [superView setAdaptiveParentLayoutWithSubviewSize:parenSize subView:self];
            }
           
        }
    }
}


@end

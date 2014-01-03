//
//  HeaderFocusView.h
//  babyfaq
//
//  Created by YANGJINGXI on 13-6-13.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewGallery.h"
#import "ExpertCellView.h"
#import "HomeViewController.h"
#import "CustomPageControl.h"

@interface HeaderFocusView : UIView 
{
    CGPoint                 _startPoint;
    ExpertCellView*           _curExpertCellView;
}


@property(nonatomic,retain)NSMutableArray                       *expertViewArray;
@property (nonatomic, readonly, getter = getExperts)NSArray     *expertsArray;
@property (nonatomic, assign) HomeViewController                *parentViewController;

@property (nonatomic, retain) IBOutlet CustomPageControl        *pageControl;
@property (nonatomic, retain) IBOutlet CustomViewGallery        *viewGallery;

- (void)showVideos:(NSArray *)videoItems;
- (void)showVideo;
- (void)refreshImage:(NSArray *)args;
- (void)viewChanged;
- (IBAction)pageChanged:(id)sender;

- (void)handleImageTap:(UIGestureRecognizer *)gestureRecognizer;

@end

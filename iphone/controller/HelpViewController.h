//
//  HelpViewController.h
//  babyfaq
//
//  Created by PRO on 13-5-29.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomViewGallery;

@interface HelpViewController : UIViewController

@property (nonatomic, retain) IBOutlet CustomViewGallery *galleryView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIView *pageView1;
@property (nonatomic, retain) IBOutlet UIView *pageView2;
@property (nonatomic, retain) IBOutlet UIView *pageView3;
@property (nonatomic, retain) IBOutlet UIView *pageView4;

//step1
@property (nonatomic, retain) IBOutlet UILabel *step1Label;

//step2
@property (nonatomic, retain) IBOutlet UILabel *step2Label;

@property (nonatomic, retain) IBOutlet UIButton *closeButton;

- (IBAction)doneClicked:(id)sender;
- (void)pageChanged;

@end




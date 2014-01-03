//
//  AboutViewController.h
//  babyfaq
//
//  Created by PRO on 13-6-3.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "RootViewController.h"

@interface AboutViewController : RootViewController

@property (nonatomic, retain) IBOutlet UIButton *btn_help;
@property (nonatomic, retain) IBOutlet UIImageView *viewBackGround;
-(IBAction)btn_helpClicked:(id)sender;

@end

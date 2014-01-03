//
//  SettingViewController.h
//  babyfaq
//
//  Created by PRO on 13-5-27.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface SettingViewController : RootViewController

@property(nonatomic,retain) IBOutlet UIButton* myUpgradeBtn;
@property(nonatomic,retain) IBOutlet UIButton* mySupportBtn;
@property(nonatomic,retain) IBOutlet UIButton* mySuggestBtn;
@property(nonatomic,retain) IBOutlet UIButton* myAboutBtn;
- (IBAction)btnClicked : (UIButton*)sender;

@end

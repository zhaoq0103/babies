//
//  DetailsViewController.h
//  babyfaq
//
//  Created by PRO on 14-1-3.
//  Copyright (c) 2014年 sina. All rights reserved.
//

#import "RootViewController.h"
#import "TutorSectionModel.h"

@interface DetailsViewController : RootViewController
@property (nonatomic, retain)SectionModel*          secModel;
@property (retain, nonatomic) IBOutlet UITextView *detailLabel;
@end

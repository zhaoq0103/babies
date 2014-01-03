//
//  ExpertSearchViewController.h
//  babyfaq
//
//  Created by YANGJINGXI on 13-7-17.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "ExpertsTableView.h"

@interface ExpertSearchViewController : RootViewController
{
    NSMutableArray*             searchExpertArray;
    NSInteger                   searchExpertsCount;
}
@property (nonatomic, retain)NSString *keyWords;
@property (retain, nonatomic) ExpertsTableView *expertsList;
@property(nonatomic,retain)NSArray* idList;
@property(nonatomic, retain) IBOutlet UIImageView *noneImg;

@end

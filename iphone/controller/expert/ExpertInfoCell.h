//
//  ExpertInfoCell.h
//  babyfaq
//
//  Created by PRO on 13-6-8.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@class ExpertInfoCell;

@protocol ExpertInfoCell_Delegate <NSObject>
-(void)cell:(ExpertInfoCell*)cell askQuestionClicked:(UIButton*)sender;
-(void)cell:(ExpertInfoCell*)cell allQAClicked:(UIButton*)sender;
@end

@interface ExpertInfoCell : UITableViewCell
{
    UILabel*        _bakLable;  ////判断是否折行
}

@property(nonatomic,retain)IBOutlet UIView* containsView;  //for custom view

@property(nonatomic, retain) DataModel*  expertModel;

@property(nonatomic, assign)id<ExpertInfoCell_Delegate> delegate;
@property(nonatomic, retain)IBOutlet    UIImageView*    avatarImageView;
@property(nonatomic, retain)IBOutlet    UILabel*        companyName;
@property(nonatomic, retain)IBOutlet    UILabel*        position;
@property(nonatomic, retain)IBOutlet    UIImageView*    vsignImageView;
@property(nonatomic, retain)IBOutlet    UILabel*        expertName;
@property(nonatomic, retain)IBOutlet    UILabel*        expertOnlineTime;
@property(nonatomic, retain)IBOutlet    UIButton        *btnAskQuestion;
@property(nonatomic, retain)IBOutlet    UIButton        *btnAllQA;



- (IBAction)btnAskQuestionClicked:(id)sender;
- (IBAction)btnAllQAClicked:(id)sender;

@end

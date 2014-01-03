//
//  QuestionAnswerCell.h
//  babyfaq
//
//  Created by PRO on 13-6-6.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "DataModel.h"
#import "RTLabel.h"

@class QuestionAnswerCell;
@protocol QuestionAnswerCell_Delegate <NSObject>
-(void)cell:(QuestionAnswerCell*)cell commentClicked:(UIButton*)sender;
-(void)cell:(QuestionAnswerCell*)cell repostClicked:(UIButton*)sender;
-(void)cell:(QuestionAnswerCell*)cell favoriteClicked:(UIButton*)sender;
-(void)headImageOfExpertTapedInCell : (QuestionAnswerCell*)cell;
@end


@interface QuestionAnswerCell : UITableViewCell
{
    BOOL _hasInited;
}

@property(nonatomic,retain)IBOutlet UIView* containsView;

@property(nonatomic,retain)IBOutlet UIImageView* vIconImageView;
@property(nonatomic,retain)IBOutlet UIImageView* avatarImageView;

@property(nonatomic,retain)IBOutlet UIImageView* qOrAFlagView;
@property(nonatomic,retain) RTLabel* weiboContent;
@property(nonatomic,retain) NSString* weiboTextFomated;
@property(nonatomic,retain) NSString* weiboText;
@property(nonatomic,retain)IBOutlet UIButton* wbFavorite;

@property(nonatomic,retain)IBOutlet UIButton* wbRepost;
@property(nonatomic,retain)IBOutlet UILabel* repostLable;

@property(nonatomic,retain)IBOutlet UIButton* wbComment;
@property(nonatomic,retain)IBOutlet UILabel* commentLable;

@property(nonatomic,retain)IBOutlet UILabel* timeLable;
@property(nonatomic,retain)IBOutlet UIImageView* separateImageView;

@property (retain, nonatomic) IBOutlet UILabel *relativeQATip;

//@property(nonatomic,retain)NSString* weiboContentStr;
@property(nonatomic,assign)NSInteger cellRowNum;
@property(nonatomic,retain)NSString* weiboMid;
@property(nonatomic,assign)NSInteger cellType;


@property(nonatomic,assign)id<QuestionAnswerCell_Delegate>delegate;

@property(nonatomic, retain)DataModel* cellData;


+ (RTLabel*)textLabel;
+ (float) CellHeight : (DataModel*) quizeModel;
@end

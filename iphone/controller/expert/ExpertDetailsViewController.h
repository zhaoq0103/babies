//
//  ExpertDetailsViewController.h
//  babyfaq
//
//  Created by PRO on 13-6-9.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "DataModel.h"
#import "QandATableView.h"

@interface ExpertDetailsViewController : RootViewController
{
//    BOOL bInited;
//    NSMutableArray* expertID;
//    NSInteger currExpert;
    NSMutableArray* searchArray;
    NSArray* searchID;
    NSMutableArray* classIDArray;
    
    BOOL  _bQADataReady;
}

@property(nonatomic, retain)DataModel* expertModel;

@property(nonatomic, retain)IBOutlet UIImageView *photoImageView;
@property(nonatomic, retain)IBOutlet UILabel *onlineTime;
@property(nonatomic, retain)IBOutlet UILabel *workField;
@property(nonatomic, retain)IBOutlet UILabel *expertPosition;
@property(nonatomic, retain)IBOutlet UIButton *askExpert;
@property(nonatomic, retain)IBOutlet UIButton *expertIntro;
@property(nonatomic, retain)IBOutlet UIButton *allAskAnswer;
@property(nonatomic, retain)IBOutlet UIImageView *seperateImageView;
@property(nonatomic, retain)IBOutlet UITextView *introTextView;
@property(nonatomic, retain)IBOutlet UIImageView *introImageVIew;
//@property(nonatomic,retain)NSMutableArray* expertID;
//@property(assign)NSInteger currExpert;

@property (retain, nonatomic) QandATableView*       searchResultTable;
@property(nonatomic,retain)NSArray*                 searchArgs;
@property (nonatomic)NSInteger                      curPage;
@property(nonatomic, retain)NSMutableArray*         searchResultArray;
@property(nonatomic)NSInteger                       searchResultCount;

@property(nonatomic)NSInteger                       expertUID;


-(IBAction)askExpertButtonClicked:(id)sender;
-(IBAction)expertInfoButtonClicked:(id)sender;
-(IBAction)allAskAnswerButtonClicked:(id)sender;


@end
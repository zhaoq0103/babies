//
//  PostInteractionDataViewController.h
//  babyfaq
//
//  Created by PRO on 13-6-7.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "RootViewController.h"
#import "DataModel.h"

//send data viewcontroller : comment, askquestion, repost, suggest

@interface PostInteractionDataViewController : RootViewController<UITextViewDelegate>
{
    NSInteger anonymouse;
    CGFloat         _keyboardHeight;
}
@property(assign) NSInteger contentType;
@property(nonatomic, retain) NSString                   *FeedHeadStr;
@property(nonatomic, retain) NSString                   *contentStr;
@property(nonatomic, retain) NSString                   *expertID;
@property(nonatomic, retain) NSString                   *subjectID;
@property(nonatomic, retain) IBOutlet UITextView *content;
@property (retain, nonatomic) IBOutlet UIImageView *contentBK;
@property(nonatomic, retain) IBOutlet UIButton *checkBoxButton;
@property(nonatomic, retain) IBOutlet UIView *askHeaderView;
@property(nonatomic, retain) IBOutlet UIImageView *backgroungImg;
@property(nonatomic, retain) IBOutlet UIImageView *anonymous_selectImg;
@property(nonatomic, retain) IBOutlet UIImageView *anonymous_defaultImg;
@property(nonatomic, retain) IBOutlet UILabel *remainTextNumLabel;

@property(nonatomic, retain) DataModel*                 dataModel;
-(IBAction)checkBoxButtonClicked:(id)sender;
-(void)initUI;
-(void)initNavigationBar;
@end


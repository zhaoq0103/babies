//
//  CommentCell.h
//  babyfaq
//
//  Created by PRO on 13-5-29.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface CommentCell : UITableViewCell
{
//    UILabel *_userNickName;
//    UILabel *_userCommentContent;
//    UILabel *_userCommentTime;
}

@property (retain, nonatomic) IBOutlet UILabel *userNickName;
@property (retain, nonatomic) IBOutlet UILabel *userCommentContent;
@property (retain, nonatomic) IBOutlet UILabel *userCommentTime;
@property (nonatomic,retain)  IBOutlet UIImageView* sepImageView;

@property(nonatomic,retain)IBOutlet UIView* containsView;  //for custom view
@property(nonatomic, retain)DataModel* commentDataModel;
@end

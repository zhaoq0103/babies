//
//  CommentViewController.h
//  babyfaq
//
//  Created by PRO on 13-5-29.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "CommentTableView.h"


@interface CommentViewController : RootViewController
{
    NSArray             * _selectedID;
    NSString            *_commentID;
}

@property(nonatomic, retain)NSString*               weiboStrID;
@property (retain, nonatomic) CommentTableView      *commentTableView;


@property (nonatomic, retain)NSMutableArray*        commentDataArray;
@property (nonatomic)NSInteger                      commentDataCount;
@property (nonatomic)NSInteger                      curPage;
@property (nonatomic, retain) IBOutlet UIImageView *emptyImg;
@property (nonatomic, retain) IBOutlet UIImageView *noneImg;

@end

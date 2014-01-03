//
//  CommentTableView.m
//  babyfaq
//
//  Created by PRO on 13-6-25.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "CommentTableView.h"
#import "CommentCell.h"
#import "MessageManager.h"
#import "CommentViewController.h"

@implementation CommentTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}


#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowNum = indexPath.row;
//    CommentDataList* commentContentList = [[DataCenter getInstance]commentList];
//    [commentContentList reloadShowedDataWithIDList:self.selectedID];
//    BOOL bBottom = rowNum>=[commentContentList contentsCountWithIDList:self.selectedID];
//    if (!bBottom)
    {
        CommentCell* rtval = nil;
        static NSString* userIdentifier = @"CommentContentIdentifier";
        rtval = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
        if (!rtval)
        {
            rtval = [[[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
//             NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:nil options:nil];
//            rtval = [array lastObject];
        }
        
        DataModel* weiboObj = self.sourceData[rowNum];
        rtval.commentDataModel  = weiboObj;
        //        [rtval reloadData];
        CGSize size = [rtval sizeThatFits:CGSizeZero];
        
        return size.height;
    }
//    else
//    {
//        PageTableViewCell* rtval = nil;
//        NSString* userIdentifier = @"pageIdentifier";
//        rtval = (PageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
//        if (!rtval) {
//            rtval = [[[PageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
//        }
//        CGSize heigtSize = [rtval sizeThatFits:CGSizeZero];
//        return heigtSize.height;
//    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sourceData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int rowNum = [indexPath row];
    CommentCell* rtval = nil;
//    CommentDataList* commentContentList = [[DataCenter getInstance]commentList];
//    BOOL bBottom = rowNum>=[commentContentList contentsCountWithIDList:self.selectedID];
//    if (!bBottom)
    {
        
        static NSString* userIdentifier = @"CommentContentIdentifier";
        rtval = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
        if (!rtval)
        {
            rtval = [[[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
//            NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:nil options:nil];
//            rtval = [array lastObject];
        }
        rtval.selectionStyle = UITableViewCellSelectionStyleNone;
        
        rtval.commentDataModel  = self.sourceData[rowNum];

#warning what's this for?  add to cell content view
        [rtval reloadData];
    }
//    else
//    {
//        PageTableViewCell* rtval = nil;
//        NSString* userIdentifier = @"pageIdentifier";
//        rtval = (PageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
//        if (!rtval) {
//            rtval = [[[PageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
//            rtval.delegate = self;
//        }
//        rtval.type = curPageType;
//        [rtval reloadData];
//        cell = rtval;
//    }
    return rtval;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIResponder* responder = [self nextResponder];
    while (responder) {
        if ( [responder isKindOfClass:[UIViewController class]] ) {
            break;
        }
        
        responder = [responder nextResponder];
    }
    
    if ( [responder isKindOfClass:[CommentViewController class]] ) {
       // [(CommentViewController*)responder rightBtnClick:nil];
    }

}

@end

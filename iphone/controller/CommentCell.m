//
//  CommentCell.m
//  babyfaq
//
//  Created by PRO on 13-5-29.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "CommentCell.h"
#import "MyTool.h"
#import "defines.h"

#define WeiBoContentFontSize 14.0
#define CommentCell_BoderMaigin 10
#define CommentCell_ContentWidth 236
#define ContentOrignX 12
#define ContentOrignY 38

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
    }
    return self;
}

-(void)reloadData
{
    //    if (!hasInited) {
    //        hasInited = YES;
    [self.contentView addSubview:_containsView];
    //    }
    
}

-(void) setCommentDataModel:(DataModel *)commentDataModel
{
    if (_commentDataModel != commentDataModel) {
        [_commentDataModel release];
        _commentDataModel = [commentDataModel retain];
    }
  
    NSDictionary* oneUser = (NSDictionary*)[_commentDataModel valueForKey:WeiboCommentObject_user];
    NSString* userName = [oneUser objectForKey:WeiboUserObject_screen_name]; 
    _userNickName.text = userName;
    
    NSString* text = [_commentDataModel valueForKey:WeiboCommentObject_text];
    _userCommentContent.text = text;
    
//    _userCommentTime.text = [_commentDataModel valueForKey:WeiboUserObject_created_at];
    
    NSString* createDateStr = (NSString*)[_commentDataModel valueForKey:WeiboObject_CreateDate];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
    formatter.dateFormat = @"EEE MMM dd HH:mm:ss z yyyy";
    NSDate* newFormatDate = [formatter dateFromString:createDateStr];
    NSString* dateStr = [MyTool humanizeDateFormatFromDate:newFormatDate];
    _userCommentTime.text = dateStr;
    
    [formatter release];
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGRect mainRect = CGRectMake(0, 0, 320, 2000);
    mainRect = CGRectMake(mainRect.origin.x + CommentCell_BoderMaigin, mainRect.origin.y + CommentCell_BoderMaigin, mainRect.size.width - 2*CommentCell_BoderMaigin, mainRect.size.height - 2*CommentCell_BoderMaigin);
    CGRect contentRect = CGRectMake(ContentOrignX, ContentOrignY, 236, mainRect.size.height);
    contentRect.size = [_userCommentContent.text sizeWithFont:[UIFont systemFontOfSize:WeiBoContentFontSize] constrainedToSize:contentRect.size];
    
    
    CGSize totalSize = CGSizeZero;
    totalSize.width = 320;
    totalSize.height = ContentOrignY +  contentRect.size.height + CommentCell_BoderMaigin;
    
    return totalSize;
}

- (void)dealloc {
    [_userNickName release];
    [_userCommentContent release];
    [_userCommentTime release];
    [_commentDataModel release];
    [super dealloc];
}


-(void)myLayoutSubviews
{
    CGRect mainRect = self.bounds;
    mainRect = CGRectMake(mainRect.origin.x + CommentCell_BoderMaigin, mainRect.origin.y + CommentCell_BoderMaigin, mainRect.size.width - 2*CommentCell_BoderMaigin, mainRect.size.height - 2*CommentCell_BoderMaigin);
    
    self.userCommentContent.frame = CGRectMake(ContentOrignX, ContentOrignY, CommentCell_ContentWidth, mainRect.size.height);
    
    int yPos = ContentOrignY;
    CGSize size = CGSizeMake(CommentCell_ContentWidth, 2000);
    CGSize labelsize = [_userCommentContent.text sizeWithFont:[UIFont systemFontOfSize:WeiBoContentFontSize] constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    _userCommentContent.frame = CGRectMake(ContentOrignX, yPos, labelsize.width, labelsize.height);
    
    yPos += _userCommentContent.frame.size.height  + CommentCell_BoderMaigin;
    self.sepImageView.frame = CGRectMake(ContentOrignX,  yPos-1, 296, 2);
    
    self.containsView.frame = CGRectMake(0, 0, DeviceScreenWidth, yPos);
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        [self myLayoutSubviews];
    }
}

@end

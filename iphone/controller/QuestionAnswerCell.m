//
//  QuestionAnswerCell.m
//  babyfaq
//
//  Created by PRO on 13-6-6.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "QuestionAnswerCell.h"
#import "MessageManager.h"
#import "defines.h"
#import "MyTool.h"
#import "HomeViewController.h"

#define WeiBoContentFontSize 14.0

@implementation QuestionAnswerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"QuestionAnswerCell" owner:self options:nil];
        _weiboContent = [QuestionAnswerCell textLabel];
        [self addSubview:_weiboContent];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if ( !CGRectEqualToRect(frame, CGRectZero) )
    {
        [self qACellLayoutSubviews];
    }
}

-(void)dealloc
{
    [_weiboContent release];
    [_relativeQATip release];
    [super dealloc];
}

- (void)setCellData:(DataModel *)cellData
{
    [_cellData release];
    _cellData = [cellData retain];
    
    NSDictionary* oneDict = [_cellData dataDict];
    NSString* ContentStr = [oneDict valueForKey:Quize_Content];
    NSDictionary* userDict = nil;
    
    
    UIImage* askiconImage = [UIImage imageNamed:@"img_question.png"];
    UIImage* replayiconImage = [UIImage imageNamed:@"img_answer.png"];
    UIImage* askbackImage = [UIImage imageNamed:@"img_expert_basemap.png"];
    UIImage* replaybackImage = [UIImage imageNamed:@"img_user_basemap.png"];
    _qOrAFlagView.image = nil;
    
    NSString* content = nil;
    NSString* contentFomated = nil;
    NSString* creat_time = nil;
    int repostCount = 0;
    int commentCount = 0;
    int talkType = 2013;
    
    
    if (_cellData.tag == STage_QuestionNeedsReply)
    {
        NSDictionary* weiboDict = [oneDict valueForKey:@"wb_data"];
        
        userDict = [weiboDict valueForKey:Quize_User];
        creat_time = [weiboDict valueForKey:Quize_CreateAt];
        repostCount = [[weiboDict valueForKey:Quize_RepostCount] intValue];
        commentCount = [[weiboDict valueForKey:Quize_CommentCount] intValue];
        talkType = 0;
        _relativeQATip.hidden = NO;
        _relativeQATip.text = @"回复问题";
        _relativeQATip.textColor = [MyTool colorWithHexString:@"#DD7079"];
    }
    else
    {
        userDict = [oneDict valueForKey:Quize_User];
        creat_time = [oneDict valueForKey:Quize_CreateAt];
        repostCount = [[oneDict valueForKey:Quize_RepostCount] intValue];
        commentCount = [[oneDict valueForKey:Quize_CommentCount] intValue];
        talkType = [[oneDict valueForKey:Quize_TalkType] intValue];
        _relativeQATip.hidden = YES;
    }
    NSString* tapSpace = @"                             ";
    NSString* name = nil;
    name = [userDict valueForKey:Quize_User_ScreenName];
    NSString* text = [NSString stringWithFormat:@"%@：%@%@", name, ContentStr, tapSpace];
    switch (talkType)
    {
        case 0://question
        {
            NSString* fomatedText = [NSString stringWithFormat:@"<font  size=14 color='#61ACB6'>%@</font>：<font size=14 color='#333333'>%@</font>%@", name, ContentStr, tapSpace];
            contentFomated = [NSString stringWithFormat:@"       %@", fomatedText];
            content = [NSString stringWithFormat:@"       %@", text];
            
            [_qOrAFlagView setImage:askiconImage];
            [_vIconImageView setImage:askbackImage];
            _separateImageView.hidden =  YES;
            _cellType = CellAsk;
        }
            break;
        case 1://answer
        {
            NSString* fomatedText = [NSString stringWithFormat:@"<font size=14 color='#DD7079'>%@</font>：<font size=14 color='#333333'>%@</font>%@", name, ContentStr, tapSpace];
            contentFomated = [NSString stringWithFormat:@"       %@", fomatedText];
            content = [NSString stringWithFormat:@"       %@", text];
            
            [_qOrAFlagView setImage:replayiconImage];
            [_vIconImageView setImage:replaybackImage];
            _separateImageView.hidden =  NO;
            _cellType = CellAns;
        }
            break;
        case 2://zi ping
        {
            NSString* fomatedText = [NSString stringWithFormat:@"<font size=14 color='#DD7079'>%@</font>：<font size=14 color='#333333'>%@</font>%@", name, ContentStr, tapSpace];
            contentFomated = fomatedText;
            content = text;
            
            _qOrAFlagView.image = nil;
            _separateImageView.hidden =  NO;
            [_vIconImageView setImage:replaybackImage];
            _cellType = CellSingle;
        }
            break;
        default:
            
            break;
    }
    
    _weiboTextFomated = contentFomated;
    _weiboText = content;
    
    //_weiboContent frame
    _weiboContent.lineSpacing = QACellContentLineSpacing;
    _weiboContent.font = [UIFont systemFontOfSize:WeiBoContentFontSize];
    _weiboContent.text = _weiboText;
    
    CGSize sizeOptimum = [_weiboContent optimumSize];
    CGRect frame = _weiboContent.frame;
    frame.size.height = sizeOptimum.height;
    _weiboContent.frame = frame;
    
    if (_cellType == FavoriteList) {
        _wbFavorite.hidden = YES;
    }
    
    if (creat_time) {
        _timeLable.text = creat_time;
    }
    NSString* repCountStr = [NSString stringWithFormat:@"         (%d)", repostCount];
    _repostLable.text = repCountStr;
    
    NSString* commentCountStr = [NSString stringWithFormat:@"  (%d)", commentCount];
    _commentLable.text = commentCountStr;
    
    // get image from url
    NSString* avatarUrl =  [userDict valueForKey:Quize_User_Avatar];
    NSURL* Url = [NSURL URLWithString:avatarUrl];
    [_avatarImageView setImageWithURL:Url];
    
    if (_cellData.newsType == DataModelType_Single && _cellData.tag == Stage_MyQuestionList)//Stage_MyQuestionList
    {
        _relativeQATip.hidden = NO;
        _relativeQATip.text = @"相关问答";
        _relativeQATip.textColor = [MyTool colorWithHexString:@"#61ACB6"];
    }
    //vip
    //    UIImage* vImage = [UIImage imageNamed:@"bg_viconlist.png"];
    //    BOOL verified = [[userDict objectForKey:Quize_Verified] boolValue];
    //    if (verified)
    //    {
    //        [cell.vIconImageView setImage:vImage];
    //    }
    //    else
    //    {
    //        [cell.vIconImageView setImage:nil];
    //    }
    
}

-(void) qACellLayoutSubviews
{
    if (_cellData == nil) {
        return;
    }

    _weiboContent.text = _weiboTextFomated;
    int yPos = _weiboContent.frame.origin.y + _weiboContent.frame.size.height;
//    CGSize sizeOptimum = [_weiboContent optimumSize];
//    int yPos = 9 + sizeOptimum.height;
    
    if ( (_cellData.newsType == DataModelType_Single && _cellData.tag == Stage_MyQuestionList)
        || _cellData.tag == STage_QuestionNeedsReply) {
        self.relativeQATip.frame = CGRectMake(235, yPos+3, 80, 16);
        yPos += (3 + 16 + 5);
    }
    
    self.timeLable.frame = CGRectMake(65, yPos+6.0, 80, 16);
    self.wbFavorite.frame = CGRectMake(142, yPos+1.0, 35, 24);
    
    
    self.wbRepost.frame = CGRectMake(180, yPos+2.0, 50, 24);
    self.repostLable.frame = CGRectMake(191, yPos+5.0, 56, 16);
    
    self.wbComment.frame = CGRectMake(252, yPos+2.0, 50, 24);
    //NSLog(@"cell frame: %@, button :%@", self.frame.origin, _wbComment.frame.origin);
    self.commentLable.frame = CGRectMake(268, yPos+5.0, 56, 16);
    
    self.separateImageView.frame = CGRectMake(0, yPos+5.0+16+8, DeviceScreenWidth, 1);
    
    //tou xiang dian ji
    if (_cellType == 1 || _cellType == 2)//expert
    {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showExpertDetail:)];
        [_avatarImageView addGestureRecognizer:tap];
        _avatarImageView.userInteractionEnabled = YES;
        [tap release];
    }
}

- (void)showExpertDetail : (UITapGestureRecognizer*)tap
{
    if ([_delegate respondsToSelector:@selector(headImageOfExpertTapedInCell:)]) {
        [_delegate headImageOfExpertTapedInCell:self];
    }
}

-(void)reloadData
{
    self.userInteractionEnabled = YES;
    
    if (!_hasInited) {
        _hasInited = YES;
        [self.contentView addSubview:_containsView];
        
    }
    //头像圆角
    //    self.avatarImageView.layer.masksToBounds = YES;
    //    self.avatarImageView.layer.cornerRadius = 6.0;
    
    self.weiboContent.text = _weiboContent.text;
}

#pragma mark --- Button Click Action
-(IBAction)favoriteClickWithSender:(id)sender
{
    if ([_delegate respondsToSelector:@selector(cell:favoriteClicked:)]) {
        [_delegate cell:self favoriteClicked:sender];
    }
}
-(IBAction)repostClickWithSender:(id)sender
{
    
    if ([_delegate respondsToSelector:@selector(cell:repostClicked:)]) {
        [_delegate cell:self repostClicked:sender];
    }
}
-(IBAction)commentClickWithSender:(id)sender
{
    if ([_delegate respondsToSelector:@selector(cell:commentClicked:)]) {
        [_delegate cell:self commentClicked:sender];
    }
}

#pragma mark - Cell Class Method
+ (RTLabel*)textLabel
{
	RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(65, 9, 235, 68)];
    [label setParagraphReplacement:@""];
	return [label autorelease];
}

+ (float) CellHeight : (DataModel*) quizeModel
{
    float fHeight = 0.0;
    
    NSDictionary* oneDict = [quizeModel dataDict];
    
    NSDictionary* userDict = nil;
    
    if (quizeModel.tag == STage_QuestionNeedsReply)
    {
        userDict = [[oneDict valueForKey:@"wb_data"] valueForKey:Quize_User];
    }
    else
    {
        userDict = [oneDict valueForKey:Quize_User];
    }
    
    NSString* name = [userDict valueForKey:Quize_User_ScreenName];
    NSString* ContentStr = [oneDict valueForKey:Quize_Content];
    
    NSString* WeiboStr = [NSString stringWithFormat:@"%@：%@", name, ContentStr];
    
    int talkType = [[oneDict valueForKey:Quize_TalkType] intValue];
    NSString* content = nil;
    switch (talkType)
    {
        case 0:
            content = [NSString stringWithFormat:@"       %@", WeiboStr];
            break;
        case 1:
            content = [NSString stringWithFormat:@"       %@", WeiboStr];
            break;
        default:
            content = WeiboStr;
            break;
    }
    
    RTLabel* label = [QuestionAnswerCell textLabel];
    label.lineSpacing = QACellContentLineSpacing;
    label.font = [UIFont systemFontOfSize:WeiBoContentFontSize];
    label.text = content;
    CGSize sizeOptimum = [label optimumSize];
    
    //9 离上面的距离， 5.0 正文与评论BUTTON间距离， 16 评论BUTTON， borderMargin borderMargin
    //1. 有相关问答标签
    if ( (quizeModel.newsType == 1 && quizeModel.tag == 30) // DataModelType_Single 1  Stage_MyQuestionList 30
        || quizeModel.tag == 28) //STage_QuestionNeedsReply 28
    {
        fHeight = 9 +  sizeOptimum.height + 5.0 + 16 + 10 + 3 + 16 + 5;
    }
    else //无相关问答标签
    {
        fHeight = 9 +  sizeOptimum.height + 5.0 + 16 + 10;
    }
    
    return fHeight;
}
@end

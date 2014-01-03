//
//  OfflineQAsTableviewCell.m
//  babyfaq
//
//  Created by PRO on 13-7-12.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "OfflineQAsTableviewCell.h"
#import "defines.h"
#import "MyTool.h"

#define OfflineQuestionFont     [UIFont systemFontOfSize:16.0f]
#define OfflineAnswerFont       [UIFont systemFontOfSize:16.0f]

#define textContentWidth                                    280
#define textContentBorderWidth                              20


@implementation OfflineQAsTableviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initSubView
{

    UIImage* askImage = [UIImage imageNamed:@"img_question.png"];
    UIImageView* ask = [[UIImageView alloc] initWithImage:askImage];
    ask.frame = CGRectMake(0, 0, 20, 20);;
    
    _questionLable = [[UILabel alloc] init];
    [_questionLable setBackgroundColor:[UIColor clearColor]];
    [_questionLable setFont:OfflineQuestionFont];
    [_questionLable setTextColor:[MyTool colorWithHexString:@"#61ACB6"]];
    [_questionLable setNumberOfLines:0];
    [_questionLable setLineBreakMode:NSLineBreakByWordWrapping];
    
    [_questionLable addSubview:ask];
    [ask release];
    [self.contentView addSubview:_questionLable];


    UIImage* replyImage = [UIImage imageNamed:@"img_answer.png"];
    UIImageView* reply = [[UIImageView alloc] initWithImage:replyImage];
    reply.frame = CGRectMake(0, 0, 20, 20);
    
    _answerLable = [[UILabel alloc] init];
    [_answerLable setBackgroundColor:[UIColor clearColor]];
    [_answerLable   setFont:OfflineAnswerFont];
    [_answerLable setTextColor:[UIColor blackColor]];
    [_answerLable setNumberOfLines:0];
    [_answerLable setLineBreakMode:NSLineBreakByWordWrapping];
    
    [_answerLable addSubview:reply];
    [reply release];
    [self.contentView addSubview:_answerLable];
    
    //bottom line
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_cutline.png"]];
    imageView.tag = 2015;
    [self.contentView addSubview:imageView];
    [imageView release];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    //set frame
    
    CGRect mainRect = self.bounds;
    int borderMargin = textContentBorderWidth;
    mainRect = CGRectMake(mainRect.origin.x + borderMargin, mainRect.origin.y + borderMargin, mainRect.size.width - 2*borderMargin, mainRect.size.height - 2*borderMargin);
    
    CGSize size = CGSizeMake(textContentWidth, 2000);
    
    _questionLable.frame = CGRectMake(textContentBorderWidth, 10, textContentWidth, mainRect.size.height);
    CGSize labelsize = [_questionLable.text sizeWithFont:OfflineQuestionFont constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    _questionLable.frame = CGRectMake(textContentBorderWidth, 10, labelsize.width, labelsize.height);
    
    
    _answerLable.frame = CGRectMake(textContentBorderWidth, _questionLable.frame.origin.y +_questionLable.frame.size.height + 8.0, textContentWidth, mainRect.size.height);
    labelsize = [_answerLable.text sizeWithFont:OfflineAnswerFont constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    _answerLable.frame = CGRectMake(textContentBorderWidth, _questionLable.frame.origin.y+_questionLable.frame.size.height+5.0, labelsize.width, labelsize.height);
    
    //bottom line
    UIImageView* bottomLine = (UIImageView*)[self.contentView viewWithTag:2015];
    bottomLine.frame = CGRectMake(0, _answerLable.frame.origin.y+_answerLable.frame.size.height + 10, DeviceScreenWidth, 1);
}

-(void) setOfflineDM:(DataModel *)offlineDM
{
    [_offlineDM release];
    _offlineDM = [offlineDM retain];
    
    NSDictionary* dic = [_offlineDM dataDict];
    NSString* q = [dic valueForKey:OfflineDBFeedTitle];
    if (q) {
        _questionLable.text = [NSString stringWithFormat:@"       %@", q];
    }
    
    NSString* a = [dic valueForKey:OfflineDBFeedResult];
    if (a) {
        _answerLable.text = [NSString stringWithFormat:@"       %@", a];
    }
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGRect mainRect = CGRectMake(0, 0, DeviceScreenWidth, 2000);
    int borderMargin = textContentBorderWidth;
    mainRect = CGRectMake(mainRect.origin.x + borderMargin, mainRect.origin.y + borderMargin, mainRect.size.width - 2*borderMargin, mainRect.size.height - 2*borderMargin);
    CGRect contentRect = CGRectMake(textContentBorderWidth, 0, textContentWidth, mainRect.size.height);
    CGRect questonRect, answerRect;
    questonRect.size = [_questionLable.text sizeWithFont:OfflineQuestionFont constrainedToSize:contentRect.size];
    answerRect.size = [_answerLable.text sizeWithFont:OfflineAnswerFont constrainedToSize:contentRect.size];

    CGSize totalSize = CGSizeZero;
    totalSize.width = DeviceScreenWidth;
    totalSize.height = questonRect.size.height + 8.0 + answerRect.size.height  + 20 + 1;
    
    return totalSize;    
}


- (void)dealloc
{
    [_offlineDM release], _offlineDM = nil;
    [_answerLable release], _answerLable = nil;
    [_questionLable release], _questionLable = nil;
    [super dealloc];
}
@end

//
//  ExpertInfoCell.m
//  babyfaq
//
//  Created by PRO on 13-6-8.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "ExpertInfoCell.h"
#import "defines.h"

@implementation ExpertInfoCell

#define expertCellBoderMargin 12

#pragma -
#pragma mark -Life Circle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"ExpertInfoCell" owner:self options:nil];
    }
    return self;
}

- (void)dealloc {

    [_expertModel release];
    [super dealloc];
}

- (void)setExpertModel:(DataModel *)expertModel
{
    [_expertModel release];
    _expertModel = [expertModel retain];
    
    _companyName.text = [_expertModel valueForKey:EXPERT_HOSPITAL];
    _position.text = [_expertModel valueForKey:EXPERT_POSITION];
    _expertName.text = [_expertModel valueForKey:EXPERT_NAME];
    _expertOnlineTime.text = [_expertModel valueForKey:EXPERT_WEEKDAY];
}

-(void)reloadData
{
//    if (!hasInited) {
//        hasInited = YES;
        [self.contentView addSubview:_containsView];
//    }
    
}

#pragma mark - Button Click Action

- (IBAction)btnAskQuestionClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cell:askQuestionClicked:)] ) {
        [_delegate cell:self askQuestionClicked:sender];
    }
}
- (IBAction)btnAllQAClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cell:allQAClicked:)] ) {
        [_delegate cell:self allQAClicked:sender];
    }
}

-(void)initSubViews
{
    if (_expertModel == nil) {
        return;
    }
    
    BOOL hideAskBtn =  NO;
    if( [[_expertModel valueForKey:EXPERT_DISABLE] isEqualToString:@"1"] )
        hideAskBtn = YES;
    
    int xPos = 88;
    int yPos = 20;
    int iHeight = 150;
    int iWidth1 = 149, iWidth2 = 130;
    
    if (hideAskBtn) {
        iWidth1 = 200;
        iWidth2 = 200;
    }
        
    CGRect NameRect =  CGRectMake(xPos, yPos, iWidth1, iHeight);
    NameRect.size = [_expertName.text sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:NameRect.size];
    _expertName.frame = CGRectMake(xPos, yPos, NameRect.size.width, NameRect.size.height);
    
    _bakLable.frame = CGRectMake(xPos, yPos, iWidth1, iHeight);
    _bakLable.text = _expertName.text;
    [_bakLable sizeToFit];
    
    CGPoint lastPoint = CGPointMake(0, 0);
    if(NameRect.size.height == 20) //判断是否折行
    {
        lastPoint = CGPointMake(_bakLable.frame.origin.x + _bakLable.frame.size.width + 4, 11);
        
    }
    if (NameRect.size.height > 20)
    {
        lastPoint = CGPointMake(_expertName.frame.origin.x + (int)NameRect.size.width % (int)NameRect.size.width + 22.0,   NameRect.size.height - 9);
    }
    
    self.vsignImageView.frame = CGRectMake(lastPoint.x, lastPoint.y, 16, 16);
    _bakLable.text = @"";
    
    yPos += NameRect.size.height + 5;
    CGRect ComRect = CGRectMake(xPos, yPos, iWidth2, iHeight);
    ComRect.size = [_companyName.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:ComRect.size];
    _companyName.frame = CGRectMake(xPos, _expertName.frame.origin.y + _expertName.frame.size.height + 5, ComRect.size.width, ComRect.size.height);
    
    yPos += ComRect.size.height + 3;
    CGRect WorkRect = CGRectMake(xPos,  yPos, iWidth2, iHeight);
    WorkRect.size = [_position.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:WorkRect.size];
    _position.frame = CGRectMake(xPos, _companyName.frame.origin.y + _companyName.frame.size.height + 3, WorkRect.size.width, WorkRect.size.height);
    
    yPos += WorkRect.size.height + 3;
    CGRect oneLineRect = CGRectMake(xPos, yPos, iWidth1, iHeight);
    oneLineRect.size = [_expertOnlineTime.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:oneLineRect.size];
    _expertOnlineTime.frame =CGRectMake(xPos, _position.frame.origin.y + _position.frame.size.height + 3, oneLineRect.size.width, oneLineRect.size.height);
    
    UIImageView* bk = (UIImageView*)[self viewWithTag:2013];
    UIImage* image = bk.image;
    image = [image stretchableImageWithLeftCapWidth:0 topCapHeight:20];
    bk.image = image;
    CGRect frame = bk.frame;
    frame.size.height = self.frame.size.height - 10;
    bk.frame = frame;
    
    // ask button 
    UIButton* askBtn = (UIButton*)[self viewWithTag:20130703];
    askBtn.hidden = NO;
    if (hideAskBtn) {
        askBtn.hidden = YES;
    }
}


-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        [self initSubViews];
    }
}



-(CGSize)sizeThatFits:(CGSize)size
{
    if (_expertModel == nil) {
        return CGSizeZero;
    }
    
//    CGRect mainRect = CGRectMake(0, 0, DeviceScreenWidth, 2000);
//    mainRect = CGRectMake(mainRect.origin.x + expertCellBoderMargin, mainRect.origin.y + expertCellBoderMargin, mainRect.size.width - 2*expertCellBoderMargin, mainRect.size.height - 2*expertCellBoderMargin);
 
    BOOL hideAskBtn =  NO;
    if( [[_expertModel valueForKey:EXPERT_DISABLE] isEqualToString:@"1"] )
        hideAskBtn = YES;
    
    
    int xPos = 100;
    int yPos = 16;
    int iHeight = 150;
    int iWidth1 = 149, iWidth2 = 130;
    
    if (hideAskBtn) {
        iWidth1 = 200;
        iWidth2 = 200;
    }

    
    CGRect NameRect =  CGRectMake(xPos, yPos, iWidth1, iHeight);
    NameRect.size = [_expertName.text sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:NameRect.size];
    
    yPos += NameRect.size.height + 5;
    CGRect ComRect = CGRectMake(xPos, yPos, iWidth2, iHeight);
    ComRect.size = [_companyName.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:ComRect.size];
    
    yPos += ComRect.size.height + 3;
    CGRect WorkRect = CGRectMake(xPos, yPos, iWidth2, iHeight);
    WorkRect.size = [_position.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:WorkRect.size];

    yPos += WorkRect.size.height + 3;
    CGRect oneLineRect = CGRectMake(xPos,  yPos, iWidth1, iHeight);
    oneLineRect.size = [_expertOnlineTime.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:oneLineRect.size];
    
    yPos += oneLineRect.size.height + expertCellBoderMargin;
    CGSize totalSize = CGSizeMake(DeviceScreenWidth, 106);
    if (yPos > 106) {
        totalSize.height = yPos;
    }
    return totalSize;
}

@end

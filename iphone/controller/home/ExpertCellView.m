//
//  ExpertCellView.m
//  babyfaq
//
//  Created by PRO on 13-6-24.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "ExpertCellView.h"
#import <QuartzCore/CALayer.h>

@implementation ExpertCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView* view  = [[[NSBundle mainBundle] loadNibNamed:@"HeaderFocusView" owner:self options:nil] lastObject];
        [self addSubview:view];
    }
    return self;
}

- (void)setExpertModel:(DataModel *)expertModel
{
    if (_expertModel != nil)
        [_expertModel release];
    _expertModel = [expertModel retain];
    
    self.labelName.text = [_expertModel valueForKey:EXPERT_NAME];
    self.labelPostion.text = [_expertModel valueForKey:EXPERT_HOSPITAL]; //EXPERT_INTRO
    self.labelIntroducton.text = [_expertModel valueForKey:EXPERT_POSITION];
    self.labelTime.text = [_expertModel valueForKey:EXPERT_WEEKDAY];
    
    NSString* avatarimgUrl = [_expertModel valueForKey:EXPERT_PROFILEIMG];
    NSURL* url = [NSURL URLWithString:avatarimgUrl];
   _imagePhoto.layer.masksToBounds = YES;
    self.imagePhoto.layer.cornerRadius = 6.0;
    [_imagePhoto setImageWithURL:url];
}


- (void)dealloc
{
    [_expertModel release], _expertModel = nil;
    [super dealloc];
}
@end

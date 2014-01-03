//
//  fastShowTableViewCell.m
//  babyfaq
//
//  Created by YANGJINGXI on 13-6-20.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "fastShowTableViewCell.h"

@implementation fastShowTableViewCell
@synthesize classLable, bg_image;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       // self.selectionStyle = UITableViewCellSelectionStyleNone;
        [[NSBundle mainBundle] loadNibNamed:@"fastShowTableViewCell" owner:self options:nil];
        [self.contentView addSubview:classLable];
        
    }
    return self;
}
-(void)dealloc
{
    [classLable release];    
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end


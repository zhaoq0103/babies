//
//  OfflineQAsTableView.m
//  babyfaq
//
//  Created by PRO on 13-7-12.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "OfflineQAsTableView.h"
#import "DataModel.h"
#import "OfflineQAsTableviewCell.h"


@implementation OfflineQAsTableView


- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
        self.dataSource = self;
        self.delegate = self;
        self.bNeedRefresh = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -  Data Source and TableView Delegate
#pragma mark  1.tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataModel* oneQuize = self.sourceData[indexPath.row];
    
    static NSString *userIdentifier = @"OfflineQandATableCell";
    
    OfflineQAsTableviewCell *cell = (OfflineQAsTableviewCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
    if (cell==nil)
    {
        cell = [[[OfflineQAsTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
    }
    cell.offlineDM = oneQuize;
    
    CGSize fitSize = [cell sizeThatFits:CGSizeZero];
    
    if (indexPath.row == self.sourceData.count-1) { //last one
        return fitSize.height - 10; // see sizeThatFits function
    }
    
    return fitSize.height;
}


#pragma mark  2.tableview data source delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowNum = indexPath.row;
    
    static NSString *userIdentifier = @"OfflineQandATableCell";
    OfflineQAsTableviewCell* cell = (OfflineQAsTableviewCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
    if (cell == nil)
    {
        cell = [[[OfflineQAsTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
    }
    
    cell.offlineDM = self.sourceData[rowNum];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}


@end

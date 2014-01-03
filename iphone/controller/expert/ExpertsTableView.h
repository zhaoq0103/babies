//
//  ExpertsTableView.h
//  babyfaq
//
//  Created by PRO on 13-6-19.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "BaseTableView.h"
#import "ExpertInfoCell.h"

@interface ExpertsTableView : BaseTableView <UITableViewDataSource,UITableViewDelegate, ExpertInfoCell_Delegate>

//@property(nonatomic, retain) NSArray* experts;

@end

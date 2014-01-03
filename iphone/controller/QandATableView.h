//
//  QandATableView.h
//  babyfaq
//
//  Created by PRO on 13-6-19.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "BaseTableView.h"
#import "QuestionAnswerCell.h"

@interface QandATableView : BaseTableView<UITableViewDataSource,UITableViewDelegate, QuestionAnswerCell_Delegate>
{
    NSArray*    _Args;
}


@property(nonatomic,assign)NSInteger cellType; //收藏列表中不再显示收藏

@end

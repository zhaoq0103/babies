//
//  OfflineQAsTableviewCell.h
//  babyfaq
//
//  Created by PRO on 13-7-12.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface OfflineQAsTableviewCell : UITableViewCell
{
    UILabel*            _questionLable;
    UILabel*            _answerLable;
}


@property(nonatomic, retain)DataModel* offlineDM;

@end

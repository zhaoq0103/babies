//
//  ExpertCellView.h
//  babyfaq
//
//  Created by PRO on 13-6-24.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface ExpertCellView : UIView
{
    
}

@property(nonatomic, retain) DataModel*                     expertModel;

@property (nonatomic, retain) IBOutlet UILabel              *labelName;
@property (nonatomic, retain) IBOutlet UILabel              *labelPostion;
@property (nonatomic, retain) IBOutlet UILabel              *labelIntroducton;
@property (nonatomic, retain) IBOutlet UILabel              *labelTime;

@property (nonatomic, retain) IBOutlet UIImageView          *imagePhoto;


@end

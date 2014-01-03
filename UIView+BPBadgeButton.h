//
//  UIButton+BPBadgeButton.h
//  Anchor3
//
//  Created by liuqiang on 12-3-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MKNumberBadgeView;

@interface UIView (BPBadgeButton)

@property (nonatomic) NSUInteger badge;

-(MKNumberBadgeView *)badgeView;

@end

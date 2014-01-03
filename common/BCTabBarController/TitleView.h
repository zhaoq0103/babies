//
//  TitleView.h
//  sinaUC
//
//  Created by shieh fabo on 11-8-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TitleView : UIView {
    UIImage* titleImage;
    UILabel* textLabel;
    NSString* title;
    UIColor* titleColor;
    UIFont* titleFont;
    UIImageView* titleImageView;
}

@property(nonatomic,retain)UIImage* titleImage;
@property(nonatomic,retain)NSString* title;
@property(nonatomic,retain)UIColor* titleColor;
@property(nonatomic,retain)UIFont* titleFont;
@property(nonatomic,retain)UILabel* textLabel;

@end

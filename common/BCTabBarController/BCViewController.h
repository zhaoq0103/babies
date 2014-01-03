//
//  BCViewController.h
//  SinaNews
//
//  Created by shieh exbice on 11-11-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleView.h"
#import "BCNavigationBar.h"

@interface BCViewController : UIViewController
{
    BCNavigationBar* mNavigationBar;
    BOOL mNavigationBarHiden;
    float mNavigationBarHeight;
    UIView* containView;
    UIView* titleView;
    UIButton* backButton;
    BOOL showBackBtn;
    BOOL hasNib;
    BOOL containFillBounds;
    BOOL hasInited;
}

@property(nonatomic,retain)BCNavigationBar* navigationBar;
@property(nonatomic,assign)BOOL navigationBarHiden;
@property(nonatomic,assign)float navigationBarHeight;
@property(nonatomic,retain)UIView* containView;
@property(nonatomic,retain)UIView* titleView;
@property(nonatomic,retain)UIButton* backButton;
@property(nonatomic,assign)BOOL showBackBtn;
@property(nonatomic,assign)UIColor* titleColor;
@property(nonatomic,assign)UIFont* titleFont;
@property(nonatomic,assign)UIImage* titleImage;
@property(nonatomic,assign)BOOL containFillBounds;


-(void)backBtnClicked:(UIButton*)sender;

+(void)setDefaultNavigationBarBackgroundImage:(UIImage*)aImage;
+(void)setDefaultNavigationBarHeight:(float)height;
+(void)setDefaultNavigationBarBackBtn:(UIButton*)backBtn;
+(void)setDefaultNavigationBarTitleColor:(UIColor*)titleColor;
+(void)setDefaultNavigationBarExtraImageView:(UIImageView*)extraView;

@end

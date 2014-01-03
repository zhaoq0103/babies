//
//  BCMultiTabBar.h
//  SinaNews
//
//  Created by shieh exbice on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCTabBar.h"
#import "BCTab.h"

@class BCMultiTabBar;

@protocol BCMultiTabBarDelegate <NSObject>

-(NSArray*)multiTabBar:(BCMultiTabBar*)multiTabBar tabsForIndex:(NSIndexPath*)index;
- (void)multiTabBar:(BCMultiTabBar *)multiTabBar didSelectTabAtIndex:(NSIndexPath*)index;
- (void)multiTabBar:(BCMultiTabBar *)multiTabBar invalidTabAtIndex:(NSIndexPath*)index;
- (void)multiTabBar:(BCMultiTabBar *)multiTabBar coverimageAppear:(float)offset;

@end

@interface BCMultiTabBar : UIView<BCTabBarDelegate>
{
    NSInteger _multiCount;
    NSMutableArray* _tabBarArray;
    id<BCMultiTabBarDelegate> delegate;
    NSInteger selectedMovement;
}

@property(nonatomic,assign)NSInteger multiCount;
@property(nonatomic,retain)NSMutableArray* tabBarArray;
@property (nonatomic, assign) UIImage *arrowImage;
@property (nonatomic, assign) id<BCMultiTabBarDelegate> delegate;
@property (nonatomic, assign) NSInteger showedMaxItem;
@property (nonatomic, assign) NSInteger selectedAlignment;
@property (nonatomic, assign) UIImage *barBackgroundImage;
@property (nonatomic, assign) UIColor *barBackgroundColor;
@property (nonatomic, assign) UIImage *selectedImage;
@property (nonatomic, assign) UIImage *leftArrowImage;
@property (nonatomic, assign) UIImage *rightArrowImage;
@property (nonatomic, assign) NSInteger selectedMovement;
@property (nonatomic, assign) BOOL arrowCoverScroll;

- (id)initWithFrame:(CGRect)frame heights:(NSArray*)heightArray;
-(void)reloadData;
-(void)reloadDataForRow:(NSInteger)row;
-(NSInteger)curRowForTabBar:(BCTabBar*)aTabBar;

@end

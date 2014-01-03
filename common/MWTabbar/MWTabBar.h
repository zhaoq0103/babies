//
//  MWTabBar.h
//  babyfaq
//
//  Created by mayanwei on 13-5-24.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MWTabBarDelegate;

#define kTabBarHeight 49.0f

@interface MWTabBar : UIView
{
	NSMutableArray *_buttons;
    id <MWTabBarDelegate> _delegate;
}
@property (nonatomic, assign) id <MWTabBarDelegate> delegate;
@property (nonatomic, retain) NSMutableArray        *buttons;
//@property (nonatomic, retain) UIImageView           *bkImage;

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray;
- (void)selectTabAtIndex:(NSInteger)index;

@end

@protocol MWTabBarDelegate<NSObject>
@optional
- (void)tabBar:(MWTabBar *)tabBar didSelectIndex:(NSInteger)index;
@end


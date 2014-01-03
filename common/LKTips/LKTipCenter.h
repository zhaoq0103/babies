//
//  LKTipCenter.h
//  SK
//
//  Created by luke on 10-11-17.
//  Copyright 2010 pica.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LKTipView;
@class LKTip;

@interface LKTipCenter : NSObject {
	
	BOOL active;
	//id<LKTipDelegate> delegate;
@private
	NSMutableArray *tips;
	LKTipView *tipView;
	LKTip *curTip;
    UILabel *topTop;
    UIView* LogWindow;
    NSTimeInterval curTopTipDuration;
    NSInteger extraTopTipWidth;
    CGRect mStatusFrame;
    BOOL showingTopTip;
    UIView* centertipView;
@private
    NSMutableArray* topMessageArray;
}

@property(nonatomic,retain)UIView* LogWindow;
@property(nonatomic,retain)UIView* centertipView;
@property(nonatomic,assign)BOOL curStatusBarHidden;

+ (LKTipCenter *)defaultCenter;

- (void)postTipWithMessage:(NSString *)message time:(NSTimeInterval)dTime;
- (void)postFallingTipWithMessage2:(NSString *)message time:(NSTimeInterval)dTime;
- (void)postTipWithMessage:(NSString *)message image:(UIImage *)image time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore;
- (void)postTipWithMessage:(NSString *)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore;
- (void)postFallingTipWithMessage:(NSString *)message time:(NSTimeInterval)dTime;
-(void)postTopTipWithMessage:(NSString *)message time:(NSTimeInterval)dTime color:(UIColor*)aColor;
-(void)postCenterTipWithMessage:(NSString*)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore parentView:(UIView*)view;
-(void)postSmallCenterTipWithMessage:(NSString*)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore parentView:(UIView*)view;
-(void)postCenterTipWithMessage:(NSString*)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore parentView:(UIView*)view font:(UIFont*)font;
-(void)postSmallTophalfTipWithMessage:(NSString*)message time:(NSTimeInterval)dTime ignoreAddition:(BOOL)ignore parentView:(UIView*)view;
@end

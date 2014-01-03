//
//  LKLoadingCenter.h
//  SK
//
//  Created by luke on 10-11-22.
//  Copyright 2010 pica.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LKLoadingView;

@interface LKLoadingCenter : NSObject {
	
@private
	LKLoadingView *loadingView;
    BOOL ignoreTouched;
}

+ (LKLoadingCenter *)defaultCenter; 
- (void)postLoadingWithTitle:(NSString *)title message:(NSString *)msg;
- (void)postLoadingWithTitle:(NSString *)title message:(NSString *)msg ignoreTouch:(BOOL)ignore;
- (void)disposeLoadingView;
- (void)disposeLoadingViewAndIgnoreTouch:(BOOL)ignore;

-(void)reversalLoadingView:(UIInterfaceOrientation)interfaceOrientation;


@end

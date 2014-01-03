//
//  LKLoadingView.h
//  SK
//
//  Created by luke on 10-11-18.
//  Copyright 2010 pica.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LKLoadingView : UIView {
	
@private
	UIActivityIndicatorView *activity;
	BOOL myhidden;
	
	NSString *title;
	NSString *message;
	float radius;
}

@property (nonatomic, retain) UIActivityIndicatorView *activity;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) float radius;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;
- (id)initWithTitle:(NSString *)title;

- (void)startAnimating;
- (void)stopAnimating;

@end

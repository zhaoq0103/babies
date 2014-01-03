//
//  LKWebViewController.h
//  SK
//
//  Created by luke on 10-12-8.
//  Copyright 2010 pica.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCViewController.h"

@interface LKWebViewController : BCViewController <UIWebViewDelegate> {

	IBOutlet UIWebView *webView;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UIBarButtonItem *preButton;
	IBOutlet UIBarButtonItem *priButton;
	IBOutlet UIBarButtonItem *refreshButton;
	IBOutlet UIBarButtonItem *actionButton;
	
	NSURL *url;
	BOOL			isViewAppeared;
	BOOL			isNeedChangeSkin;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, retain) UIBarButtonItem *preButton;
@property (nonatomic, retain) UIBarButtonItem *priButton;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;
@property (nonatomic, retain) UIBarButtonItem *actionButton;

@property (nonatomic, retain) NSURL *url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *)aUrl;
- (IBAction)goPrepage;
- (IBAction)goPripage;
- (IBAction)refreshPage;
- (IBAction)actionButtonPressed;
@end

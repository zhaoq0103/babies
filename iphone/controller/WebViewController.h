//
//  WebViewController.h
//
//  Created by pro
//  Copyright (c) 2013年 liaohy. All rights reserved.
//

#import "RootViewController.h"

@interface WebViewController : RootViewController
{
    NSString*       _url;
    UILabel*       _webPageTitleLabel;
    BOOL           _bGetContent;
}

@property (retain, nonatomic) IBOutlet UIWebView *web;

- (id)initWithURL : (NSString*)url;
- (id)initWithURL : (NSString*)url andNeedParser:(BOOL)bNeed;

- (IBAction)goBack:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)goFarward:(id)sender;
@end

//
//  WebViewController.m
//
//  Created by pro
//  Copyright (c) 2013年 liaohy. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _searchBar.hidden = YES;
    
    _web.scalesPageToFit = NO;
    NSURL* url = [NSURL URLWithString:_url];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_web loadRequest:request];
    
    if (_webPageTitleLabel) {
        _webPageTitleLabel.text = [NSString stringWithString:@"网页加载中..."];
    }
    //导航栏加载提示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithURL : (NSString*)url
{
    self = [super init];
    if (self) {
        _url = [url copy];
    }
    
    return self;
}

// if need custom webview,use this initer
- (id)initWithURL : (NSString*)url andNeedParser:(BOOL)bNeed
{
    return nil;
}

- (void)initOfflineView
{
    //do nothing
}

#pragma mark - Button Action

- (IBAction)goBack:(id)sender {
    if ([_web canGoBack]) {
        [_web goBack];
    }
}

- (IBAction)refresh:(id)sender {
    [_web reload];
}

- (IBAction)goFarward:(id)sender {
    if ([_web canGoForward]) {
        [_web goForward];
    }
}


- (void)dealloc {
    [_web release];
    [_url release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWeb:nil];
    [super viewDidUnload];
}

#pragma UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //导航栏加载提示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (_webPageTitleLabel) {
        _webPageTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];//获取网页标题
    }
}


- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    _webPageTitleLabel = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
}
@end

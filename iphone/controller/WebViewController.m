//
//  WebViewController.m
//
//  Created by pro
//  Copyright (c) 2013年 liaohy. All rights reserved.
//

#import "WebViewController.h"
#import "RegexKitLite.h"
#import "defines.h"

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
    _bGetContent = NO;
    
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
    OCSafeRelease(_web.delegate);
    OCSafeRelease(_web);
    OCSafeRelease(_url);

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
  
    if (!_bGetContent) {
        if (_webPageTitleLabel) {
            _webPageTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];//获取网页标题
        }
        
        //artibodyTitle  We use document.title
        //NSString* title = [webView stringByEvaluatingJavaScriptFromString: @" document.getElementById('artibodyTitle').innerHTML " ];
        
        NSString* text = [webView stringByEvaluatingJavaScriptFromString: @" document.getElementById('artibody').innerHTML " ];
        if (![text isKindOfClass:[NSString class]] || text.length <= 0)
        {
            return;
        }
        
        //NSOperationQueue
        [self performSelector:@selector(parseContent:) withObject:text];
        
        _bGetContent = YES;
 
    }
}

-(NSString*) parseContent:(NSString*)content
{
    NSString* reg =  @"(\\w+[,，.。!！、:：;；]?)+(?=(\\s*(</strong>)?\\s*</p>))";
    
    NSArray* texts = [content componentsMatchedByRegex:reg];
    //handle file content
    NSString* file = @"123321";
    for (NSString* p in texts) {
        //file = [file stringByAppendingString:p];
    }
    NSLog(@"%@", file);
    
    //    [webView stringByEvaluatingJavaScriptFromString: @" var script = document.createElement('script'); "
    //     " script.type = 'text/javascript'; "
    //     " script.text = \"function getHeader() { "
    //     " var g_title = document.getElementById('artibodyTitle').innerHTML; "
    //     //" var re = '/<[^<>]*?font[^<>]*?>/gi;' "
    //     //" g_title = g_title.replace(re,""); "
    //     " return \"hello\"; "
    //     " }\"; "
    //     " document.getElementsByTagName('head')[0].appendChild(script); " ];
    //
    //    NSString* title = [webView stringByEvaluatingJavaScriptFromString: @" getHeader(); " ];
    
    //    getHeader : function(){
    //        var g_title=document.getElementById("artibodyTitle").innerHTML;
    //        var re = /<[^<>]*?font[^<>]*?>/gi;
    //        g_title = g_title.replace(re,"");
    //        return g_title;
    //    }
    //
    //    getContent : function(){
    //        var g_text=document.getElementById("artibody").innerHTML;
    //        var re = /<[^<>]*?font[^<>]*?>/gi;
    //        g_text = g_text.replace(re,"");
    //        return g_text;
    //    }
}

- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    _webPageTitleLabel = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
}
@end

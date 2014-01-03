//
//  RootViewController.m
//  babyfaq
//
//  Created by mayanwei on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "RootViewController.h"
#import "defines.h"
#import "SeachResultViewController.h"
#import "ExpertSearchViewController.h"

#define SearchBarBaseTag        6666
@interface RootViewController ()
{

}

@end

@implementation RootViewController

#pragma mark --- life circle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _uiInited = NO;
    _searchBar.hidden = YES;
    
    [self setBKImage];
    [self initSearchView];
    [self initNavgationBar];
    [self initTableViewFooter];
    [self initOfflineView];
}

- (void)setBKImage
{
    UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:controllerBKImage]];
    imgView.frame = CGRectMake(0, 0, DeviceScreenWidth, DeviceScreenHeight);
    [self.view insertSubview:imgView atIndex:0];
    [imgView release];
}

//give a chance for child to change offline view
- (void)initOfflineView
{
    _offlineView = [[UIView alloc] initWithFrame:CGRectZero];

    UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:controllerBKImage]];
//    imgView.frame = _offlineView.frame;
    imgView.tag = 2013;
    [_offlineView addSubview:imgView];
    _offlineView.backgroundColor = [UIColor redColor];
    [imgView release];
    
    UILabel* tips = [[UILabel alloc] initWithFrame:CGRectZero];
    tips.backgroundColor = [UIColor clearColor];
    tips.tag = 2014;
    tips.font = [UIFont systemFontOfSize:17.0];
    tips.textColor = [UIColor colorWithRed:97/255.0 green:172/255.0 blue:182/255.0 alpha:1.0];
    [tips setText:@"您现在是离线状态!"];
    
    [_offlineView addSubview:tips];
    [tips release];
    
    [self.view addSubview:_offlineView];
    
    [self layoutOfflineSubViews];
}

//give a chance for child to layout offline subview
-(void)layoutOfflineSubViews
{
    int iHeight = 0;
    
    if ([_searchBar isHidden] && (self.navigationController.viewControllers.count == 1) ) {//expert page, personcenter page
        iHeight = DeviceScreenHeight-StatusBarHeight-appNavigationBarHeight-appTabBarHeight;
        _offlineView.frame = CGRectMake(0, 0, DeviceScreenWidth, iHeight);
    }
    else if(![_searchBar isHidden] && (self.navigationController.viewControllers.count == 1) )
    {
        iHeight = DeviceScreenHeight-StatusBarHeight-appNavigationBarHeight-20-appSearchBarHeight-appTabBarHeight;
        _offlineView.frame = CGRectMake(0, 20 + appSearchBarHeight, DeviceScreenWidth, iHeight);
    }
    else
    {
        iHeight = DeviceScreenHeight-StatusBarHeight-appNavigationBarHeight;
        _offlineView.frame = CGRectMake(0, 0, DeviceScreenWidth, iHeight);
    }
    
    UIImageView* bkImag = (UIImageView*)[_offlineView viewWithTag:2013];
    bkImag.frame = CGRectMake(0, 0, _offlineView.frame.size.width, _offlineView.frame.size.height);
    
    UILabel* tips = (UILabel*)[_offlineView viewWithTag:2014];
    tips.frame = CGRectMake((DeviceScreenWidth-180)/2 + 20, (iHeight-20)/2 - 40, DeviceScreenWidth, 20);
}

- (BOOL) updataUI4LineStatues
{
    NetworkStatus _stat = [[ UIApplication sharedApplication].delegate netWorkStatus];    
    if (_stat == NotReachable) { 
        [self setIsOffline:YES];
        return NO;
    }

    [self setIsOffline:NO];
    return YES;
}


- (void) setIsOffline:(BOOL)isOffline
{
    if (_offlineView) {      
        if (isOffline) {
            _offlineView.hidden = NO;
            [self.view bringSubviewToFront:_offlineView];
        }
        else
        {
            _offlineView.hidden = YES;
            [self initAllUI];
        }
    }
}

- (void)reloadTableViewDataSource:(BOOL)needDown
{
    //for child override to refresh
}
- (void) initAllUI
{
    //for child override to refresh ui
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
   
    [_searchBar release];
    [_footerViewButton release], _footerViewButton = nil;
    [_offlineView release], _offlineView = nil;
    
     [super dealloc];
}

- (void) initTableViewFooter
{
    //2.footer - get more data
    _footerViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, DeviceScreenWidth, 50)];
    _footerViewButton.tag = 2013;
    _footerViewButton.backgroundColor = [UIColor clearColor];
    [_footerViewButton setTitle:@"上拉加载更多..." forState:UIControlStateNormal];
    [_footerViewButton setTitleColor:[UIColor colorWithRed:97.0/255.0 green:172.0/255.0 blue:182.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    _footerViewButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    
    UIActivityIndicatorView* waitingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    waitingView.frame = CGRectMake(50, 15, 20, 20);
    waitingView.tag = 201307;
    waitingView.hidden = YES;
    [_footerViewButton addSubview:waitingView];
    [waitingView release];
}

- (void) showTableViewFooter : (BOOL)bshow
{
    
}
#pragma mark --- about search bar
- (void)initSearchView
{
    if(!_searchBar)
    {
        _searchBar = [[[[NSBundle mainBundle] loadNibNamed:@"CustomSearchBar" owner:self options:nil] lastObject] retain];
       // [_searchBar setBackgroundColor:[UIColor whiteColor]];
        [_searchBar setFrame:CGRectMake(10, 10, 300, 44)];
        
        [self.view addSubview:_searchBar];
        _searchBar.eventDelegate = self;
        _searchBar.target = self;
        _searchBar.searchAction = @selector(goSearch);
        _searchBar.editBeginAction = @selector(editBegin);
        _searchBar.editEndAction = @selector(editEnd);
    }
}

//使用搜索引擎搜索
- (void)goSearch
{
    NSLog(@"goSearch");
    if (_searchBar.keywordText .text == @"" || _searchBar.keywordText .text == Nil || _searchBar.keywordText .text.length == 0) {
        return;
    }
    
    if ( _searchBar.tag == 1)//专家图搜索
    {
        ExpertSearchViewController* resultVC = [[ExpertSearchViewController alloc] initWithNibName:@"ExpertSearchViewController" bundle:nil];
        resultVC.keyWords =  _searchBar.keywordText.text;
        
//        if ([self.eventDelegate respondsToSelector:@selector(itemInnerCellClickedAction_PushViewController:animate:)]) {
//            [self.eventDelegate itemInnerCellClickedAction_PushViewController:resultVC animate:YES];
//        }
         [self.navigationController pushViewController:resultVC animated:YES];
        [resultVC release];
    }
    else // pu tong sou suo
    {
        //问答搜索
        SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
        resultVC.title = @"问答搜索";
        resultVC.keyWords =  _searchBar.keywordText.text;
        resultVC.searchBarTag  = SearchBarBaseTag;
        
        if (_searchBar.tag > SearchBarBaseTag)
        {
            int a = _searchBar.tag - SearchBarBaseTag;
            if (a > 500) { //my question
                resultVC.searchType = QuizeList;
            }
            else // fen lei zi sou suo
            {
                resultVC.searchType = SearchbyGroup;
                NSString* catID = [NSString stringWithFormat:@"%d", _searchBar.tag - SearchBarBaseTag ];
                resultVC.cateid = catID;
            }
        }
        else        //default keywords search
        {
            resultVC.searchType = SearchbyWords;
        }
        
        [self.navigationController pushViewController:resultVC animated:YES];
        [resultVC release];
    }
    
    //    _page = 0;
    //    [self showWaitingView:YES];
    //    [WebApi searchWebVideo:_searchBar.keywordText.text page:(_page + 1) withDelegate:self context:REQUESTCONTEXT_SEARCH];
    //
    //    if(([Setting getPrivacyMask] & PRIVACYTYPESEARCH) == PRIVACYTYPESEARCH && _searchBar.keywordText.text.length > 0)
    //    {
    //        //保存关键词
    //        Keyword *keyword = [[Keyword alloc] init];
    //        keyword.name = _searchBar.keywordText.text;
    //        [Keyword insert:keyword];
    //        [keyword release];
    //        _clearButton.enabled = YES;
    //
    //        if(_keywords)
    //        {
    //            [_keywords release];
    //            _keywords = nil;
    //        }
    //        _keywords = [[Keyword getKeywords:KEYWORDTYPEUSER] retain];
    //        [_historyTable reloadData];
    //    }
}

- (void)editBegin
{
    //search history
}

- (void)editEnd
{
    //search history
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"resing first responder");
    [_searchBar.keywordText resignFirstResponder];
}

#pragma mark - Custom Navigaion Bar

- (void)initNavgationBar
{
    [self initNavigationLeftItem];
    [self initNavigationTitleItem];
    [self initNavigationRightItem];
}

- (void)initNavigationLeftItem
{
    //spaceBtn only get a pos
    UIButton *spaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    spaceBtn.frame = CGRectMake(0, 13, 2, 2);
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 13, 20, 20);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* leftItem = [[[UIBarButtonItem alloc] initWithCustomView:spaceBtn] autorelease];
    UIBarButtonItem* leftItem2 = [[[UIBarButtonItem alloc] initWithCustomView:leftBtn] autorelease];
    
    NSArray* items = @[leftItem, leftItem2];
    
    float osVer = [[UIDevice currentDevice].systemVersion floatValue];
    if (osVer >= 5.0) {
        self.navigationItem.leftBarButtonItems = items;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = leftItem2;
    }
}

- (void)initNavigationTitleItem
{
    UILabel* customLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    //[customLab setTextColor:[UIColor blueColor]];
    [customLab setTextColor:[UIColor colorWithRed:254.0/255.0 green:248.0/255.0 blue:225.0/255.0 alpha:1.0]];
    [customLab setText:nil];
    customLab.textAlignment = UITextAlignmentCenter;
    customLab.backgroundColor = [UIColor clearColor];
    customLab.tag = 200;
    customLab.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = customLab;
    [customLab release];
}

- (void)initNavigationRightItem
{

}

- (void)leftBtnClick:(UIButton *)button
{
    [self.navigationController   popViewControllerAnimated:YES];
}

- (void)rightBtnClick:(UIButton *)button
{
    
}

- (void) hideSearchBarKeyBoard
{
    [_searchBar.keywordText resignFirstResponder];
}

#pragma mark - TableViewEvent_Delegate
-(void)pullDownToRefresh:(UITableView*) tableView
{
    //for overload
}
-(void)pullUpToLoadMoreData:(UITableView*) tableView
{
        //for overload
}

-(void)itemInnerCellClickedAction_PushViewController : (UIViewController*)controller animate:(BOOL) animate
{
    [self.navigationController pushViewController:controller animated:animate];
}


#pragma mark - Basic Handle Notification

- (BOOL)isThisNotificationWanted : (NSNotification*) notify
{
    NSDictionary* usrInfo = [notify userInfo];
    NSNumber*   id = [usrInfo valueForKey:RequsetSender];
    if (id != nil ) {
        return (int)self == [id intValue];
    }
    
    return NO;
}

@end

//
//  HomeViewController.m
//  babyfaq
//
//  Created by mayanwei on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "HomeViewController.h"
#import "CommentDataList.h"
#import "DataCenter.h"
#import "MessageManager.h"
#import "LKLoadingCenter.h"
#import "defines.h"
#import "RegValueSaver.h"

#import "SeachResultViewController.h"
#import "LoginViewController.h"
#import "HeaderFocusView.h"
#import "fastShowTableViewCell.h"
#import "OfflineQAsTableView.h"
#import "DataBaseSaver.h"


typedef enum{
    SearchNotificationT = 1,
    SearchFaildedNotificationT,
    ExpertMsgNotificationT,
    ExperClassFaildedNotificationT,
    SearchArrayNotificationT,
    SearchArrayFaildedNotificationT,
    LoginSuccessedNotificationT,
    ExpertDetailsInfoNotificationT,
    ExpertDetailsInfoFaildedNotificationT,
    NeedReplyQuestionNotificationT,
    NeedReplyQuestionFaildedNotificationT,
    ReplyedAnQuestionNotificationT,
    UserInfoSuccessGetNotificationT
} HomePageNotifyType;

@interface HomeViewController ()
{

}
@end

@implementation HomeViewController

#pragma mark - life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _bAnExpertLogined  = NO;
        _bQuestionsNeedReplyReady = NO;
        
        _btnNewAskAnswer.selected = YES;
        _btnAllAskAnswer.selected = NO;
        _bFastMenuDataReady = NO;
        _bRecommendExpertDataReady = NO;
        _bLatestQADataReady = NO;
        _bAllQADataReady = NO;
        
        self.searchID = [[DataCenter getInstance]   searchgroupID];
        self.searchArray = [[NSMutableArray alloc]initWithCapacity:0];
        self.searchArgs = [[DataCenter getInstance]     searchArgs];
        self.expertID = [[DataCenter getInstance] expertID];
        
        _bNewQua = YES;
        
        _bForceRefreshRecommendExpertData = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL  isOnLine = [self updataUI4LineStatues];
    if (isOnLine)
    {
        [self initAllUI];
    }
}

- (void) initAllUI
{
    //refresh UI
    if (_uiInited == NO) {
        [self initView];
        [self initNotification];
        [self reloadTableViewDataSource: YES];
        
        _btnNewAskAnswer.selected = YES;
        _btnAllAskAnswer.selected = NO;
        self.searchResultTable.tag = 2013;
        
        UITapGestureRecognizer *fastShowBgViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fastShowBgViewClicked:)];
        [_fastShowBgView addGestureRecognizer:fastShowBgViewGesture];
        [fastShowBgViewGesture release];
    }
    
    //refresh data
    if (_uiInited == YES) {
        if ( !_bFastMenuDataReady || !_bRecommendExpertDataReady || !_bLatestQADataReady || !_bAllQADataReady || _bForceRefreshRecommendExpertData) {
            [self reloadTableViewDataSource:YES];
        }
    }
    
    // refresh finish
    _uiInited = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    [_btnNewAskAnswer release];
    [_btnAllAskAnswer release];
    [_fastShowView release];
    [_searchArray release];
    [_searchID release];
    [_classIDArray release];
    [_fastShowBgView release];
    [super dealloc];
}

- (void)initView
{
    [self initNavgationBar];
    [self initFocusView];
    [self initSubViews];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //1.tableview footer
    if (_btnNewAskAnswer.selected && !_bAnExpertLogined) //recommend experts
    {
        [self showTableViewFooter:NO];
    }
    else
    {
        [self showTableViewFooter:YES];
    }
    
}

- (void) showTableViewFooter : (BOOL)bshow
{
    if (bshow) {
        self.searchResultTable.tableFooterView = self.footerViewButton;
    }
    else
        self.searchResultTable.tableFooterView = nil;
}

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
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"btn_list.png"] forState:UIControlStateNormal];
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
    //custom about title here
    self.title = @"首页";
    [super initNavigationTitleItem];   
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"首页"];
    
}

- (void)initNavigationRightItem
{
    [self setLoginButtonImage:NO];
}

- (void)initFocusView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HeaderFocusView2" owner:self options:nil];
    HeaderFocusView *focusView = [array objectAtIndex:0];
    [focusView setParentViewController:self];
    
    [focusView setTag:1];
    [self.FocusView addSubview:focusView];
}

- (void)initSubViews
{
    int yPos = 10 + 113 + 30 +10;//10 margin, 113 focusheader height, 30 button height
    self.searchResultTable = [[QandATableView alloc] initWithFrame:CGRectMake(0, yPos, DeviceScreenWidth, DeviceScreenHeight-yPos-appNavigationBarHeight-appTabBarHeight-StatusBarHeight) style:UITableViewStylePlain];
    [self.view addSubview:_searchResultTable];
    _searchResultTable.eventDelegate = self;
    
    //search bar
    _searchBar.hidden = YES;
    _searchBar.target = self;
    _searchBar.searchAction = @selector(searchQAsByKeywords);
}

-(void) searchQAsByKeywords
{
    //问答搜索
    SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
//    resultVC.title = @"问答搜索";
    resultVC.keyWords =  _searchBar.keywordText.text;
    resultVC.title = _searchBar.keywordText.text;
    resultVC.searchType = SearchbyWords;
    [self.navigationController pushViewController:resultVC animated:YES];
    [resultVC release];
}

#pragma mark - NavigationBar Button Click Action

- (void)leftBtnClick:(UIButton *)button
{
    //1.hide keyboard first
    [self hideSearchBarKeyBoard];
    
    NetworkStatus _stat = [[ UIApplication sharedApplication].delegate netWorkStatus];
    if (_stat == NotReachable || _bFastMenuDataReady == NO)
    {
        NSString*   tips = @"离线状态,请检查网络后重试!";
        if (_bFastMenuDataReady == NO)
        {
            tips =  @"数据未就绪,请稍候!";
        }
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示"
                                                      message:tips
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else
    {
        if (self.fastShowView.hidden == YES)
        {
            self.fastShowView.hidden = NO;
            self.fastShowBgView.hidden = NO;
            [self.view bringSubviewToFront:_fastShowBgView];
            [self.view bringSubviewToFront:_fastShowView];
        }
        else if(self.fastShowView.hidden == NO)
        {
            self.fastShowView.hidden = YES;
            self.fastShowBgView.hidden = YES;
        }
    }
}

- (void)rightBtnClick:(UIButton *)button
{
    //登陆界面
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (!Logined)
    {
        LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginView animated:NO];
        [loginView release];
    }
    else
    {
        UIAlertView* loginAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经登录, 确定要退出登录吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [loginAlertView show];
        [loginAlertView release];
    }
}

- (void) tapLoginLogout : (UITapGestureRecognizer*)tap
{
    [self rightBtnClick:nil];
}

#pragma mark - BUTTON click action
- (IBAction)btnNewAskAnswerClicked:(id)sender
{
    [self hideFastMemuAndKeyBoard];
    
    if (_btnNewAskAnswer.selected == YES) {
        return;
    }
    _btnNewAskAnswer.selected = YES;
    _btnAllAskAnswer.selected = NO;
    
//    _bNewQua = YES;
    if (_bAnExpertLogined) {
        self.searchResultTable.sourceData = _needReplyQsArray;
        self.searchResultTable.tag = 2013;
        [self showTableViewFooter:YES];
    }
    else
    {
        self.searchResultTable.sourceData = _searchNewResultArray;
        [self showTableViewFooter:NO];
    }
    
    _searchType = ExpertAllAns;
    if (!_bLatestQADataReady) {
        [self reloadTableViewDataSource: YES];
    }
    else
        [self reloadTableData:NO]; //YES --- SCROLL TO TOP

}
- (IBAction)btnAllAskAnswerClicked:(id)sender
{
    [self hideFastMemuAndKeyBoard];
    
    if (_btnAllAskAnswer.selected == YES) {
        return;
    }
    _btnNewAskAnswer.selected = NO;
    _btnAllAskAnswer.selected = YES;
    [self showTableViewFooter:YES];
//    _bNewQua = NO;
    self.searchResultTable.sourceData = _searchResultArray;
    self.searchResultTable.tag = 2014;
    _searchType = ExpertAllAns;
    if (!_bAllQADataReady) {
        _bLatestQADataReady = NO;
        [self reloadTableViewDataSource: YES];
    }
    else
        [self reloadTableData:NO]; //YES --- SCROLL TO TOP

}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource:(BOOL)needDown
{
    if(!needDown)
    {
        BOOL needRefresh = [self checkRefreshByDate:self.searchID];//self.expertID
        if (needRefresh)
        {
            needDown = YES;
        }
    }
    if (needDown)
    {
       // [[LKLoadingCenter defaultCenter] postLoadingWithTitle:nil message:@"载入中..." ignoreTouch:NO];
        
        //fast menu
        if (!_bFastMenuDataReady) {
            [[MessageManager getInstance] startGetSearchGroupWithSender:self];
        }
        
        if (!_bRecommendExpertDataReady || _bForceRefreshRecommendExpertData) {
            //recommand expert
            [[MessageManager getInstance] startGetExpertMsgWithSender:self args:nil];
        }

        if (!_bLatestQADataReady && !_bAnExpertLogined) {
            //all QA
            [[MessageManager getInstance] startGetAllQAInWeiboWithSender:self page:1];
        }
        else if(_bAnExpertLogined && !_bQuestionsNeedReplyReady)
        {
            [[MessageManager getInstance] startGetQuestionsNeedReplyWithSender:self page:1];
        }
    }
    else
    {
        // latest data
    }
}

-(BOOL)checkRefreshByDate:(NSArray*)IDArray
{
    return YES;
    
    BOOL rtval = NO;
    CommentDataList* dataList = [[DataCenter getInstance] searchgroupList];
    NSDate* oldDate = [dataList dateInfoWithIDList:IDArray];
    if (oldDate)
    {
        NSTimeInterval length = [oldDate timeIntervalSinceDate:[NSDate date]];
        length = abs(length);
        if (length > HttpRequstRefreshTime)
        {
            rtval = YES;
        }
    }
    else
        rtval = YES;
    return rtval;
}

#pragma mark - InitNotification and the Action

-(void)initNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    SEL action = @selector(handleNotification:);
    //QA List
    [nc addObserver:self
           selector:action
               name:SearchNotification
             object:nil];
    
    [nc addObserver:self
           selector:action
               name:SearchFaildedNotification
             object:nil];
   //recommand expert
    [nc addObserver:self
           selector:action
               name:ExpertMsgNotification
             object:nil];
    
    [nc addObserver:self
           selector:action
               name:ExperClassFaildedNotification
             object:nil];
    
    //fast menu
    [nc addObserver:self
           selector:action
               name:SearchArrayNotification
             object:nil];
    
    [nc addObserver:self
           selector:action
               name:SearchArrayFaildedNotification
             object:nil];
    
    //login - for set button image
    [nc addObserver:self
           selector:action
               name:LoginSuccessedNotification
             object:nil];
    
    //expert detail - for judge if is an expert logined
    [nc addObserver:self
           selector:action
               name:ExpertDetailsInfoNotification
             object:nil];
    [nc addObserver:self
           selector:action
               name:ExpertDetailsInfoFaildedNotification
             object:nil];
    // need reply question
    [nc addObserver:self
           selector:action
               name:NeedReplyQuestionNotification
             object:nil];
    [nc addObserver:self
           selector:action
               name:NeedReplyQuestionFaildedNotification
             object:nil];
    
    // replyed
    [nc addObserver:self
           selector:@selector(replyAnQuestionSuccessed:)
               name:ReplyedAnQuestionNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(loginOutSuccess:)
               name:LogoutSuccessedNotification
             object:nil];
    
    //UserInfoSuccessGetNotification
    [nc addObserver:self
           selector:@selector(userInfoGetSuccessd:)
               name:UserInfoSuccessGetNotification
             object:nil];
    //专家回复成功刷新
    [nc addObserver:self
           selector:@selector(ExpertNewAskListRefesh:)
               name:ExpertCommentSuccessNotification
             object:nil];
}

-(void)ExpertNewAskListRefesh:(NSNotification*)notify
{
//    self.searchResultTable.sourceData = _needReplyQsArray;
//    self.searchResultTable.tag = 2013;
         _bQuestionsNeedReplyReady = NO;
    [self reloadTableViewDataSource:YES];

}
-(void)loginOutSuccess:(NSNotification*)notify
{
    [self setLoginButtonImage:NO];
}

- (void) handleNotification:(NSNotification*)notify
{
    //所有界面接收登陆
     NSString* name = [notify name];
    if (name == LoginSuccessedNotification) {
        [self loginSuccessed:notify];
    }
    //1. if this notify is about self
    BOOL myNotify = [self isThisNotificationWanted:notify];
    if (!myNotify)
        return;
    
    NSArray* notifyNames = @[SearchNotification, SearchFaildedNotification, ExpertMsgNotification,ExperClassFaildedNotification,SearchArrayNotification,SearchArrayFaildedNotification,LoginSuccessedNotification,ExpertDetailsInfoNotification,ExpertDetailsInfoFaildedNotification,NeedReplyQuestionNotification,NeedReplyQuestionFaildedNotification];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:notifyNames.count];
    for (int i=1; i<notifyNames.count+1; ++i) {
        [dic setValue:[NSNumber numberWithInt:i] forKey:notifyNames[i-1]];
    }
    HomePageNotifyType type = [[dic valueForKey:name] intValue];

    switch (type) {
        case SearchNotificationT:
        {
            [self SearchObjectsAdded:notify];            
        }
            break;
        case SearchFaildedNotificationT:
        {
            [self SearchObjectsFailed:notify];
        }
            break;
        case ExpertMsgNotificationT:
        {
            [self recommentExpertsAdded:notify];
        }
            break;
        case ExperClassFaildedNotificationT:
        {
            [self recommentExpertsFailed:notify];
        }
            break;
        case SearchArrayNotificationT:
        {
            [self SearchArrayObjectsAdded:notify];
        }
            break;
        case SearchArrayFaildedNotificationT:
        {
            [self SearchArrayObjectsFailed:notify];
        }
            break;
        case LoginSuccessedNotificationT:
        {
          //  [self loginSuccessed:notify];
        }
            break;
        case ExpertDetailsInfoNotificationT:
        {
            [self anExpertLogin:YES];
            [self showTableViewFooter:YES];
        }
            break;
        case ExpertDetailsInfoFaildedNotificationT:
        {
            [self anExpertLogin:NO];
        }
            break;
        case NeedReplyQuestionNotificationT:
        {
            [self NeedReplyQeustionAdded:notify];
        }
            break;
        case NeedReplyQuestionFaildedNotificationT:
        {//do nothing
        }
            break;
        default:
            break;
    }
}

-(void)userInfoGetSuccessd:(NSNotification*)notify
{
    //up date profile_image, we do not use the notify info but it has all userinfo
    [self setLoginButtonImage:YES];
}

-(void)replyAnQuestionSuccessed:(NSNotification*)notify
{
    //update num of un replyed questions
    _bQuestionsNeedReplyReady = NO;
    [[MessageManager getInstance] startGetQuestionsNeedReplyWithSender:self page:1];
}

//recommand experts
-(void)recommentExpertsAdded:(NSNotification*)notify
{
    CommentDataList* dataList = nil;
    dataList = [[DataCenter getInstance] expertList];
    [dataList reloadShowedDataWithIDList:self.expertID];
    _recommendExpertsCount = [dataList contentsCountWithIDList:self.expertID];
    
    if (_recommendExpertsArray == nil) {
        _recommendExpertsArray = [[NSMutableArray alloc] initWithCapacity:_recommendExpertsCount];
    }
    if (_recommendExpertsArray.count > 0) {
        [_recommendExpertsArray removeAllObjects];
    }
    
    DataModel* oneExpert = nil;
    for (int i=0; i<_recommendExpertsCount; ++i) {
        oneExpert = [dataList oneObjectWithIndex:i IDList:self.expertID];
        if (oneExpert)
        {
            [_recommendExpertsArray addObject:oneExpert];
        }
    }
    
    HeaderFocusView* focusView = (HeaderFocusView*)[self.FocusView viewWithTag:1];
    
    _bRecommendExpertDataReady   = YES;
    //show this when notification comes
    [focusView showVideos:_recommendExpertsArray];
}

-(void)recommentExpertsFailed:(NSNotification*)notify
{
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
}

-(void)SearchObjectsAdded:(NSNotification*)notify
{
    //1.save data
    CommentDataList* dataList = [[DataCenter getInstance] searchDateList];
    [dataList reloadShowedDataWithIDList:@[@"search"] ];
    
    _searchResultCount = [dataList contentsCountWithIDList:@[@"search"] ];
    if (_bNewQua) {
        if (_searchNewResultArray == nil) {
            _searchNewResultArray = [[NSMutableArray alloc] initWithCapacity:_searchResultCount];
        }
        if (_searchNewResultArray.count > 0) {
            [_searchNewResultArray removeAllObjects];
        }
        
        DataModel* oneQuize = nil;
        for (int i=0; i<_searchResultCount; ++i) {
            oneQuize = [dataList oneObjectWithIndex:i IDList:@[@"search"] ];
            if (oneQuize)
            {
                [_searchNewResultArray addObject:oneQuize];
            }
        }
        
        if (_btnNewAskAnswer.selected) {
            self.searchResultTable.sourceData = _searchNewResultArray;
            self.searchResultTable.tag = 2014;
        }
        
        _bLatestQADataReady = YES;
        _bNewQua = NO;
    }
    else
    {
        if (_searchResultArray == nil) {
            _searchResultArray = [[NSMutableArray alloc] initWithCapacity:_searchResultCount];
        }
        if (_searchResultArray.count > 0) {
            [_searchResultArray removeAllObjects];
        }
        
        DataModel* oneQuize = nil;
        for (int i=0; i<_searchResultCount; ++i) {
            oneQuize = [dataList oneObjectWithIndex:i IDList:@[@"search"] ];
            if (oneQuize)
            {
                [_searchResultArray addObject:oneQuize];
            }
        }
        
        if (_btnAllAskAnswer.selected) {
            self.searchResultTable.sourceData = _searchResultArray;
        }
        _bAllQADataReady = YES;
    }
    
    
    
    //2. update ui
    NSDictionary* userInfo = [notify userInfo];
    
    int page = [[userInfo objectForKey:@"page"] intValue];
    //    int countNumber = [[userInfo objectForKey:@"count"] intValue];
    int totalPageNum = [[userInfo objectForKey:@"totalPage"]intValue];
    
    if ([CommentDataList checkNumberArrayEqualWithFirstArray:self.searchArgs secondArray:self.searchArgs])
    {
        self.curPage = page;
        //_nothingFind.hidden = YES;
        self.searchResultTable.tableFooterView.hidden = NO;
        
        if (totalPageNum <= 1) {
            self.searchResultTable.tableFooterView.hidden = YES;
        }        
        else if (_curPage < totalPageNum ) {
            self.searchResultTable.bIsThereMoreData = YES;
        }
        else
        {
            self.searchResultTable.bIsThereMoreData = NO;
        }
        
        if (page == 1) {
            [self reloadTableData:YES];
        }
        else
        {
            [self reloadTableData:NO];
        }
    }
    else
    {
        [[LKLoadingCenter defaultCenter] disposeLoadingView];
       // _nothingFind.hidden = NO;
    }

    if (_bAllQADataReady || _bNewQua) {
        [self.searchResultTable dataLoadingFinish];
    }
}

-(void)SearchObjectsFailed:(NSNotification*)notify
{    
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
}

-(void)SearchArrayObjectsAdded:(NSNotification*)notify
{
    CommentDataList* dataList = [[DataCenter getInstance] searchgroupList];
    [dataList reloadShowedDataWithIDList:self.searchID ];
    int count = [dataList contentsCountWithIDList:self.searchID];
    
    if ([self.searchArray count] > 0)
    {
        [self.searchArray removeAllObjects];
    }
    
    NSMutableArray* keyArray = [[NSMutableArray alloc]  initWithCapacity:1];
    for (int i = 0; i< count ; i++)
    {
        DataModel* groupObj = [dataList oneObjectWithIndex:i IDList:self.searchID];
        NSDictionary* groupDict = [groupObj dataDict];
        
        NSArray* allkeys = [groupDict allKeys];
        NSString* key = [allkeys objectAtIndex:0];
        NSString* value = [groupDict objectForKey:key];
        [self.searchArray addObject:value];
        [keyArray addObject:key];
    }
    
    self.classIDArray = keyArray;
    [keyArray release];
    _bFastMenuDataReady = YES;
    [_fastShowView reloadData];
}
-(void)SearchArrayObjectsFailed:(NSNotification*)notify
{
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
}


-(void)loginSuccessed:(NSNotification*)notify
{
    [[MessageManager getInstance] startGetUserInfo];
    [[MessageManager getInstance] startGetSettingInfoWithSender:self];
    
    //judge if is an expert
    NSString* userID = [[RegValueSaver getInstance] readSystemInfoForKey:RegKey_CurrentAccount];
    [[MessageManager getInstance] startGetExpertInfoWithSender:self args:@[userID]];
}
//-(void)loginOutSuccess:(NSNotification*)notify
//{
//    [self setLoginButtonImage:NO];
//}
- (void) anExpertLogin : (BOOL) anExpert
{
    _bAnExpertLogined = anExpert;
    if (_bAnExpertLogined) { //an expert
        [_btnNewAskAnswer setTitle:@"最新问题" forState:UIControlStateNormal];
        if (!_bQuestionsNeedReplyReady) {
            [[MessageManager getInstance] startGetQuestionsNeedReplyWithSender:self page:1];
        }
    }
    else
    { //
        [_btnNewAskAnswer setTitle:@"最新问答" forState:UIControlStateNormal];
        if (_btnNewAskAnswer.selected) {
            self.searchResultTable.sourceData = _searchNewResultArray;
            [self reloadTableData:YES];
        }
    }
}

-(void)NeedReplyQeustionAdded:(NSNotification*)notify
{
    //1.save data
    CommentDataList* dataList = [[DataCenter getInstance] searchDateList];
    [dataList reloadShowedDataWithIDList:@[@"search"] ];
    
    _needReplyQsCount = [dataList contentsCountWithIDList:@[@"search"] ];
    
    if (_needReplyQsArray == nil) {
         _needReplyQsArray = [[NSMutableArray alloc] initWithCapacity:_needReplyQsCount];
    }
    if (_needReplyQsArray.count > 0) {
        [_needReplyQsArray removeAllObjects];
    }
    
    DataModel* oneQuize = nil;
    for (int i=0; i<_needReplyQsCount; ++i) {
        oneQuize = [dataList oneObjectWithIndex:i IDList:@[@"search"] ];
        if (oneQuize)
        {
            [_needReplyQsArray addObject:oneQuize];
        }
    }
    _bQuestionsNeedReplyReady  = YES;
    
    if (_btnNewAskAnswer.selected) {
        self.searchResultTable.sourceData = _needReplyQsArray;
        self.searchResultTable.tag = 2013;
    }
    
    //2. update ui
    NSDictionary* userInfo = [notify userInfo];
    
    int page = [[userInfo objectForKey:@"page"] intValue];
    int total = [[userInfo objectForKey:@"total"]intValue];
    
    if ([CommentDataList checkNumberArrayEqualWithFirstArray:self.searchArgs secondArray:self.searchArgs])
    {
        self.curPage = page;
        
        if (_needReplyQsCount < total) {
            self.searchResultTable.bIsThereMoreData = YES;
        }
        else
        {
            self.searchResultTable.bIsThereMoreData = NO;
        }
        
        if (page == 1) {
            [self reloadTableData:YES];
        }
        else
        {
            [self reloadTableData:NO];
        }
    }
    
    if (_bQuestionsNeedReplyReady) {
        [self.searchResultTable dataLoadingFinish];
    }

    [[LKLoadingCenter defaultCenter] disposeLoadingView];
}
//快捷菜单
#pragma mark - UITableview Delegate - fast menu

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 33;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        int count = [self.searchArray count] + 1;
        return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        int rowNum = indexPath.row;
    
        NSString *userIdentifier = [NSString stringWithFormat:@"searchgrouptList"];
        fastShowTableViewCell* cell = (fastShowTableViewCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
        if (cell==nil)
        {
            cell = [[[fastShowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
        }
    
    if (rowNum == 0)
    {
        cell.classLable.text = QuizeListTitle;
    }
    else
    {
        NSString* groupName = [self.searchArray objectAtIndex:rowNum-1];
        cell.classLable.text = groupName;
    }

    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowNum = indexPath.row;
    if (rowNum == 0) {
        //我的问题
        BOOL Logined = [[MessageManager getInstance] hasLogined];
        if (!Logined)
        {
            LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
            [self.navigationController pushViewController:loginView animated:NO];
            [loginView release];
        }
        else
        {
            SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
            resultVC.title = QuizeListTitle;
            resultVC.searchType = QuizeList;
            [self.navigationController pushViewController:resultVC animated:YES];
            [resultVC release];
        }
    }
    else
    {
        NSString* cateId = [_classIDArray objectAtIndex:rowNum-1];
        NSString* groupName = [self.searchArray objectAtIndex:rowNum-1];

        SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
        resultVC.searchType = SearchbyGroup;
        //resultVC.keyWords = groupName;
        resultVC.cateid = cateId;
        resultVC.title = groupName;
        [self.navigationController pushViewController:resultVC animated:YES];
        [resultVC release];
    }

    [self.fastShowView performSelector:@selector(deselectRowAtIndexPath:animated:) withObject:indexPath];
}

//问答列表
#pragma mark - list

-(void)reloadTableData:(BOOL)scrollTop
{
    //    [[LKLoadingCenter defaultCenter] disposeLoadingView];
    
    //    NSNumber* pageNumber = [dataList infoValueWithIDList:_searchArgs ForKey:@"page"];
    //    if (pageNumber)
    //    {
    //        self.curPage = [pageNumber intValue];
    //    }
    [self.searchResultTable reloadData];
    if(scrollTop)
    {
        [self.searchResultTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}

#pragma mark - TableViewEvent_Delegate
-(void)pullDownToRefresh:(UITableView*) tableView
{
    _bNewQua = YES;
    _bLatestQADataReady = NO;
    _bQuestionsNeedReplyReady = NO;
    [self reloadTableViewDataSource:YES];
}

-(void)pullUpToLoadMoreData:(UITableView*) tableView
{
    if (_offlineView.hidden) {
        _bNewQua = NO;
        if (_bAnExpertLogined && _btnNewAskAnswer.selected)
        { //an expert
            [[MessageManager getInstance] startGetQuestionsNeedReplyWithSender:self page:self.curPage+1];
        }
        else
        { //
            [[MessageManager getInstance] startGetAllQAInWeiboWithSender:self page:self.curPage +  1];
        }
    }
    else //offline mode
    {
        NSArray* offlineDatas = [[DataBaseSaver getInstance] getOfflineDataStartFromPage:_curPageOfOfflineData++ andPageCount:20];
        if (offlineDatas.count > 0) {
            OfflineQAsTableView* tableView = (OfflineQAsTableView*)[_offlineView viewWithTag:2015];
            
            NSMutableArray* oldData = [NSMutableArray arrayWithArray:tableView.sourceData];
            [oldData addObjectsFromArray:offlineDatas];
            
            tableView.sourceData = oldData;
            [tableView reloadData];
            
            [tableView dataLoadingFinish];
        }
    }
}

#pragma mark - UIAlertViewDelegate  - login out
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)// make sure to logout
    {
        [[MessageManager getInstance] startLogout];
        [self setLoginButtonImage:NO];
        
        [self anExpertLogin:NO];
    }
}
         
- (void)setLoginButtonImage : (BOOL)bLogined
{
    //1.    //spaceBtn only get a pos
    UIButton *spaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    spaceBtn.frame = CGRectMake(0, 13, 2, 2);
    
    //2.  头像
    UIImageView* bkDefaultImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]] autorelease];

    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLoginLogout:)];
    [bkDefaultImage addGestureRecognizer:tap];
    [tap release];
    

    
    if (bLogined) //用户头像
    {
        bkDefaultImage.frame = CGRectMake(0, 0, 35, 35);
        bkDefaultImage.userInteractionEnabled = YES;
        bkDefaultImage.layer.cornerRadius = 17.0;
        bkDefaultImage.layer.masksToBounds = YES;
        //img_headpicture.png
        NSString* imageUrl = [[[RegValueSaver  getInstance] readAccountDict] valueForKey:@"profile_image_url"];
        
        if ( imageUrl )
        {
            UIImageView* bkImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_headpicture.png"]] autorelease];
            bkImage.frame = CGRectMake(0, 0, 35, 35);
            //bkImage.userInteractionEnabled = YES;
            bkImage.layer.cornerRadius = 17.0;
            bkImage.layer.masksToBounds = YES;
            [bkDefaultImage addSubview:bkImage];
            
            UIImageView* userHeadImage = [[[UIImageView alloc] initWithFrame:CGRectMake(2.8, 2.8, 30, 30)] autorelease];
            //userHeadImage.image = [UIImage imageNamed:@"btn_list_notlogin.png"]; //默认头像
            userHeadImage.layer.cornerRadius = 16.0;
            userHeadImage.layer.masksToBounds = YES;
            
            NSURL* url = [NSURL URLWithString:imageUrl];
            [userHeadImage setImageWithURL:url];
            [bkDefaultImage addSubview:userHeadImage];
        }
    }
    else
    {
        bkDefaultImage.frame = CGRectMake(0, 0, 20, 20);
        bkDefaultImage.userInteractionEnabled = YES;
        UIImageView* userHeadImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)] autorelease];
        userHeadImage.image = [UIImage imageNamed:@"btn_list_notlogin.png"]; //默认头像
        [bkDefaultImage addSubview:userHeadImage];
    }
    
    
    
    UIBarButtonItem* rightItem = [[[UIBarButtonItem alloc] initWithCustomView:spaceBtn] autorelease];
    UIBarButtonItem* rightItem2 = [[[UIBarButtonItem alloc] initWithCustomView:bkDefaultImage] autorelease];
    
    NSArray* items = @[rightItem, rightItem2];

    
    float osVer = [[UIDevice currentDevice].systemVersion floatValue];
    if (osVer >= 5.0) {
        self.navigationItem.rightBarButtonItems = items;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = rightItem2;
    }
    
}

#pragma mark - Hide FastMemu and Keyboard

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideFastMemuAndKeyBoard];
}

- (void) hideFastMenu
{
    //1.hide fast menu
    if (self.fastShowView.hidden == NO) {
        self.fastShowView.hidden = YES;
        self.fastShowBgView.hidden = YES;
    }
}

- (void)hideFastMemuAndKeyBoard
{
    [self hideFastMenu];
    //2. hide keyboard
    [self hideSearchBarKeyBoard];
}


#pragma mark - Offline Data
- (void)initOfflineView
{
    _offlineView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //1. kb and tips
    UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:controllerBKImage]];
    //    imgView.frame = _offlineView.frame;
    imgView.tag = 2013;
    [_offlineView addSubview:imgView];
    [imgView release];
    
    UILabel* tips = [[UILabel alloc] initWithFrame:CGRectZero];
    tips.backgroundColor = [UIColor clearColor];
    tips.tag = 2014;
    [tips setTextColor:[UIColor colorWithRed:97.0/255.0 green:172.0/255.0 blue:182.0/255.0 alpha:1.0]];
    [tips setText:@"您现在是离线状态,下面是本地知识库!"];
    [_offlineView addSubview:tips];
    [tips release];
    
    //2.offline tableview
    OfflineQAsTableView* dbDataView = [[OfflineQAsTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    dbDataView.eventDelegate   = self;
    dbDataView.tableFooterView = self.footerViewButton;
    dbDataView.tableFooterView.hidden = NO; //21489条数据, so, always think there are more data
    dbDataView.bIsThereMoreData = YES;
    _curPageOfOfflineData = 1;
    NSArray* offlineDatas = [[DataBaseSaver getInstance] getOfflineDataStartFromPage:_curPageOfOfflineData andPageCount:20];
    if (offlineDatas.count > 0) {
        dbDataView.sourceData = offlineDatas;
        [dbDataView dataLoadingFinish];
    }
    
    dbDataView.tag = 2015;
    [_offlineView addSubview:dbDataView];
    [dbDataView release];
    
    //3.
    [self.view addSubview:_offlineView];
    
    [self layoutOfflineSubViews];
}

- (void) layoutOfflineSubViews
{
    //1.
    _searchBar.hidden = NO;
    
    //2.
    int yPos = 64;//self.view.frame.size.height not include statusbar height   self.view.frame.size.height
    int iHeight = DeviceScreenHeight-appNavigationBarHeight-20-appSearchBarHeight-appTabBarHeight - StatusBarHeight;
    _offlineView.frame = CGRectMake(0, yPos, self.view.frame.size.width, iHeight);
    
    UIImageView* bkImag = (UIImageView*)[_offlineView viewWithTag:2013];
    bkImag.frame = CGRectMake(0, 0, _offlineView.frame.size.width, _offlineView.frame.size.height);
    
    UILabel* tips = (UILabel*)[_offlineView viewWithTag:2014];
    tips.frame = CGRectMake(20, 0, DeviceScreenWidth, 20);
    
    //table
    yPos = 30;
    OfflineQAsTableView* tableView = (OfflineQAsTableView*)[_offlineView viewWithTag:2015];
    tableView.frame = CGRectMake(0, yPos, _offlineView.frame.size.width, _offlineView.frame.size.height-yPos);
}
#pragma mark - fastShowgesture
- (void)fastShowBgViewClicked:(UITapGestureRecognizer*)recognizer
{
    _fastShowView.hidden = YES;
    _fastShowBgView.hidden = YES;
}
@end

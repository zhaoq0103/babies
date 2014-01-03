//
//  ExpertViewController.m
//  babyfaq
//
//  Created by mayanwei on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "ExpertViewController.h"
#import "defines.h"
#import "CommentDataList.h"
#import "DataCenter.h"
#import "MessageManager.h"
#import "ExpertInfoCell.h"
#import "ExpertDetailsViewController.h"
#import "LKLoadingCenter.h"
#import "LKTipCenter.h"
#import "MyTool.h"
#import "Reachability.h"
#import "ExpertSearchViewController.h"

typedef enum
{
    ExpertMsgNotificationT = 1,
    ExperClassFaildedNotificationT,
    ExperClassNotificationT,
    ExpertbyGroupNotificationT,
    ExpertbyGroupFaildedNotificationT
    
}ExpertPageNotifocation;

@interface ExpertViewController ()

@end

@implementation ExpertViewController

#pragma -
#pragma -mark Life Circle
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
    BOOL  isOnLine = [self updataUI4LineStatues];
    if (isOnLine)
    {
        [self initAllUI];
    }
}

- (void) initAllUI
{
    if (_uiInited == NO) {
        _bRecommenExpertDataReady = NO;
        _bGroupedExpertDataReady = NO;
        _bGroupedExpertCategoryDataReady = NO;
        
        _bForceRefreshRecommendExpertData = YES;
        
        self.expertID = [[DataCenter getInstance] expertID];
        self.categoryID = [[DataCenter getInstance] GroupID];
        
        UIButton* btn = (UIButton*)[self.view viewWithTag:10];
        btn.selected = YES;
        
        _recommendExpertsCount = 0;
        _groupedExpertsCount = 0;
        
        [self initNotification];
        //load data first
        [self reloadTableViewDataSource: YES];
        [self initSubViews];
    }
    
    //refresh data
    if (_uiInited == YES) {
        if ( !_bRecommenExpertDataReady || !_bGroupedExpertDataReady || !_bGroupedExpertCategoryDataReady || _bForceRefreshRecommendExpertData) {
            [self reloadTableViewDataSource:YES];
        }
    }
    
    // refresh finish
    _uiInited = YES;
}

- (void)initSubViews
{
    //1.header
    int yPos = 94;
    self.expertsList = [[ExpertsTableView alloc] initWithFrame:CGRectMake(0, 94, DeviceScreenWidth, DeviceScreenHeight-StatusBarHeight - appNavigationBarHeight-appTabBarHeight-yPos) style:UITableViewStylePlain];
    _expertsList.eventDelegate = self;
    [self.view addSubview:_expertsList];
}

-(void)layoutOfflineSubViews
{
    //2.search bar
    _searchBar.target = self;
    _searchBar.searchAction = @selector(searchQAsByKeywords);
    _searchBar.keywordText.placeholder = @"请输入专家的名字";
    [super layoutOfflineSubViews];
}

-(void) searchQAsByKeywords
{
    //问答搜索
    ExpertSearchViewController* resultVC = [[ExpertSearchViewController alloc] initWithNibName:@"ExpertSearchViewController" bundle:nil];
    resultVC.keyWords =  _searchBar.keywordText.text;
    [self.navigationController pushViewController:resultVC animated:YES];
    [resultVC release];
}

- (void) showGroupedExpertsCategories : (BOOL)bshow
{
    UIScrollView* headerView = nil;
    
    if (bshow && _bGroupedExpertCategoryDataReady)
    {
        CGRect frame = CGRectMake(0, 0, DeviceScreenWidth, 32);
        UIImage* bkImage = [UIImage imageNamed:@"bg_expert_scrollbar.png"];
        
        headerView = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
        headerView.backgroundColor = [UIColor colorWithPatternImage:bkImage];
        headerView.showsHorizontalScrollIndicator = NO;

        NSArray* ids = [[_categoryNameAndIDDics allKeys] sortedArrayUsingSelector:@selector(compare:)];
        int xPos = 0;
        for (id object in ids)
        {
            int buttonWidth = 40;
            NSString* cateid = object;
            NSString* catName = [_categoryNameAndIDDics valueForKey:object];
            UIColor* fontColor = [MyTool colorWithHexString:@"#666666"];
            UIButton* catButton = [MyTool createButton:catName font:[UIFont systemFontOfSize:15] color:fontColor width:buttonWidth height:26 left:xPos top:3];
            [catButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [catButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
            catButton.tag = [cateid intValue];
            if (catButton.tag == -1) {
                catButton.selected = YES;
            }
            [catButton addTarget:self action:@selector(categoriesItemClicked:) forControlEvents:UIControlEventTouchUpInside];
            xPos += (buttonWidth + 10);
            [headerView addSubview:catButton];
        }
        
        headerView.contentSize = CGSizeMake(xPos, 32);
    }

    self.expertsList.tableHeaderView = headerView;
}

- (void) showTableViewFooter : (BOOL)bshow
{
    if (bshow) {
        self.expertsList.tableFooterView = self.footerViewButton;
    }
    else
        self.expertsList.tableFooterView = nil;
}

-(void) categoriesItemClicked : (UIButton*)button
{
    button.selected = YES;

    for (UIView* btn in self.expertsList.tableHeaderView.subviews)
    {
        if ([btn isKindOfClass:[UIButton class]] && btn.tag != button.tag) {
            ((UIButton*)btn).selected = NO;
        }
    }
    
    NSString* cateid =  [NSString stringWithFormat:@"%d", button.tag];
    [self.categoryID removeAllObjects];
    [self.categoryID addObject:cateid];
    _bGroupedExpertDataReady = NO;
    [self reloadTableViewDataSource:YES];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showTableViewFooter:YES];
//    UIButton* btn1 = (UIButton*)[self.view viewWithTag:10];
//    
//    if (btn1.selected) //recommend experts
//    {
//        [self showGroupedExpertsCategories:NO];
//        [self showTableViewFooter:NO];
//    }
//    else
//    {
//        [self showGroupedExpertsCategories:YES];
//        [self showTableViewFooter:YES];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_btnCommentExperts release];
    [_btnExpertsGroup release];
    [_expertsList release];
    [_categoryNameAndIDDics release], _categoryNameAndIDDics = nil;
    [_groupedExpertsArray release], _groupedExpertsArray = nil;
    [_recommendExpertsArray release], _recommendExpertsArray = nil;
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBtnCommentExperts:nil];
    [self setBtnExpertsGroup:nil];
    [self setExpertsList:nil];
    [super viewDidUnload];
}

#pragma mark - Init Navigation Bar
- (void)initNavigationLeftItem
{
    //nothing
}
- (void)initNavigationTitleItem
{
    //self.title = @"问专家";
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"问专家"];
}

- (void)initNavigationRightItem
{
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
-(BOOL)checkRefreshByDate:(NSArray*)IDArray
{
    return YES;
    
    BOOL rtval = NO;
    CommentDataList* dataList = [[DataCenter getInstance] expertbyGroupList];
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

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource:(BOOL)needDown
{
    BOOL doneLoading = NO;
    if(!needDown)
    {
        BOOL needRefresh = [self checkRefreshByDate:self.categoryID];
        if (needRefresh)
        {
            needDown = YES;
        }
        
        doneLoading = YES;
    }
    
    if (needDown)
    {
        [[LKLoadingCenter defaultCenter] postLoadingWithTitle:nil message:@"载入中..." ignoreTouch:NO];
        //        NetWorked = NO;
        UIButton* btn1 = (UIButton*)[self.view viewWithTag:10];
        
        if (btn1.selected) {
            if (!_bRecommenExpertDataReady || _bForceRefreshRecommendExpertData) {
                //[[MessageManager getInstance] startGetExpertMsgWithSender:self args:nil];
                [[MessageManager getInstance] startGetActiveExpertMsgWithSender:self args:nil page:1];
            }
        }
        //else
        {
            if (!_bGroupedExpertCategoryDataReady)
            {
                [[MessageManager getInstance] startGetExpertClassWithSender:self args:@[@"expertclass"]];
            }
            if (!_bGroupedExpertDataReady) {
                [[MessageManager getInstance] startGetExpertbyGroupWithSender:self args:self.categoryID page:1];
            }
        }
    }
    
    if (!doneLoading)
    {
        [self reloadTableData:NO];
    }
}

-(void)reloadTableData:(BOOL)scrollTop
{
    //tableview    
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
//    CommentDataList* dataList = [[DataCenter getInstance] expertbyGroupList];
//    [dataList reloadShowedDataWithIDList:self.categoryID];
//    NSNumber* pageNumber = [dataList infoValueWithIDList:self.categoryID ForKey:@"page"];
//    if (pageNumber)
//    {
//        self.curPage = [pageNumber intValue];
//    }
 
    [self.expertsList reloadData];
    
    if(scrollTop) //滚动到最上面
    {
        [self.expertsList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}

#pragma mark - InitNotification and the Action 

-(void)initNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    SEL antion = @selector(handleNotification:);
    //recommand experts
    [nc addObserver:self
           selector:antion
               name:ExpertMsgNotification
             object:nil];
    
    [nc addObserver:self
           selector:antion
               name:ExperClassFaildedNotification
             object:nil];
    
    //grouped experts categories
    [nc addObserver:self
           selector:antion
               name:ExperClassNotification
             object:nil];
    
    //grouped experts
    [nc addObserver:self
           selector:antion
               name:ExpertbyGroupNotification
             object:nil];
    
    [nc addObserver:self
           selector:antion
               name:ExpertbyGroupFaildedNotification
             object:nil];
}

-(void)handleNotification: (NSNotification*) notify
{
    BOOL myNotify = [self isThisNotificationWanted:notify];
    if (!myNotify) {
        return;
    }
    NSArray* notifyNames = @[ExpertMsgNotification,ExperClassFaildedNotification,ExperClassNotification,ExpertbyGroupNotification,ExpertbyGroupFaildedNotification];
    NSMutableDictionary* dic =  [NSMutableDictionary dictionaryWithCapacity:notifyNames.count];
    for (int i=1; i<notifyNames.count; i++) {
        [dic setValue:[NSNumber numberWithInt:i] forKey:notifyNames[i-1]];
    }
    NSString* name = [notify name];
    ExpertPageNotifocation  type = [[dic valueForKey:name] intValue];
    switch (type) {
        case ExpertMsgNotificationT:
            [self recommentExpertsAdded:notify];
            break;
        case ExperClassFaildedNotificationT:
             [self recommentExpertsFailed:notify];
            break;
        case ExperClassNotificationT:
             [self ExpertCateNameAndIDAdded:notify];
            break;
        case ExpertbyGroupNotificationT:
             [self ExpertGroupObjectsAdded:notify];
            break;
        case ExpertbyGroupFaildedNotificationT:
             [self ExpertGroupObjectsFailed:notify];
            break;
            
        default:
            break;
    }
}
//recommand experts
-(void)recommentExpertsAdded:(NSNotification*)notify
{
    CommentDataList* dataList = nil;
    dataList = [[DataCenter getInstance] expertList];
    [dataList reloadShowedDataWithIDList:[[DataCenter getInstance] expertActived]];
    _recommendExpertsCount = [dataList contentsCountWithIDList:[[DataCenter getInstance] expertActived]];
    
   
    if (_recommendExpertsArray == nil) {
        _recommendExpertsArray = [[NSMutableArray alloc] initWithCapacity:_recommendExpertsCount];
    }
    if (_recommendExpertsArray.count > 0) {
        [_recommendExpertsArray removeAllObjects];
    }

    DataModel* oneExpert = nil;
    for (int i=0; i<_recommendExpertsCount; ++i) {
        oneExpert = [dataList oneObjectWithIndex:i IDList:[[DataCenter getInstance] expertActived]];
        if (oneExpert)
        {
            [_recommendExpertsArray addObject:oneExpert];
        }
    }
    _bRecommenExpertDataReady = YES;
 
    //2. update ui
    NSDictionary* userInfo = [notify userInfo];
    int page = [[userInfo objectForKey:@"page"] intValue];
    //int countNumber = [[userInfo objectForKey:@"count"] intValue];
    //int totalPageNum = [[userInfo objectForKey:@"totalPage"]intValue];
    int total = [[userInfo objectForKey:@"total"]intValue];
    
    {
        self.curPage = page;
 
        if (_recommendExpertsCount < total)
        {
          self.expertsList.bIsThereMoreData = YES;
        }
        else
        {
            self.expertsList.bIsThereMoreData = NO;
        }
        
        UIButton* btn = (UIButton*)[self.view viewWithTag:10];
        if ( btn.selected)
        {
            self.expertsList.sourceData = _recommendExpertsArray;
            
            if (page == 1)
            {
                [self reloadTableData:YES];
            }
            else
            {
                [self reloadTableData:NO];
            }
        }
    }
   
    
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
    
   //3. up data footer
    if (_bGroupedExpertDataReady) {
        [self.expertsList dataLoadingFinish];
    }

}

-(void)recommentExpertsFailed:(NSNotification*)notify
{
    
}


//groupedExpert categories
-(void)ExpertCateNameAndIDAdded:(NSNotification*)notify
{
    CommentDataList* dataList = [[DataCenter getInstance] classList];
    [dataList reloadShowedDataWithIDList:@[@"expertclass"]];
    int count = [dataList contentsCountWithIDList:@[@"expertclass"]];
    
    if (_categoryNameAndIDDics == nil) {
        _categoryNameAndIDDics = [[NSMutableDictionary alloc] initWithCapacity:10];
        [_categoryNameAndIDDics setValue:@"全部" forKey:@"-1"];
    }
    
    if (_categoryNameAndIDDics.count > 1) {
        [_categoryNameAndIDDics removeAllObjects];
        [_categoryNameAndIDDics setValue:@"全部" forKey:@"-1"];
    }

    for (int i = 0; i < count; i++) {
        DataModel* expertObj = [dataList oneObjectWithIndex:i IDList:@[@"expertclass"]];
        NSDictionary* expertClass  = [expertObj dataDict];
        if (expertClass)
        {
          [_categoryNameAndIDDics addEntriesFromDictionary:expertClass];
        }
    }
    
    _bGroupedExpertCategoryDataReady = YES;
    
    UIButton* btn2 = (UIButton*)[self.view viewWithTag:11];
    if ( btn2.selected)
    {
        [self showGroupedExpertsCategories:YES];
    }
}

//not implement
//-(void)ExpertCateNameAndIDFailed:(NSNotification*)notify
//{
//}

//grouped experts
-(void)ExpertGroupObjectsAdded:(NSNotification*)notify
{
    //1.data
    CommentDataList* dataList = nil;
    dataList = [[DataCenter getInstance] expertbyGroupList];
    [dataList reloadShowedDataWithIDList:self.categoryID];
    _groupedExpertsCount = [dataList contentsCountWithIDList:self.categoryID];
    
    if (_groupedExpertsArray == nil) {
        _groupedExpertsArray = [[NSMutableArray alloc] initWithCapacity:_groupedExpertsCount];
    }
    if (_groupedExpertsArray.count > 0) {
        [_groupedExpertsArray removeAllObjects];
    }

    DataModel* oneExpert = nil;
    for (int i=0; i<_groupedExpertsCount; ++i) {
        oneExpert = [dataList oneObjectWithIndex:i IDList:self.categoryID];
        if (oneExpert)
        {
             [_groupedExpertsArray addObject:oneExpert];
        }
    }

    
    _bGroupedExpertDataReady = YES;
    
    //2. update ui
    NSDictionary* userInfo = [notify userInfo];
    int page = [[userInfo objectForKey:@"page"] intValue];
//    int countNumber = [[userInfo objectForKey:@"count"] intValue];
    int totalPageNum = [[userInfo objectForKey:@"totalPage"]intValue];
        
    if ([CommentDataList checkNumberArrayEqualWithFirstArray:self.categoryID secondArray:self.categoryID])
    {
        self.curPage = page;
        self.expertsList.tableFooterView.hidden = NO;
        
        if (totalPageNum <= 1) {
            self.expertsList.tableFooterView.hidden = YES;
        }
        else if (_curPage < totalPageNum ) {
            self.expertsList.bIsThereMoreData = YES;
        }
        else
        {
            self.expertsList.bIsThereMoreData = NO;
        }
        
        UIButton* btn2 = (UIButton*)[self.view viewWithTag:11];        
        if ( btn2.selected)
        {
            self.expertsList.sourceData = _groupedExpertsArray;
            
            if (page == 1)
            {
                [self reloadTableData:YES];
            }
            else
            {
                [self reloadTableData:NO];
            }
        }
    }
    else
    {
        [[LKLoadingCenter defaultCenter] disposeLoadingView];        
    }
    
    
    //3. up data footer
    if (_bGroupedExpertDataReady) {
        [self.expertsList dataLoadingFinish];
    }
//    NetWorked = YES;
    
}
-(void)ExpertGroupObjectsFailed:(NSNotification*)notify
{
//    NetWorked = YES;
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
    [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"没有找到指定分类的专家！" time:2.0 ignoreAddition:NO parentView:self.view];
}


#pragma mark - Button Click Action

- (IBAction)btnCommentExpertsClicked:(id)sender {
    UIButton* btn = (UIButton*)sender;
    if (btn.selected) {
        return;
    }
    
    
    btn.selected  = YES;
    UIButton* btn2 = (UIButton*)[self.view viewWithTag:11];
    btn2.selected  = NO;
    
    //[self showTableViewFooter:YES];
    [self showGroupedExpertsCategories:NO];
    self.expertsList.sourceData = _recommendExpertsArray;
    
    if (!_bRecommenExpertDataReady) {
        [self reloadTableViewDataSource:YES];
    }
    else
        [self reloadTableData:YES]; //YES --- SCROLL TO TOP
}

- (IBAction)btnExpertsGroupClicked:(id)sender {
    UIButton* btn = (UIButton*)sender;
    if (btn.selected) {
        return;
    }
    
    
    btn.selected  = YES;
    UIButton* btn1 = (UIButton*)[self.view viewWithTag:10];
    btn1.selected = NO;
   
    //[self showTableViewFooter:YES];
    //show expertGroup Category
    [self showGroupedExpertsCategories:YES];
    self.expertsList.sourceData = _groupedExpertsArray;
    
    if (!_bGroupedExpertDataReady) {
        [self reloadTableViewDataSource:YES];
    }
    else
        [self reloadTableData:NO]; //YES --- SCROLL TO TOP
}


#pragma mark -
#pragma mark TableViewEvent_Delegate
-(void)pullDownToRefresh:(UITableView*) tableView
{
    
}

-(void)pullUpToLoadMoreData:(UITableView*) tableView
{
    UIButton* btn1 = (UIButton*)[self.view viewWithTag:10];
    UIButton* btn2 = (UIButton*)[self.view viewWithTag:11];
    if (btn1.selected) {
        [[MessageManager getInstance] startGetActiveExpertMsgWithSender:self args:nil page:self.curPage + 1];
    }
    else if(btn2.selected)
    {
        [[MessageManager getInstance] startGetExpertbyGroupWithSender:self args:self.categoryID page:self.curPage +  1];
    }

}

@end

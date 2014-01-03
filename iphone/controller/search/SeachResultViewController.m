//
//  SeachResultViewController.m
//  babyfaq
//
//  Created by PRO on 13-5-27.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "SeachResultViewController.h"
#import "DataCenter.h"
#import "DataModel.h"
#import "QuestionAnswerCell.h"
#import "MessageManager.h"
#import "defines.h"
#import "CommentViewController.h"
#import "LKTipCenter.h"
#import "PostInteractionDataViewController.h"
#import "LKLoadingCenter.h"
#import "OfflineQAsTableView.h"
#import "DataBaseSaver.h"
#import "NSData+base64.h"
#import "PersonCenterViewController.h"

typedef enum
{
    SearchNotificationT = 1,
    SearchFaildedNotificationT,
    AddFavoriteNotificationT,
    AddFavoriteFaildedNotificationT
}SearchResultNotification;

#define offlineDataPageCount            20


@interface SeachResultViewController ()

@end

@implementation SeachResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _nothingFind.hidden = YES;
        self.searchArgs = [[DataCenter getInstance]     searchArgs];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL  isOnLine = [self updataUI4LineStatues];
    if (isOnLine)
    {
        [self initNotification];
        //[self initNavgationBar];
        [self initSubViews];
        //    [self showTableViewFooter:NO];
        [self reloadTableViewDataSource: YES];
    }
}

- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:self.title];
}

- (void)leftBtnClick:(UIButton *)button
{
    if (_searchType == RelativeQA &&
         ![self.navigationController.viewControllers[0] isKindOfClass:[PersonCenterViewController class]] ) {
        
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else
    {
        [super leftBtnClick:nil];
    }
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
    _offlineView.backgroundColor = [UIColor redColor];
    [imgView release];
    
    UILabel* tips = [[UILabel alloc] initWithFrame:CGRectZero];
    tips.backgroundColor = [UIColor clearColor];
    [tips setTextColor:[UIColor colorWithRed:97.0/255.0 green:172.0/255.0 blue:182.0/255.0 alpha:1.0]];
    tips.tag = 2014;
    [tips setText:@"离线状态,下面是本地知识库搜索结果!"];
    [_offlineView addSubview:tips];
    [tips release];
    
    //2.offline tableview
    OfflineQAsTableView* dbDataView = [[OfflineQAsTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    dbDataView.eventDelegate   = self;
    dbDataView.tag = 2015;
    
    _curPageOfOfflineData = 1;
    NSArray* offlineDatas = [[DataBaseSaver getInstance] getOfflineDataFromDBByKeyword:_keyWords andPangeIndex:_curPageOfOfflineData andPageCount:offlineDataPageCount];
    
    if (offlineDatas.count > 0) {
        _noneImg.hidden = YES;
        dbDataView.sourceData = offlineDatas;
    }
    else
    {
       // _noneImg.hidden = NO;
    }
    
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
    int yPos = 60;//self.view.frame.size.height not include statusbar height
    int iHeight = self.view.frame.size.height-appNavigationBarHeight-20-appSearchBarHeight;
    _offlineView.frame = CGRectMake(0, yPos, self.view.frame.size.width, iHeight);
    
    UIImageView* bkImag = (UIImageView*)[_offlineView viewWithTag:2013];
    bkImag.frame = CGRectMake(0, 0, _offlineView.frame.size.width, _offlineView.frame.size.height);
    
    UILabel* tips = (UILabel*)[_offlineView viewWithTag:2014];
    tips.frame = CGRectMake(20, 0, DeviceScreenWidth, 20);
    
    //table
    yPos = 30;
    OfflineQAsTableView* tableView = (OfflineQAsTableView*)[_offlineView viewWithTag:2015];
    tableView.frame = CGRectMake(0, yPos, _offlineView.frame.size.width, _offlineView.frame.size.height-yPos+4);  //+4 for hidden "jiazaigenduo"  tips, should hidden not here
    
    //table footer
    if (tableView.sourceData.count < offlineDataPageCount) {
        tableView.bIsThereMoreData = NO;
        [self showTableViewFooter:NO];
    }
    else
    {
        tableView.bIsThereMoreData = YES;
        [self showTableViewFooter:YES];
        [tableView dataLoadingFinish];
    }
}

- (void) showTableViewFooter : (BOOL)bshow
{
    if (_offlineView.hidden)
    {
        if (bshow) {
            self.searchResultTable.tableFooterView = self.footerViewButton;
        }
        else
            self.searchResultTable.tableFooterView = nil;
    }
    else
    {
        OfflineQAsTableView* tableView = (OfflineQAsTableView*)[_offlineView viewWithTag:2015];
        if (bshow) {
            tableView.tableFooterView = self.footerViewButton;
        }
        else
            tableView.tableFooterView = nil;
    }

}

- (void)dealloc {
    [_searchResultTable release];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:SearchNotification object:nil];
    [nc removeObserver:self name:SearchFaildedNotification object:nil];
    [nc removeObserver:self name:AddFavoriteNotification object:nil];
    [nc removeObserver:self name:AddFavoriteFaildedNotification object:nil];
    self.cateid = nil;
    [_offlineView release], _offlineView = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [self setSearchResultTable:nil];
    [super viewDidUnload];
}

- (void)initSubViews
{
    int yPos = 0;
    _searchBar.hidden = YES;
    
    //fen lei(jieduan), my question  show search bar
    if ( (_searchType == SearchbyGroup || _searchType == QuizeList) && _keyWords == nil )
    { 
        _searchBar.hidden = NO;
        yPos = 20+appSearchBarHeight;
    }
    
    CGRect frame = CGRectMake(0, yPos, DeviceScreenWidth, DeviceScreenHeight-StatusBarHeight-appNavigationBarHeight-yPos);
    self.searchResultTable = [[QandATableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [self.view addSubview:_searchResultTable];
    _searchResultTable.eventDelegate = self;
    
    //search bar
    _searchBar.target = self;
    _searchBar.searchAction = @selector(searchQAsByKeywords);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) searchQAsByKeywords
{
    //问答搜索
    SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
    resultVC.title = [NSString stringWithFormat:@"问答搜索:%@", _searchBar.keywordText.text];
    resultVC.keyWords =  _searchBar.keywordText.text;
    resultVC.searchType = _searchType;
    resultVC.cateid = _cateid;
    [self.navigationController pushViewController:resultVC animated:YES];
    [resultVC release];    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource:(BOOL)needDown
{
    if(!needDown)
    {
        BOOL needRefresh = [self checkRefreshByDate:nil];//self.expertID
        if (needRefresh)
        {
            needDown = YES;
        }
    }
    if (needDown)
    {
        NSString* cateid = nil;
        
        switch (_searchType)
        {
            case SearchbyGroup://分类搜索
            {
                BabyWriteActionLog(@"search by class");
                cateid = [_cateid stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSMutableDictionary* args = [NSMutableDictionary dictionaryWithCapacity:2];
                if ([cateid length] > 0)
                {
                    [args setValue:cateid forKey:@"cate_id"];
                    
                    NSString* keywords = [_keyWords stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([keywords length] > 0) {
                        [args setValue:[keywords rawUrlEncodeByEncoding:NSUTF8StringEncoding] forKey:@"keyword"];
                    }
                }

                [[MessageManager getInstance]   startSearchCateIdWithSender:self args:args page:1];
            }
                break;
                
            case SearchbyWords://关键字搜索（homepage, searchpage, searchresultpage, 搜索专家接口？)
            {
                BabyWriteActionLog(@"search by keywords");
                [[MessageManager getInstance]   startSearchbyWordWithSender:self args:_keyWords page:1];
                
                //send to server search word
                [[MessageManager getInstance]   sendSearchword2ServerWithSender:self args:_keyWords];
            }
                break;
            case ExpertAllAns://专家所有问答  uid
            {
                BabyWriteActionLog(@"all quize");
                cateid = [_cateid stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSMutableDictionary* paramDic = [NSMutableDictionary dictionaryWithCapacity:2];

                if ([cateid length] > 0)
                {
                    [paramDic setValue:cateid forKey:EXPERT_UID];
                    
                    NSString* keywords = [_keyWords stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([keywords length] > 0) {
                        [paramDic setValue:[keywords rawUrlEncodeByEncoding:NSUTF8StringEncoding] forKey:@"keyword"];
                    }
                }

                [[MessageManager getInstance]   startGetAllAnswerofExpertWithSender:self param:paramDic page:1];
            }
                break;
            case FavoriteList://我的收藏
                BabyWriteActionLog(@"my favorite");
                [[MessageManager getInstance]   startGetFavoriteListWithSender:self page:1];
                break;
            case QuizeList://我的问题
            {
                BabyWriteActionLog(@"my question");
                
                NSMutableDictionary* args = [NSMutableDictionary dictionaryWithCapacity:2];
                
                NSString* keywords = [_keyWords stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([keywords length] > 0) {
                    [args setValue:[keywords rawUrlEncodeByEncoding:NSUTF8StringEncoding] forKey:@"keyword"];
                }
                
                [[MessageManager getInstance]   startGetMyQuizeListWithSender:self param:args page:1];
            }
                break;
            case RelativeQA://相关问答
            {
                NSMutableDictionary* paramDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [paramDic setValue:_keyWords forKey:@"text"];
                [paramDic setValue:_subjectID forKey:@"sid"];
                [[MessageManager getInstance]   startGetRelativeQAsWithSender:self args:paramDic page:1];
            }
                
                break;
            default:
                break;
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
    [nc addObserver:self
           selector:action
               name:SearchNotification
             object:nil];
    
    [nc addObserver:self
           selector:action
               name:SearchFaildedNotification
             object:nil];
    
    
    
    [nc addObserver:self
           selector:action
               name:AddFavoriteNotification
             object:nil];
    
    [nc addObserver:self
           selector:action
               name:AddFavoriteFaildedNotification
             object:nil];
}

- (void) handleNotification:(NSNotification*)notify
{
    //1. if this notify is about self
    BOOL myNotify = [self isThisNotificationWanted:notify];
    if (!myNotify)
        return;
    
    NSArray* notifyNames = @[SearchNotification, SearchFaildedNotification, AddFavoriteNotification,AddFavoriteFaildedNotification];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:notifyNames.count];
    for (int i=1; i<notifyNames.count+1; ++i) {
        [dic setValue:[NSNumber numberWithInt:i] forKey:notifyNames[i-1]];
    }
    NSString* name = [notify name];
    SearchResultNotification type = [[dic valueForKey:name] intValue];
    
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
        case AddFavoriteNotificationT:
        {
            [self favoriteObjectsAdded:notify];
        }
            break;
        case AddFavoriteFaildedNotificationT:
        {
            [self favoriteObjectsFailed:notify];
        }
            break;
        default:
            break;
    }
}

-(void)favoriteObjectsAdded:(NSNotification*)notify
{
    self.searchResultTable.hidden = NO;
    [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"收藏成功!" time:2.0 ignoreAddition:NO parentView:self.view];
}
-(void)favoriteObjectsFailed:(NSNotification*)notify
{
//    [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"收藏失败!" time:2.0 ignoreAddition:NO parentView:self.containView];
}

-(void)SearchObjectsAdded:(NSNotification*)notify
{
    //1.save data
    CommentDataList* dataList = [[DataCenter getInstance] searchDateList];
    [dataList reloadShowedDataWithIDList:@[@"search"] ];
    
    _searchResultCount = [dataList contentsCountWithIDList:@[@"search"] ];
    
    if (_searchResultArray == nil) {
        _searchResultArray = [[NSMutableArray alloc] initWithCapacity:_searchResultCount];
    }
    if (_searchResultArray.count > 0) {
        [_searchResultArray removeAllObjects];
    }
    
    DataModel* oneQuize = nil;
    if (_searchResultCount > 0) {
        _noneImg.hidden = YES;
    }
    else
    {
        _noneImg.hidden = NO;
        _nothingFind.hidden =YES;
    }
    for (int i=0; i<_searchResultCount; ++i) {
        oneQuize = [dataList oneObjectWithIndex:i IDList:@[@"search"] ];
        if (oneQuize)
        {
            [_searchResultArray addObject:oneQuize];
        }
    }
    
    self.searchResultTable.sourceData = _searchResultArray;

    //2. update ui
    NSDictionary* userInfo = [notify userInfo];
    
    int page = [[userInfo objectForKey:@"page"] intValue];
//    int countNumber = [[userInfo objectForKey:@"count"] intValue];
    int totalPageNum = [[userInfo objectForKey:@"totalPage"]intValue];
    
    if ([CommentDataList checkNumberArrayEqualWithFirstArray:self.searchArgs secondArray:self.searchArgs])
    {
        self.curPage = page;
        _nothingFind.hidden = YES;
        self.searchResultTable.tableFooterView.hidden = NO;
        
        if (totalPageNum <= 1) {
            [self showTableViewFooter:NO];
//            self.searchResultTable.tableFooterView.hidden = YES;
        }
        else if (_curPage < totalPageNum ) {
            [self showTableViewFooter:YES];
            self.searchResultTable.bIsThereMoreData = YES;
        }
        else
        {
            [self showTableViewFooter:YES];
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
        _nothingFind.hidden = NO;
    }
    
    //3.update tableview footer
    [self.searchResultTable dataLoadingFinish];
    
}
-(void)SearchObjectsFailed:(NSNotification*)notify
{
    _nothingFind.hidden = YES;
    _noneImg.hidden = NO;
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
}

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
    
}

-(void)pullUpToLoadMoreData:(UITableView*) tableView
{
    NSString* cateid = nil;
    if (_offlineView.hidden) {
        switch (_searchType)
        {
            case SearchbyGroup://分类搜索
            {
                cateid = [_cateid stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSMutableDictionary* args = [NSMutableDictionary dictionaryWithCapacity:2];
                
                if ([cateid length] > 0)
                {
                    [args setValue:cateid forKey:@"cate_id"];
                    
                    NSString* keywords = [_keyWords stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([keywords length] > 0) {
                        [args setValue:[keywords rawUrlEncodeByEncoding:NSUTF8StringEncoding] forKey:@"keyword"];
                    }
                }
                
                [[MessageManager getInstance]   startSearchCateIdWithSender:self args:args page:self.curPage+1];
            }
                break;
                
            case SearchbyWords://关键字搜索（homepage, searchpage, searchresultpage, 搜索专家接口？）
                [[MessageManager getInstance]   startSearchbyWordWithSender:self args:_keyWords page:self.curPage + 1];
                break;
            case ExpertAllAns://专家所有问答  uid
            {
                cateid = [_cateid stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSMutableDictionary* paramDic = [NSMutableDictionary dictionaryWithCapacity:2];
                
                if ([cateid length] > 0)
                {
                    [paramDic setValue:cateid forKey:EXPERT_UID];
                    
                    NSString* keywords = [_keyWords stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([keywords length] > 0) {
                        [paramDic setValue:[keywords rawUrlEncodeByEncoding:NSUTF8StringEncoding] forKey:@"keyword"];
                    }
                }
                
                [[MessageManager getInstance]   startGetAllAnswerofExpertWithSender:self param:paramDic page:self.curPage + 1];
            }
                break;
            case FavoriteList://我的收藏
                [[MessageManager getInstance]   startGetFavoriteListWithSender:self page:self.curPage + 1];
                break;
            case QuizeList://我的问题
            {
                NSMutableDictionary* args = [NSMutableDictionary dictionaryWithCapacity:2];
                
                NSString* keywords = [_keyWords stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([keywords length] > 0) {
                    [args setValue:[keywords rawUrlEncodeByEncoding:NSUTF8StringEncoding] forKey:@"keyword"];
                }
                
                [[MessageManager getInstance]   startGetMyQuizeListWithSender:self param:args page:self.curPage + 1];
            }
                break;
            default:
                break;
        }
    }
    else //offline mode
    {
        int pageCount = 20;
        OfflineQAsTableView* tableView = (OfflineQAsTableView*)[_offlineView viewWithTag:2015];
        
        NSArray* offlineDatas = [[DataBaseSaver getInstance] getOfflineDataFromDBByKeyword:_keyWords andPangeIndex:_curPageOfOfflineData++ andPageCount:pageCount];
        
        if (offlineDatas.count > 0) {
           // _nothingFind.hidden = YES;
            _noneImg.hidden = YES;
            NSMutableArray* oldData = [NSMutableArray arrayWithArray:tableView.sourceData];
            [oldData addObjectsFromArray:offlineDatas];
            
            tableView.sourceData = oldData;
            [tableView reloadData];
            
            [tableView dataLoadingFinish];
            
            
            if (offlineDatas.count < pageCount) {
                [self showTableViewFooter:NO];
                tableView.bIsThereMoreData = NO;
            }
            else
            {
                [self showTableViewFooter:YES];
                tableView.bIsThereMoreData = YES;
            }
        }
        else
        {
           // _nothingFind.hidden = NO;
            _noneImg.hidden = NO;
            [self showTableViewFooter:NO];
            tableView.bIsThereMoreData = NO;
        }
    }
}
@end

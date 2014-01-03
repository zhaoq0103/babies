//
//  ExpertSearchViewController.m
//  babyfaq
//
//  Created by YANGJINGXI on 13-7-17.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "ExpertSearchViewController.h"
#import "defines.h"
#import "LKLoadingCenter.h"
#import "LKTipCenter.h"
#import "MessageManager.h"
#import "DataCenter.h"
@implementation ExpertSearchViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.idList = [[DataCenter getInstance] searchExpertArray];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    BOOL  isOnLine = [self updataUI4LineStatues];
    if (isOnLine)
    {
        _searchBar.hidden = YES;
        [self initSubViews];
        [self updataUI4LineStatues];
        [self initNavigationTitleItem];
        [self initNotification];
        //[self initUI];
        [self reloadTableViewDataSource: YES];
    }
}

- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"搜索专家"];
}

- (void)initSubViews
{
    self.expertsList = [[ExpertsTableView alloc] initWithFrame:CGRectMake(0,0, DeviceScreenWidth, DeviceScreenHeight-StatusBarHeight - appNavigationBarHeight) style:UITableViewStylePlain];
    _expertsList.eventDelegate = self;
    [self.view addSubview:_expertsList];
}

-(void)initNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(SearchExpertObjectsAdded:)
               name:SearchWordsNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(SearchExpertObjectsFailed:)
               name:SearchWordsFaildedNotification
             object:nil];
}

/////////////////////////////
////////////////////////////
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
//刷新
//-(BOOL)checkRefreshByDate:(NSArray*)IDArray
//{
//    return YES;
//    
//    BOOL rtval = NO;
//    CommentDataList* dataList = [[DataCenter getInstance] expertbyGroupList];
//    NSDate* oldDate = [dataList dateInfoWithIDList:IDArray];
//    if (oldDate)
//    {
//        NSTimeInterval length = [oldDate timeIntervalSinceDate:[NSDate date]];
//        length = abs(length);
//        if (length > HttpRequstRefreshTime)
//        {
//            rtval = YES;
//        }
//    }
//    else
//        rtval = YES;
//    
//    return rtval;
//}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource:(BOOL)needDown
{
    BOOL doneLoading = NO;
//    if(!needDown)
//    {
//        BOOL needRefresh = [self checkRefreshByDate:self.categoryID];
//        if (needRefresh)
//        {
//            needDown = YES;
//        }
//        
//        doneLoading = YES;
//    }
    
    if (needDown)
    {
        [[LKLoadingCenter defaultCenter] postLoadingWithTitle:nil message:@"载入中..." ignoreTouch:NO];
        
        
         
                [[MessageManager getInstance] startSearchWordsWithSender:self args:_keyWords page:1];
            
        

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
    
    [self.expertsList reloadData];
    
    if(scrollTop) //滚动到最上面
    {
        [self.expertsList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}

#pragma mark - InitNotification and the Action
-(void)SearchExpertObjectsAdded:(NSNotification*)notify
{
//    NSDictionary* userInfo = [notify userInfo];        
//    int page = [[userInfo objectForKey:@"page"] intValue];
//    int countNumber = [[userInfo objectForKey:@"count"] intValue];
//    int totalPageNum = [[userInfo objectForKey:@"totalPage"]intValue];
    CommentDataList* dataList = [[DataCenter getInstance] EsearchDateList];
    [dataList reloadShowedDataWithIDList:@[@"searchexpert"]];
    
    searchExpertsCount = [dataList contentsCountWithIDList:@[@"searchexpert"]];
    
    if (searchExpertArray == nil) {
        searchExpertArray = [[NSMutableArray alloc] initWithCapacity:searchExpertsCount];
    }
    if (searchExpertArray.count > 0) {
        [searchExpertArray removeAllObjects];
    }
    
    DataModel* oneExpert = nil;
    for (int i=0; i<searchExpertsCount; ++i) {
        oneExpert = [dataList oneObjectWithIndex:i IDList:@[@"searchexpert"]];
        if (oneExpert)
        {
            [searchExpertArray addObject:oneExpert];
        }
    }

        self.expertsList.sourceData = searchExpertArray;
        [self reloadTableData:YES];
}

-(void)SearchExpertObjectsFailed:(NSNotification*)notify
{
   // [[LKLoadingCenter defaultCenter] disposeLoadingView];
    _noneImg.hidden = NO;
    [self.view bringSubviewToFront:_noneImg];
    
}
#pragma mark -
#pragma mark TableViewEvent_Delegate
-(void)pullDownToRefresh:(UITableView*) tableView
{
    
}

//-(void)pullUpToLoadMoreData:(UITableView*) tableView
//{
//    [[MessageManager getInstance] startSearchWordsWithSender:self args:_keyWords page:self.curPage + 1];
//}


@end

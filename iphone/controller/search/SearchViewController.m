//
//  SearchViewController.m
//  babyfaq
//
//  Created by mayanwei on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "SearchViewController.h"
#import "SeachResultViewController.h"
#import "DataModel.h"
#import "MyTool.h"
#import "defines.h"
#import "DataCenter.h"
#import "MessageManager.h"
#import "NSData+base64.h"

#import "WindowsManager.h"
#import "MWTabBarController.h"
#import "Reachability.h"
#import "OfflineQAsTableView.h"
#import "DataBaseSaver.h"

#define jieduanBtn_BKColor              @"#A0CDD6"
#define seperateBtn_BKColor             @"#FF919A"

#define jieduanBtn_width                192/2
#define jieduanBtn_height               88/2

#define hotwordsBtn_width               192/2
#define hotwordsBtn_height1              60/2
#define hotwordsBtn_height2              90/2
#define hotwordsBtn_height3              120/2

#define Border_width_height             20/2
#define Seperate_width_height           12/2
#define Seperate_btn_yPos               218

#define jieduanFont                     [UIFont systemFontOfSize:15.0]
#define hotwordsFont                    [UIFont systemFontOfSize:14.0]
#define hotFont                         [UIFont boldSystemFontOfSize:17.0]

#define jieduanButtonBaseTag            100
#define hotwordsButtonBaseTag           200

//    int yPosOgrinal = StatusBarHeight + appNavigationBarHeight + appSearchBarHeight  + 2*Border_width_height;

//#define ColorFromString(string) [MyTool hexStringToColor: string alpha :1.0f];
typedef enum
{
    SearchArrayNotificationT = 1,
    SearchArrayFaildedNotificationT,
    SearchHotwordsNotificationT,
    SearchHotwordsFaildedNotificationT
}SearchViewNotification;
@interface SearchViewController ()

@end

@implementation SearchViewController

#pragma mark - Life Circle
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
        _searchBar.hidden = NO;
        _bJieDuanDataReady = NO;
        _bHotwordDataReady = NO;
        [self initNotification];
        [self initViews];
        [self initData];
        [self initNavigationTitleItem];
    }
    
    //refresh data
    if (_uiInited == YES) {
        if ( !_bJieDuanDataReady || !_bJieDuanDataReady) {
            [self reloadTableViewDataSource:YES];
        }
    }
    
    // refresh finish
    _uiInited = YES;
}


- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"搜索"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_jieduanSearchList release], _jieduanSearchList = nil;
    [_hotwordsSearchList release], _hotwordsSearchList = nil;
    [super dealloc];
}

- (void) initViews
{
    UIColor* bkColor = [MyTool colorWithHexString:seperateBtn_BKColor];
    UIButton* button = [MyTool createButton:@"热点" font:hotFont color:[UIColor colorWithRed:254.0/255.0 green:248.0/255.0 blue:225.0/255.0 alpha:1.0] width:55 height:27 left:Border_width_height top: Seperate_btn_yPos];
    button.backgroundColor = bkColor;
    [self.view addSubview:button];
    _hotwordsSearchList.frame = CGRectMake(10, 256, 300, DeviceScreenHeight-369);
    
    //search bar
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

- (void) initData
{
    [self reloadTableViewDataSource:YES];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource:(BOOL)needDown
{
    if (needDown)
    {
        if (!_bJieDuanDataReady) {
            [[MessageManager getInstance] startGetSearchGroupWithSender:self];
        }
        
        if (!_bHotwordDataReady) {
            [[MessageManager getInstance] startGetHotwordsWithSender:self];
        }
    }
    else
    {
        // latest data
    }
}

#pragma mark - InitNotification and the Action

-(void)initNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    SEL action = @selector(handleNotification:);
    //jie duan
    [nc addObserver:self
           selector:action
               name:SearchArrayNotification
             object:nil];
    
    [nc addObserver:self
           selector:action
               name:SearchArrayFaildedNotification
             object:nil];
    
    //hot words
    [nc addObserver:self
           selector:action
               name:SearchHotwordsNotification
             object:nil];
    
    [nc addObserver:self
           selector:action
               name:SearchHotwordsFaildedNotification
             object:nil];
}

- (void) handleNotification:(NSNotification*)notify
{
    //1. if this notify is about self
    BOOL myNotify = [self isThisNotificationWanted:notify];
    if (!myNotify)
        return;
    
    NSArray* notifyNames = @[SearchArrayNotification, SearchArrayFaildedNotification, SearchHotwordsNotification,SearchHotwordsFaildedNotification];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:notifyNames.count];
    for (int i=1; i<notifyNames.count+1; ++i) {
        [dic setValue:[NSNumber numberWithInt:i] forKey:notifyNames[i-1]];
    }
    NSString* name = [notify name];
    SearchViewNotification type = [[dic valueForKey:name] intValue];
    
    switch (type) {
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
        case SearchHotwordsNotificationT:
        {
            [self SearchHotwordsAdded:notify];
        }
            break;
        case SearchHotwordsFaildedNotificationT:
        {
            [self SearchHotwordsFailed:notify];
        }
            break;
        default:
            break;
    }
}


-(void)SearchArrayObjectsAdded:(NSNotification*)notify
{
    NSArray* args = [[DataCenter getInstance]   searchgroupID];
    CommentDataList* dataList = [[DataCenter getInstance] searchgroupList];
    [dataList reloadShowedDataWithIDList:args];
    int count = [dataList contentsCountWithIDList:args];
    
    if (count > 0) {
        if (_jieduanData == nil) {
            _jieduanData = [[NSMutableDictionary alloc] initWithCapacity:9];
        }
        if (_jieduanData.count > 0) {
            [_jieduanData removeAllObjects];
        }
        
        for (int i = 0; i< count ; i++)
        {
            DataModel* groupObj = [dataList oneObjectWithIndex:i IDList:args];
            [_jieduanData  addEntriesFromDictionary:[groupObj dataDict]];
        }
        _bJieDuanDataReady = YES;
        [self setJieDuanData];
    }
}

-(void)SearchArrayObjectsFailed:(NSNotification*)notify
{
    //    [[LKLoadingCenter defaultCenter] disposeLoadingView];
}

-(void)SearchHotwordsAdded:(NSNotification*)notify
{
    NSArray* args = [[DataCenter getInstance]   hotwordsGroupID];
    CommentDataList* dataList = [[DataCenter getInstance] searchgroupList];
    [dataList reloadShowedDataWithIDList:args];
    int count = [dataList contentsCountWithIDList:args];
    
    if (count > 0) {
        if (_hotwordsSearchTimes == nil) {
            _hotwordsSearchTimes = [[NSMutableArray alloc] initWithCapacity:count];
        }
        if (_hotwordsValues == nil) {
            _hotwordsValues  = [[NSMutableArray alloc] initWithCapacity:count];
        }
        if ([self.hotwordsValues count] > 0)
        {
            [self.hotwordsValues removeAllObjects];
        }
        if ([self.hotwordsSearchTimes count] > 0)
        {
            [self.hotwordsSearchTimes removeAllObjects];
        }
        
        for (int i = 0; i< count ; i++)
        {
            DataModel* groupObj = [dataList oneObjectWithIndex:i IDList:args];
            NSDictionary* groupDict = [groupObj dataDict];
            
            NSString* hotword = [groupDict valueForKey:@"keyword"];
            NSString* searchTimes = [groupDict valueForKey:@"search_count"];
                        
            [self.hotwordsValues addObject:hotword];
            [self.hotwordsSearchTimes   addObject:searchTimes];
        }
        
        _bHotwordDataReady = YES;
        [self setHotWordsData];
    }
}

-(void)SearchHotwordsFailed:(NSNotification*)notify
{
    //    [[LKLoadingCenter defaultCenter] disposeLoadingView];
}

- (void) setJieDuanData
{
    UIColor* bkColor = [MyTool colorWithHexString:jieduanBtn_BKColor];
    int yPos = 0;
    int xPos = 0;
    
    NSArray* keys = [[_jieduanData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (int i = 0; i<keys.count; ++i) {
        NSString* key = [keys objectAtIndex:i];
        NSString* title = [_jieduanData valueForKey:key];
        
        NSCharacterSet* nameSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
        NSRange range = [title rangeOfCharacterFromSet:nameSet];
        NSString* left;
        NSString* right;
        UIButton* button;
        if (range.location != NSNotFound) {
            NSRange need;
            need.location = 0;
            need.length = range.location - 1;
            left = [title substringWithRange:need];
            
            need.location = range.location - 1;
            need.length = title.length - range.location + 1;
            right = [title substringWithRange:need];
            
//            title = [left stringByAppendingFormat:@"\n%@", right];
            
            button = [MyTool createButton:nil font:jieduanFont color:[UIColor whiteColor] width:jieduanBtn_width height:jieduanBtn_height left:xPos top:yPos];
            button.backgroundColor = bkColor;
            [button setBackgroundImage:[UIImage imageNamed:@"btn_qustion.png"] forState:UIControlStateNormal];
            button.tag = [(NSString*)key intValue];
            [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, jieduanBtn_width, jieduanBtn_height/2) ];
            [leftLabel setText:left];
            leftLabel.textColor = [UIColor whiteColor];
            leftLabel.backgroundColor = [UIColor clearColor];
            leftLabel.textAlignment = UITextAlignmentCenter;
            leftLabel.font = [UIFont systemFontOfSize:15.0];
            UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, jieduanBtn_height/2, jieduanBtn_width, jieduanBtn_height/2)];
            [rightLabel setText:right];
            rightLabel.textColor = [UIColor whiteColor];
            rightLabel.backgroundColor = [UIColor clearColor];
            rightLabel.textAlignment = UITextAlignmentCenter;
            rightLabel.font = [UIFont systemFontOfSize:15.0];
            
            [button addSubview:leftLabel];
            [button addSubview:rightLabel];
            
            [leftLabel release];
            [rightLabel release];
        }
        else
        {
            button = [MyTool createButton:title font:jieduanFont color:[UIColor whiteColor] width:jieduanBtn_width height:jieduanBtn_height left:xPos top:yPos];
            button.backgroundColor = bkColor;
            [button setBackgroundImage:[UIImage imageNamed:@"btn_qustion.png"] forState:UIControlStateNormal];
            button.tag = [(NSString*)key intValue];
            [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
        }

        //button.showsTouchWhenHighlighted = YES;

        xPos += (Seperate_width_height + jieduanBtn_width);
        if ((i + 1) % 3 == 0) {
            yPos += (Seperate_width_height + jieduanBtn_height);
            xPos = 0;
        }
        
        [_jieduanSearchList addSubview:button];

    }
}


- (void) setHotWordsData
{
//#warning test
//    if (1) {
//        [_hotwordsValues removeAllObjects];
//        [_hotwordsSearchTimes removeAllObjects];
//        
//        _hotwordsValues = [NSMutableArray arrayWithArray:@[@"我",@"爱",@"北",@"京",@"天",@"安",@"门",@"上",@"太",@"阳",@"升",@"！"]];
//        _hotwordsSearchTimes = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"3",@"2",@"1",@"1",@"2",@"3",@"4",@"5",@"6"]];
//    }
    
    
    UIColor* bkColor = [MyTool colorWithHexString:jieduanBtn_BKColor];
    int colum1yPos = 0;
    int colum2yPos = 0;
    int colum3yPos = 0;
    int xPos = 0;
    
    int randowHeight1 = hotwordsBtn_height2;
    int randowHeight2 = hotwordsBtn_height3;
    int randowHeight3 = hotwordsBtn_height1;
    int columFlag = 0;
    UIButton* button = nil;
    for (int i=0; i<_hotwordsSearchTimes.count; ++i) {
        NSString* tempWord = _hotwordsValues[i];
        NSString* word = [tempWord rawUrlDecode];
        NSString* times = _hotwordsSearchTimes[i];
        NSString* timesWithAdd = [NSString stringWithFormat:@"%d +", [times intValue]];
        
        //NSString* title = [NSString stringWithFormat:@"%@\n%d + ", [word rawUrlDecode], [times intValue]];
        
//        if ([title isEqualToString:@"%E6%9C%BA"]) { //urlencode 2 times
//            NSLog(@"WHY");
//        }
        UILabel *upLabel = [[UILabel alloc] init];
        [upLabel setText:word];
        upLabel.textColor = [UIColor whiteColor];
        upLabel.backgroundColor = [UIColor clearColor];
        upLabel.textAlignment = UITextAlignmentCenter;
        upLabel.font = [UIFont systemFontOfSize:15.0];
        UILabel *downLabel = [[UILabel alloc] init];
        [downLabel setText:timesWithAdd];
        downLabel.textColor = [UIColor whiteColor];
        downLabel.backgroundColor = [UIColor clearColor];
        downLabel.textAlignment = UITextAlignmentCenter;
        downLabel.font = [UIFont systemFontOfSize:15.0];
        
        if ( columFlag == 0)
        {
            button = [MyTool createButton:nil font:hotwordsFont color:[UIColor whiteColor] width:jieduanBtn_width height:randowHeight1 left:xPos top:colum1yPos];
            colum1yPos += (randowHeight1 + Seperate_width_height);
            
        
            if (randowHeight1 == hotwordsBtn_height2)
            {
                randowHeight1 = hotwordsBtn_height1;
                upLabel.frame = CGRectMake(0, 3, jieduanBtn_width, hotwordsBtn_height2/2-3);
                downLabel.frame =  CGRectMake(0, hotwordsBtn_height2/2, jieduanBtn_width, hotwordsBtn_height2/2-2);
            }
            else if(randowHeight1 == hotwordsBtn_height1)
            {
                randowHeight1 = hotwordsBtn_height3;
                upLabel.frame = CGRectMake(0, 0, jieduanBtn_width, hotwordsBtn_height1/2);
                downLabel.frame =  CGRectMake(0, hotwordsBtn_height1/2, jieduanBtn_width, hotwordsBtn_height1/2);
            }
            else if(randowHeight1 == hotwordsBtn_height3)
            {
                randowHeight1 = hotwordsBtn_height2;
                upLabel.frame = CGRectMake(0, 10, jieduanBtn_width, hotwordsBtn_height3/2-10);
                downLabel.frame =  CGRectMake(0, hotwordsBtn_height3/2, jieduanBtn_width, hotwordsBtn_height3/2-10);
            }

        }
        else if( columFlag == 1)
        {
            button = [MyTool createButton:nil font:hotwordsFont color:[UIColor whiteColor] width:jieduanBtn_width height:randowHeight2 left:xPos top:colum2yPos];
            colum2yPos += (randowHeight2 + Seperate_width_height);
            upLabel.frame = CGRectMake(0, 0, jieduanBtn_width, randowHeight2/2);
            downLabel.frame = CGRectMake(0, randowHeight2/2, jieduanBtn_width, randowHeight2/2);
            if (randowHeight2 == hotwordsBtn_height2)
            {
                randowHeight2 = hotwordsBtn_height3;
                upLabel.frame = CGRectMake(0, 3, jieduanBtn_width, hotwordsBtn_height2/2-3);
                downLabel.frame =  CGRectMake(0, hotwordsBtn_height2/2, jieduanBtn_width, hotwordsBtn_height2/2-2);
            }
            else if(randowHeight2 == hotwordsBtn_height1)
            {
                randowHeight2 = hotwordsBtn_height2;
                upLabel.frame = CGRectMake(0, 0, jieduanBtn_width, hotwordsBtn_height1/2);
                downLabel.frame =  CGRectMake(0, hotwordsBtn_height1/2, jieduanBtn_width, hotwordsBtn_height1/2);
            }
            else if(randowHeight2 == hotwordsBtn_height3)
            {
                randowHeight2 = hotwordsBtn_height1;
                upLabel.frame = CGRectMake(0, 10, jieduanBtn_width, hotwordsBtn_height3/2-10);
                downLabel.frame =  CGRectMake(0, hotwordsBtn_height3/2, jieduanBtn_width, hotwordsBtn_height3/2-10);
            }
        }
        else
        {
            button = [MyTool createButton:nil font:hotwordsFont color:[UIColor whiteColor] width:jieduanBtn_width height:randowHeight3 left:xPos top:colum3yPos];
            colum3yPos += (randowHeight3 + Seperate_width_height);
            upLabel.frame = CGRectMake(0, 0, jieduanBtn_width, randowHeight3/2);
            downLabel.frame =  CGRectMake(0, randowHeight3/2, jieduanBtn_width, randowHeight3/2);
            
            if (randowHeight3 == hotwordsBtn_height2)
            {
                randowHeight3 = hotwordsBtn_height3;
                upLabel.frame = CGRectMake(0, 3, jieduanBtn_width, hotwordsBtn_height2/2-3);
                downLabel.frame =  CGRectMake(0, hotwordsBtn_height2/2, jieduanBtn_width, hotwordsBtn_height2/2-2);
            }
            else if(randowHeight3 == hotwordsBtn_height1)
            {
                randowHeight3 = hotwordsBtn_height2;
                upLabel.frame = CGRectMake(0, 0, jieduanBtn_width, hotwordsBtn_height1/2);
                downLabel.frame =  CGRectMake(0, hotwordsBtn_height1/2, jieduanBtn_width, hotwordsBtn_height1/2);
            }
            else if(randowHeight3 == hotwordsBtn_height3)
            {
                randowHeight3 = hotwordsBtn_height1;
                upLabel.frame = CGRectMake(0, 10, jieduanBtn_width, hotwordsBtn_height3/2-10);
                downLabel.frame =  CGRectMake(0, hotwordsBtn_height3/2, jieduanBtn_width, hotwordsBtn_height3/2-10);
            }
        }
        
        xPos += (Seperate_width_height + jieduanBtn_width);
        
        columFlag++;
        if (columFlag % 3 == 0) {
            columFlag = 0;
            xPos = 0;
        }
        
        button.backgroundColor = bkColor;
        [button setBackgroundImage:[UIImage imageNamed:@"btn_qustion.png"] forState:UIControlStateNormal];
        //button.showsTouchWhenHighlighted = YES;
        button.tag = hotwordsButtonBaseTag + i;
        [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:upLabel];
        [button addSubview:downLabel];
        [upLabel release];
        [downLabel release];
        
        [_hotwordsSearchList addSubview:button];
    }
    
    int height = colum1yPos > colum2yPos ? (colum1yPos > colum3yPos ? colum1yPos : colum3yPos) : (colum2yPos > colum3yPos ? colum2yPos : colum3yPos);
    [_hotwordsSearchList setContentSize:CGSizeMake(DeviceScreenWidth-2*Border_width_height, height)];
}

#pragma mark - Custom Navigation Bar

//over load for hide navigation btn
- (void) initNavgationBar
{
}

#pragma mark - Search Bar Action
//over load
- (void)goSearch
{
    //result
    
    //show
    SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
    resultVC.title = @"问答搜索";
    resultVC.keyWords = _searchBar.keywordText.text;
    resultVC.searchType = SearchbyWords;  //default keywords search
    [self.navigationController pushViewController:resultVC animated:YES];
    [resultVC release];
}

#pragma mark -----Click BTN Action
- (void)btnClicked:(id)sender {

    UIButton* btn = (UIButton*)sender;
    
    int tagIndex = btn.tag;
    SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
    
    if (tagIndex >= hotwordsButtonBaseTag)
    { //hot word
//        NSString *title = btn.titleLabel.text;
//        NSCharacterSet* nameSet = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
//        NSRange range = [title rangeOfCharacterFromSet:nameSet];
//        NSString* keywords;
//        if (range.location != NSNotFound) {
//            NSRange need;
//            need.location = 0;
//            need.length = range.location;
//            keywords = [title substringWithRange:need];
//        }
//        
        NSString* tempword = _hotwordsValues[btn.tag - hotwordsButtonBaseTag];
        NSString* keywords = [tempword rawUrlDecode];
        resultVC.title = keywords;
        resultVC.keyWords = keywords;
        resultVC.searchType = SearchbyWords;
    }
    else //jieduan
    {
        NSString* cateID = [NSString stringWithFormat:@"%d", tagIndex];
        NSString* text = [_jieduanData valueForKey:cateID];
        resultVC.title = text;
//        resultVC.keyWords = text;
        resultVC.cateid = cateID;
        resultVC.searchType = SearchbyGroup;
    }
    
    [self.navigationController pushViewController:resultVC animated:YES];
    [resultVC release];
}


#pragma mark - Offline Data
- (void)initOfflineView
{
    [self initNavigationTitleItem];
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
    int yPos = 64;//self.view.frame.size.height not include statusbar height  self.view.frame.size.height  460
    int iHeight = DeviceScreenHeight-appNavigationBarHeight-20-appSearchBarHeight-appTabBarHeight-StatusBarHeight;
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

#pragma mark - TableViewEvent_Delegate, for get more offline data in DB
-(void)pullUpToLoadMoreData:(UITableView*) tableView
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
@end

//
//  ExpertDetailsViewController.m
//  babyfaq
//
//  Created by PRO on 13-6-9.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "ExpertDetailsViewController.h"
#import "LKLoadingCenter.h"
#import "defines.h"
#import "DataCenter.h"
#import "MessageManager.h"
#import "QandATableView.h"
#import "LoginViewController.h"
#import "PostInteractionDataViewController.h"
#import "ExpertPageUtils.h"
#import "SeachResultViewController.h"

typedef enum{
    SearchNotificationT = 1,
    SearchFaildedNotificationT,
    ExpertDetailsInfoNotificationT,
    ExpertDetailsInfoFaildedNotificationT,
} ExpertDetailsPageNotifyType;

@interface ExpertDetailsViewController ()
-(void)initUI;
-(void)initNotification;
-(void)reloadDataSource:(BOOL)needDown;
-(void)loadViewData:(NSInteger)index;
@end

@implementation ExpertDetailsViewController
@synthesize photoImageView, onlineTime, workField, expertPosition, askExpert, expertIntro, allAskAnswer, seperateImageView, introTextView, introImageVIew;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _bQADataReady = NO;
        
        self.view.backgroundColor = [UIColor greenColor];
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
        _searchBar.hidden = NO;
        
        [self initNotification];
        [self initSubViews];
        [self showTableViewFooter:YES];
        
        //default show allAnswers
        _searchResultTable.hidden = NO;
        introTextView.hidden = YES;
        
        expertIntro.selected = NO;
        allAskAnswer.selected = YES;
    }
}

- (void) setExpertUID:(NSInteger)expertUID
{
    _expertUID = expertUID;
    
    //from cell headImage click action
    NSNumber* idParam = [NSNumber numberWithInteger:_expertUID];
    [[MessageManager getInstance] startGetExpertInfoWithSender:self args:@[idParam]];
}

- (void) showTableViewFooter : (BOOL)bshow
{
    self.searchResultTable.tableFooterView = self.footerViewButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setExpertModel:(DataModel *)expertModel
{
    
    if (_expertModel) {
        [_expertModel release];
    }
    _expertModel = [expertModel retain];
    
    NSString* hospital = [_expertModel valueForKey:EXPERT_HOSPITAL];
    if (hospital) {
        expertPosition.text = hospital;
    }    
   // [expertPosition sizeToFit];
    
    NSString* fieldStr = [_expertModel valueForKey:EXPERT_POSITION];
    if (fieldStr) {
        workField.text = fieldStr;
    }
    //[workField sizeToFit];
    
    NSString* timeStr = [_expertModel valueForKey:EXPERT_WEEKDAY];
    if (timeStr) {
        onlineTime.text = timeStr;
    }
    //[onlineTime sizeToFit];
    
    
    NSString* introStr = [_expertModel valueForKey:EXPERT_INTRO];
    NSString* introFomateStr = nil;
    if (introStr) {
        introFomateStr = [NSString stringWithFormat:@"　　%@", introStr];
    }
    if (introFomateStr) {
         introTextView.text = introFomateStr;
    }
    introTextView.editable = NO;
    
    NSString* avatarimgUrl = [_expertModel valueForKey:EXPERT_PROFILEIMG];
    NSURL* url = [NSURL URLWithString:avatarimgUrl];
    [photoImageView setImageWithURL:url];
    photoImageView.layer.masksToBounds= YES;
    photoImageView.layer.cornerRadius  = 6.0;
    
    
    NSString* Disable = [_expertModel valueForKey:EXPERT_DISABLE];
    if( [Disable isEqualToString:@"1"] )
    {
        self.askExpert.hidden = YES;
    }
    
    
    [self initNavigationTitleItem];
    if ( !_bQADataReady) {
        [self reloadTableViewDataSource: YES];
    }
}
- (void)dealloc
{
    [photoImageView release];
    [onlineTime release];
    [workField release];
    [expertPosition release];
    [askExpert release];
    [expertIntro release];
    [allAskAnswer release];
    [seperateImageView release];
    [introTextView release];
    [introImageVIew release];
    [_expertModel release];
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}
-(void)viewWillAppear:(BOOL)animated
{   
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
}

- (void)initNavigationTitleItem
{
    NSString* title = [_expertModel valueForKey:EXPERT_NAME];
//    if (title) {
//        self.title = title;
//    }
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    if (title) {
        [label setText:title];
    }
    
}

#pragma mark - Init Notification and It's Action
-(void)initNotification
{
    //all QA
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
    
    //expert Info, same as recommend expert
    [nc addObserver:self
           selector:action
               name:ExpertDetailsInfoNotification
             object:nil];
    
    [nc addObserver:self
           selector:action
               name:ExpertDetailsInfoFaildedNotification
             object:nil];
}

- (void) handleNotification:(NSNotification*)notify
{
    //1. if this notify is about self
    BOOL myNotify = [self isThisNotificationWanted:notify];
    if (!myNotify)
        return;
    
    NSArray* notifyNames = @[SearchNotification, SearchFaildedNotification, ExpertDetailsInfoNotification,ExpertDetailsInfoFaildedNotification];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:notifyNames.count];
    for (int i=1; i<notifyNames.count+1; ++i) {
        [dic setValue:[NSNumber numberWithInt:i] forKey:notifyNames[i-1]];
    }
    NSString* name = [notify name];
    ExpertDetailsPageNotifyType type = [[dic valueForKey:name] intValue];
    
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
        case ExpertDetailsInfoNotificationT:
        {
            [self ExpertDetailMsgGot:notify];
        }
            break;
        case ExpertDetailsInfoFaildedNotificationT:
        {
            [self ExpertDetailMsgGotFailed:notify];
        }
            break;
        default:
            break;
    }
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
        [[LKLoadingCenter defaultCenter] disposeLoadingView];
    }
    else
    {
        [[LKLoadingCenter defaultCenter] disposeLoadingView];
        // _nothingFind.hidden = NO;
    }
    
    //3. set a data get flag
    _bQADataReady = YES;
    //3. up data footer
    if (_bQADataReady) {
        [self.searchResultTable dataLoadingFinish];
    }
}
-(void)SearchObjectsFailed:(NSNotification*)notify
{
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
}

-(void)ExpertDetailMsgGot:(NSNotification*)notify
{
    //handle data
    CommentDataList* dataList = [[DataCenter getInstance] infoList];
    NSNumber* idParam = [NSNumber numberWithInteger:_expertUID];
    [dataList reloadShowedDataWithIDList:@[idParam]];
    DataModel* oneExpert = [dataList oneObjectWithIndex:0 IDList:@[idParam]];
    
    self.expertModel = oneExpert;
}

-(void)ExpertDetailMsgGotFailed:(NSNotification*)notify
{
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
}

#pragma mark - Button Click Action

- (void) backBtnClick : (UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)askExpertButtonClicked:(id)sender;
{
    //
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (!Logined)
    {
        LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginView animated:NO];
        [loginView release];
    }
    else
    {
        //1.upload log
        BabyWriteActionLog(@"QuizeAdd");
        
        //2.show
        NSString* expertnameStr = [_expertModel valueForKey:EXPERT_NAME];
        NSString* expertuid = [_expertModel valueForKey:EXPERT_UID];
        NSString* preInfo = [ExpertPageUtils getStringForAskingPreInfo];
        if ([preInfo isEqualToString:@"提问："]) {
            preInfo = [NSString stringWithFormat:@"提问：准备怀孕"];
        }
        NSString* content = [NSString stringWithFormat:@"向 @%@ %@ ", expertnameStr, preInfo];
        
        PostInteractionDataViewController* QuizeView = [[PostInteractionDataViewController alloc]initWithNibName:@"PostInteractionDataViewController" bundle:nil];
        QuizeView.contentType = QuizeViewType_QuizeAdd;
        QuizeView.contentStr = content;
        QuizeView.expertID = expertuid;
        QuizeView.subjectID = [_expertModel valueForKey:@"subject_id"];
        
        [self.navigationController pushViewController:QuizeView animated:NO];
        [QuizeView release];
    }
}

-(IBAction)expertInfoButtonClicked:(id)sender
{
    if (expertIntro.selected) {
        return;
    }
    
    expertIntro.selected = YES;
    allAskAnswer.selected  = NO;
    
    introTextView.hidden = NO;
    _searchResultTable.hidden  = YES;
}

-(IBAction)allAskAnswerButtonClicked:(id)sender
{
    if (allAskAnswer.selected) {
        return;
    }
    
    expertIntro.selected = NO;
    allAskAnswer.selected  = YES;
    
    introTextView.hidden = YES;
    _searchResultTable.hidden  = NO;

    if ( !_bQADataReady) {
        [self reloadTableViewDataSource: YES];
    }
}

- (void)initSubViews
{
    _searchBar.hidden =  NO;
    int yPos = 190;
    self.searchResultTable = [[QandATableView alloc] initWithFrame:CGRectMake(0, yPos, DeviceScreenWidth, DeviceScreenHeight-yPos-appNavigationBarHeight-StatusBarHeight) style:UITableViewStylePlain];
    [self.view addSubview:_searchResultTable];
    _searchResultTable.eventDelegate = self;
    
    //search bar
    _searchBar.target = self;
    _searchBar.searchAction = @selector(searchQAsByKeywords);
}

-(void) searchQAsByKeywords
{
    //问答搜索
    SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
//    resultVC.title = @"问答搜索";
    resultVC.title = _searchBar.keywordText.text;
    resultVC.keyWords =  _searchBar.keywordText.text;
    resultVC.cateid = [_expertModel valueForKey:EXPERT_UID];
    resultVC.searchType = ExpertAllAns;
    [self.navigationController pushViewController:resultVC animated:YES];
    [resultVC release];
}


- (void)reloadTableViewDataSource:(BOOL)needDown
{    
    [[LKLoadingCenter defaultCenter] postLoadingWithTitle:nil message:@"载入中..." ignoreTouch:NO];

    NSMutableDictionary* paramDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [paramDic setValue:[_expertModel valueForKey:EXPERT_UID] forKey:EXPERT_UID];
    
    [[MessageManager getInstance]   startGetAllAnswerofExpertWithSender:self param:paramDic page:1];
}



//list
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
    NSMutableDictionary* paramDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [paramDic setValue:[_expertModel valueForKey:EXPERT_UID] forKey:EXPERT_UID];
    
    [[MessageManager getInstance]   startGetAllAnswerofExpertWithSender:self param:paramDic page:self.curPage + 1];
}

@end

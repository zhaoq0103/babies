//
//  CommentViewController.m
//  babyfaq
//
//  Created by PRO on 13-5-29.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "CommentViewController.h"
#import "PostInteractionDataViewController.h"
#import "defines.h"
#import "DataCenter.h"
#import "LKLoadingCenter.h"
#import "MessageManager.h"

#define countPerPage 20

@interface CommentViewController ()

@end

@implementation CommentViewController



#pragma mark - 
#pragma mark Life Cycle 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selectedID = [[NSArray alloc] initWithObjects:@"weibocommentlist", nil];
    }
    return self;
}

- (void)dealloc
{
    [_selectedID release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL  isOnLine = [self updataUI4LineStatues];
    if (isOnLine)
    {
        self.title = @"评论";
        [self initNotify];
        [self initData];
        [self initCommentTableView];
        [self showTableViewFooter:YES];
    }
}

- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"评论"];
    
}

- (void)initNavigationRightItem
{
    UIButton *spaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    spaceBtn.frame = CGRectMake(0, 13, 2, 2);
    UIBarButtonItem* leftItem = [[[UIBarButtonItem alloc] initWithCustomView:spaceBtn] autorelease];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 20, 20);
    
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"btn_list_comment"] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    NSArray* items = @[leftItem, rightBarButtonItem];
    

    float osVer = [[UIDevice currentDevice].systemVersion floatValue];
    if (osVer >= 5.0) {
        self.navigationItem.rightBarButtonItems = items;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    
    MW_RELEASE(rightBarButtonItem);

}

- (void) showTableViewFooter : (BOOL)bshow
{
    self.commentTableView.tableFooterView = self.footerViewButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    [[LKLoadingCenter defaultCenter] postLoadingWithTitle:nil message:@"载入中..." ignoreTouch:NO];
    _curPage = 1;
    [[MessageManager getInstance] startCommentListV2WeiboWithSender:self ID:_weiboStrID  count:countPerPage page:1 max_id:nil args:_selectedID];
}

- (void)initCommentTableView
{
    _searchBar.hidden =  YES;
    int yPos = 0; //search bar height
    self.commentTableView = [[CommentTableView alloc] initWithFrame:CGRectMake(0, yPos, DeviceScreenWidth, DeviceScreenHeight-StatusBarHeight-appNavigationBarHeight-yPos) style:UITableViewStylePlain];
    [self.view addSubview:_commentTableView];
    _commentTableView.eventDelegate = self;
}

#pragma mark - InitNotification and the Action 

-(void)initNotify
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(CommentContentAdded:)
               name:NavObjectsAddedNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(CommentContentFailed:)
               name:NavObjectsFailedNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(refresh:)
               name:CommentSuccessNotification
             object:nil];
}

-(void)refresh:(NSNotification*)notify
{
    [self reloadTableViewDataSource:NO];
}

-(void)CommentContentAdded:(NSNotification*)notify
{
    //1.save data
    CommentDataList* commentContentList = [[DataCenter getInstance] commentList];
    [commentContentList reloadShowedDataWithIDList:_selectedID];
    _commentDataCount = [commentContentList contentsCountWithIDList:_selectedID];
    
    if (_commentDataArray == nil) {
        _commentDataArray = [[NSMutableArray alloc] initWithCapacity:_commentDataCount];
    }
    if (_commentDataArray.count > 0) {
        [_commentDataArray removeAllObjects];
    }
    
    DataModel* oneQuize = nil;
    for (int i=0; i<_commentDataCount; ++i) {
        oneQuize = [commentContentList oneObjectWithIndex:i IDList:_selectedID];
        if (oneQuize)
        {
            [_commentDataArray addObject:oneQuize];
        }
        
        if (i == _commentDataCount-1) {
            [_commentID release];
            _commentID = [[oneQuize valueForKey:@"mid"] copy];
        }
    }
    
    self.commentTableView.sourceData = _commentDataArray;
    
    //2. updata ui
    NSNumber* object = [notify object];
    if ([object isKindOfClass:[NSNumber class]] && [object intValue] == (int)self )
    {
        NSDictionary* userInfo = [notify userInfo];
        NSArray* indexArray = [userInfo objectForKey:@"args"];
        NSArray* objectArray = [userInfo objectForKey:@"array"];
        NSNumber* page = [userInfo objectForKey:@"page"];
        
        if ([CommentDataList checkNumberArrayEqualWithFirstArray:indexArray secondArray:_selectedID]) {
            _curPage = [page intValue];
             self.commentTableView.tableFooterView.hidden = NO;
            
            if ([objectArray count]>0)
            {
                if ([objectArray count] < countPerPage && _curPage == 1)
                {
                    self.commentTableView.tableFooterView.hidden = YES;
                }
                else if([objectArray count] < countPerPage)
                {
                    self.commentTableView.bIsThereMoreData = NO;
                }
                else
                {
                    self.commentTableView.bIsThereMoreData = YES;
                }
                _emptyImg.hidden = YES;
                _noneImg.hidden = YES;
            }
            else
            {
                self.commentTableView.tableFooterView.hidden = YES;
                //
                _emptyImg.hidden = NO;
                _noneImg.hidden = NO;
            }
            
            [self reloadData];
        }
    }
    
    //3.
    [self.commentTableView dataLoadingFinish];
}

-(void)CommentContentFailed:(NSNotification*)notify
{
    [self reloadData];
}

-(void)reloadData
{
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
    [self.commentTableView reloadData];
}


#pragma mark - Navigation Bar RightButton Clicked
//over load for comment 
- (void)rightBtnClick:(UIButton *)button
{
    PostInteractionDataViewController* comment  = [[PostInteractionDataViewController alloc] initWithNibName:@"PostInteractionDataViewController" bundle:nil];
    
    comment.contentType = QuizeViewType_Comment;
    comment.expertID = _weiboStrID;
    [self.navigationController pushViewController:comment animated:YES];
    [comment release];
}

#pragma mark - TableViewEvent_Delegate
-(void)pullDownToRefresh:(UITableView*) tableView
{
    [self reloadTableViewDataSource:NO];
}
-(void)pullUpToLoadMoreData:(UITableView*) tableView
{
        [[MessageManager getInstance] startCommentListV2WeiboWithSender:self ID:_weiboStrID  count:countPerPage page:self.curPage+1 max_id:_commentID args:_selectedID];
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
        [[LKLoadingCenter defaultCenter] postLoadingWithTitle:nil message:@"载入中..." ignoreTouch:NO];
        
        //comment
            [[MessageManager getInstance] startCommentListV2WeiboWithSender:self ID:_weiboStrID  count:countPerPage page:1 max_id:nil args:_selectedID];
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

@end

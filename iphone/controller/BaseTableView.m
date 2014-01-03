//
//  BaseTableView.m
//  babyfaq
//
//  Created by PRO on 13-6-9.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "BaseTableView.h"
#import "defines.h"

@implementation BaseTableView

#pragma mark -
#pragma mark Life Circle
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        [self initViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initViews];
}

- (void) dealloc
{
    [_refreshHeaderView release], _refreshHeaderView = nil;
    [super dealloc];
}

- (void)initViews
{
    //1.refresh tableview
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSelectionStyleNone;
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.bounds.size.height, self.frame.size.width, self.bounds.size.height)];
    _refreshHeaderView.delegate = self;

    
    [_refreshHeaderView refreshLastUpdatedDate];
    self.bNeedRefresh = YES;
}

- (void)setBNeedRefresh:(BOOL)bNeedRefresh
{
    if (bNeedRefresh) {
        [self addSubview:_refreshHeaderView];
    }
    else
    {
        if ([_refreshHeaderView superview]) {
            [_refreshHeaderView removeFromSuperview];
        }
    }
}

- (void) dataLoading
{
    UIButton* moreData  = (UIButton*)[self.tableFooterView viewWithTag:2013];
    [moreData setTitle:@"正在加载数据...." forState:UIControlStateNormal];
    
    UIActivityIndicatorView* waitingView = (UIActivityIndicatorView*)[moreData  viewWithTag:201307];
    waitingView.hidden = NO;
    [waitingView startAnimating];
    
    moreData.enabled = NO;
}

- (void) dataLoadingFinish
{
    UIButton* moreData  = (UIButton*)[self.tableFooterView viewWithTag:2013];
    if (_bIsThereMoreData) {
        [moreData setTitle:@"上拉加载更多..." forState:UIControlStateNormal];
        moreData.enabled = YES;
    }
    else
    {
        [moreData setTitle:@"已经加载所有数据!" forState:UIControlStateNormal];
        moreData.enabled = NO;
    }
    
    
    UIActivityIndicatorView* waitingView = (UIActivityIndicatorView*)[moreData  viewWithTag:201307];
    waitingView.hidden = YES;
    [waitingView stopAnimating];
    
}

- (void)getMoreData : (UIButton* ) sender
{
    [self dataLoading];
    
    if ([self.eventDelegate respondsToSelector:@selector(pullUpToLoadMoreData:)]) {
        [_eventDelegate pullUpToLoadMoreData:self];
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging];
    //上拉加载更多
    float a = scrollView.contentOffset.y;
    float b = scrollView.frame.size.height;
    float c = scrollView.contentSize.height;
    if (self.tableFooterView && _bIsThereMoreData &&  (a + b  > c + 20) ) {
        [self getMoreData:nil];
    }
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    
    //refresh test demo
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
    //下拉刷新
	if ([self.eventDelegate respondsToSelector:@selector(pullDownToRefresh:)]) {
        [_eventDelegate pullDownToRefresh:self];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
#pragma mark  1.tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self cellForRowAtIndexPath:indexPath];
    if ([self.eventDelegate respondsToSelector:@selector(tableView:didSelectCell:)]) {
        [_eventDelegate tableView:tableView didSelectCell:cell];
    }
}

#pragma mark 2.tableview data source delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.sourceData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    static NSString *userIdentifier = @"UITableViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:userIdentifier];
    if (cell==nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
    }
    return  cell;
}


@end

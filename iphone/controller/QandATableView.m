//
//  QandATableView.m
//  babyfaq
//
//  Created by PRO on 13-6-19.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "QandATableView.h"
#import "MessageManager.h"
#import "CommentDataList.h"
#import "DataModel.h"
#import "DataCenter.h"
#import "QuestionAnswerCell.h"
#import "CommentViewController.h"
#import "PostInteractionDataViewController.h"
#import "LoginViewController.h"
#import "ExpertDetailsViewController.h"
#import "HomeViewController.h"
#import "defines.h"
#import "LKTipCenter.h"
#import "SeachResultViewController.h"

@implementation QandATableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
        _Args = [[[DataCenter getInstance] searchArgs] retain];
        
        self.dataSource = self;
        self.delegate = self;
        [self initNotification];
    }
    return self;
}

- (void) dealloc
{
    [_Args release], _Args = nil;
    [super dealloc];
}

#pragma mark -  Data Source and TableView Delegate
#pragma mark  1.tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fHeight = 0.0;
    
    DataModel* oneQuize = self.sourceData[indexPath.row];
    fHeight = [QuestionAnswerCell CellHeight:oneQuize];
    
    return fHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.homepage
    [self hideHomePageFastMenu];
    //2.My Qeustion, just to Relative QAs
    UIResponder* responder = [self nextResponder];
    while (responder) {
        if ( [responder isKindOfClass:[UIViewController class]] ) {
            break;
        }
        
        responder = [responder nextResponder];
    }
    
    //专家登录
    if (self.tag == 2013) {
        BOOL Logined = [[MessageManager getInstance] hasLogined];
        if (!Logined) {
            return;
        }
        QuestionAnswerCell* cell = (QuestionAnswerCell*)[tableView cellForRowAtIndexPath:indexPath];
        PostInteractionDataViewController* post = [[PostInteractionDataViewController alloc]initWithNibName:@"PostInteractionDataViewController" bundle:nil];
        post.dataModel = [cell cellData];
        post.contentType = QuizeViewType_Reply;
        
        RootViewController* host = (RootViewController*)responder;
        [host.navigationController pushViewController:post animated:YES];
        [post release];
    }
    
    //相关问答
    if ( [responder isKindOfClass:[SeachResultViewController class]] ) {
        
        SeachResultViewController* host = (SeachResultViewController*)responder;
        if (host.searchType == QuizeList) {
            //1. get data
            QuestionAnswerCell* cell = (QuestionAnswerCell*)[tableView cellForRowAtIndexPath:indexPath];
            if (cell.cellData.newsType == DataModelType_Single) {//只有问题， 没有回复
                NSDictionary* dict = [cell.cellData dataDict];
                NSNumber* talkType = [dict valueForKey:@"talk_type"];
                if ([talkType intValue] == 0) { // 0 : wen 1 : da 2 : ziping
                    NSString* subjectID = [dict valueForKey:@"subject_id"];
                    //2.show
                    SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
                    resultVC.title = @"相关问答";
                    resultVC.subjectID = subjectID;
                    resultVC.searchType = RelativeQA;
                    resultVC.keyWords = cell.weiboContent.text;
                    
                    [host.navigationController pushViewController:resultVC animated:YES];
                    [resultVC release];
                }
                
            }
            
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideHomePageFastMenu];
}

- (void)hideHomePageFastMenu
{
    UIResponder* responder = [self nextResponder];
    while (responder) {
        if ( [responder isKindOfClass:[UIViewController class]] ) {
            break;
        }
        
        responder = [responder nextResponder];
    }
    
    if ( [responder isKindOfClass:[HomeViewController class]] )
    {
        [((HomeViewController*)responder) hideFastMenu];
    }
}


#pragma mark  2.tableview data source delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowNum = indexPath.row;
    
    static NSString *userIdentifier = @"QandATableCell";
    QuestionAnswerCell* cell = (QuestionAnswerCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];
    if (cell == nil)
    {
        cell = [[[QuestionAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
    }
    
    cell.cellData = self.sourceData[rowNum];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellRowNum = rowNum;
    
    cell.delegate = self;
    [cell reloadData];
    return  cell;
}


#pragma mark - QuestionAnswerCell_Delegate
-(void)cell:(QuestionAnswerCell*)cell commentClicked:(UIButton*)sender
{
    //专家登陆
    if (self.tag == 2013) {
        return;
    }
    //评论
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (!Logined)
    {
        LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        if ([self.eventDelegate respondsToSelector:@selector(itemInnerCellClickedAction_PushViewController:animate:)]) {
            [self.eventDelegate itemInnerCellClickedAction_PushViewController:loginView animate:YES];
        }
        //[self.navigationController pushViewController:loginView animated:NO];
        [loginView release];
    }
    else
    {
        CommentViewController* CommentView = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
        DataModel* oneQuize = cell.cellData;
        NSString* idstr = [oneQuize valueForKey:WeiboObject_idstr];
        CommentView.weiboStrID = idstr;
        
        //push to viewcontroller
        if ([self.eventDelegate respondsToSelector:@selector(itemInnerCellClickedAction_PushViewController:animate:)]) {
            [self.eventDelegate itemInnerCellClickedAction_PushViewController:CommentView animate:YES];
        }
        [CommentView release];
    }
}
//转发
-(void)cell:(QuestionAnswerCell*)cell repostClicked:(UIButton*)sender
{
    if (self.tag == 2013) {
        return;
    }
    
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (!Logined)
    {
        LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        if ([self.eventDelegate respondsToSelector:@selector(itemInnerCellClickedAction_PushViewController:animate:)]) {
            [self.eventDelegate itemInnerCellClickedAction_PushViewController:loginView animate:YES];
        }
        //[self.navigationController pushViewController:loginView animated:NO];
        [loginView release];
    }
    else
    {
        DataModel* oneQuize = cell.cellData;
        NSDictionary* oneDict = [oneQuize dataDict];
        
        
        NSString* WeiboMid = [oneDict valueForKey:Quize_WeiboMid];
        NSString* mid = WeiboMid;
        
        NSString* ContentStr = [oneDict valueForKey:Quize_Content];
        
        NSDictionary* userDict = [oneDict valueForKey:Quize_User];
        NSString* name = [userDict valueForKey:Quize_User_ScreenName];
        
        
        NSString* repostStr = [NSString stringWithFormat:@"//@%@: %@", name,ContentStr];
        
        PostInteractionDataViewController* QuizeView = [[PostInteractionDataViewController alloc]initWithNibName:@"PostInteractionDataViewController" bundle:nil];
        QuizeView.expertID = mid;
        QuizeView.contentType = QuizeViewType_Weiborepost;
        
        if (cell.cellType == CellAns)
        {
            QuizeView.contentStr = repostStr;
        }
        //push to viewcontroller
        if ([self.eventDelegate respondsToSelector:@selector(itemInnerCellClickedAction_PushViewController:animate:)]) {
            [self.eventDelegate itemInnerCellClickedAction_PushViewController:QuizeView animate:YES];
        }
        
        [QuizeView release];
    }
}

-(void)cell:(QuestionAnswerCell*)cell favoriteClicked:(UIButton*)sender
{
    if (self.tag == 2013) {
        return;
    }
    
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (!Logined)
    {
        LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        if ([self.eventDelegate respondsToSelector:@selector(itemInnerCellClickedAction_PushViewController:animate:)]) {
            [self.eventDelegate itemInnerCellClickedAction_PushViewController:loginView animate:YES];
        }
        [loginView release];
    }
    else
    {
        NSString* mid = [cell.cellData valueForKey:@"mid"];
        [[MessageManager getInstance]   startAddFavoriteWithID:mid];
    }
}

-(void)headImageOfExpertTapedInCell : (QuestionAnswerCell*)cell
{
    UIResponder* responder = [self nextResponder];
    while (responder) {
        if ( [responder isKindOfClass:[UIViewController class]] ) {
            break;
        }
        
        responder = [responder nextResponder];
    }
    
    if ( ![responder isKindOfClass:[ExpertDetailsViewController class]] ) {
        NSDictionary* dict = [cell.cellData dataDict];
        NSDictionary* userDict = [dict valueForKey:Quize_User];
        NSNumber* uid =[userDict objectForKey:@"id"];//EXPERT_UID
        
        if (uid)
        {
            ExpertDetailsViewController* details = [[ExpertDetailsViewController alloc]initWithNibName:@"ExpertDetailsViewController" bundle:nil];
            details.expertUID = [uid  intValue];
            //push to viewcontroller
            if ([self.eventDelegate respondsToSelector:@selector(itemInnerCellClickedAction_PushViewController:animate:)]) {
                [self.eventDelegate itemInnerCellClickedAction_PushViewController:details animate:YES];
            }
            
            [details release];
        }
    }
}
//
-(void)initNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(favoriteObjectsAdded:)
               name:AddFavoriteNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(favoriteObjectsFailed:)
               name:AddFavoriteFaildedNotification
             object:nil];
}

-(void)favoriteObjectsAdded:(NSNotification*)notify
{
    UIResponder* responder = [self nextResponder];
    while (responder) {
        if ( [responder isKindOfClass:[UIViewController class]] ) {
            break;
        }
        
        responder = [responder nextResponder];
    }
    
    if ( ![responder isKindOfClass:[RootViewController class]] )
    {
        RootViewController* viewVC = (RootViewController*)responder;
        [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"收藏成功!" time:2.0 ignoreAddition:NO parentView:viewVC.view];
    }
}
-(void)favoriteObjectsFailed:(NSNotification*)notify
{
    UIResponder* responder = [self nextResponder];
    while (responder) {
        if ( [responder isKindOfClass:[UIViewController class]] ) {
            break;
        }
        
        responder = [responder nextResponder];
    }
    
    if ( ![responder isKindOfClass:[RootViewController class]] )
    {
        RootViewController* viewVC = (RootViewController*)responder;
        [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"已经收藏!" time:2.0 ignoreAddition:NO parentView:viewVC.view];
    }
    
}
@end

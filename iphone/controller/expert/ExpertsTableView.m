//
//  ExpertsTableView.m
//  babyfaq
//
//  Created by PRO on 13-6-19.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "ExpertsTableView.h"
#import "CommentDataList.h"
#import "ExpertInfoCell.h"
#import "MessageManager.h"
#import "PostInteractionDataViewController.h"
#import "ExpertDetailsViewController.h"
#import "ExpertPageUtils.h"
#import "defines.h"
#import "LoginViewController.h"

@implementation ExpertsTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
        self.dataSource = self;
        self.delegate = self;
        self.bNeedRefresh = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UITableViewDataSource,UITableViewDelegate
#pragma mark  1.tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* userIdentifier = @"ExpertInfoCell";
    ExpertInfoCell* rtval = (ExpertInfoCell*)([tableView dequeueReusableCellWithIdentifier:userIdentifier]);
    if (!rtval) {
        rtval = [[[ExpertInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
    }
    
    DataModel* oneExpert = self.sourceData[indexPath.row];
    rtval.expertModel = oneExpert;
    
    CGSize size = [rtval sizeThatFits:CGSizeZero];

    return size.height;
}

#pragma mark 2.tableview data source delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    static NSString *userIdentifier = @"ExpertInfoCell";
    ExpertInfoCell* cell = (ExpertInfoCell*)[tableView dequeueReusableCellWithIdentifier:userIdentifier];

    if (cell == nil)
    {
        cell = [[[ExpertInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userIdentifier] autorelease];
        
    }
    
    cell.expertModel = self.sourceData[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString* avatarimgUrl = [cell.expertModel valueForKey:EXPERT_PROFILEIMG];
    NSURL* url = [NSURL URLWithString:avatarimgUrl];
    [cell.avatarImageView setImageWithURL:url];
    
    cell.avatarImageView.layer.masksToBounds = YES;
    cell.avatarImageView.layer.cornerRadius = 6.0;
        
    cell.delegate = self;
    [cell reloadData];
    return  cell;

    
}

//same as click all_answer button
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExpertInfoCell* cell = (ExpertInfoCell*)[self cellForRowAtIndexPath:indexPath];
    [self showExpertDetailsIntheCell:cell];
    
    [self performSelector:@selector(deselectRowAtIndexPath:animated:) withObject:indexPath afterDelay:0.5];
}

#pragma mark - ExpertInfoCell_Delegate
-(void)cell:(ExpertInfoCell*)cell askQuestionClicked:(UIButton*)sender
{
//    UIButton* askButton = (UIButton*)sender;
//    int index = askButton.tag - AskButtonTagBase;
  
    //1.login
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
    //2. get user info
        DataModel* oneExpert = cell.expertModel;
        NSString* expertnameStr = [oneExpert valueForKey:EXPERT_NAME];
        NSString* expertuid = [oneExpert valueForKey:EXPERT_UID];
        NSString* preInfo = [ExpertPageUtils getStringForAskingPreInfo];
        if ([preInfo isEqualToString:@"提问："]) {
            preInfo = [NSString stringWithFormat:@"提问：准备怀孕"];
        }
        NSString* content = [NSString stringWithFormat:@"向 @%@ %@ ", expertnameStr, preInfo];
        
    //3. upload log
        BabyWriteActionLog(@"QuizeAdd");

        
    //4. show ask question ui
        PostInteractionDataViewController* interactionView = [[PostInteractionDataViewController alloc]initWithNibName:@"PostInteractionDataViewController" bundle:nil];
        interactionView.ContentType = QuizeViewType_QuizeAdd;
        interactionView.ContentStr = content;
        interactionView.expertID = expertuid;
        interactionView.subjectID = [oneExpert valueForKey:@"subject_id"];
        

    //5.push to viewcontroller    
        if ([self.eventDelegate respondsToSelector:@selector(itemInnerCellClickedAction_PushViewController:animate:)]) {
            [self.eventDelegate itemInnerCellClickedAction_PushViewController:interactionView animate:YES];
       }
    
        [interactionView release];
    }
    
}

-(void)cell:(ExpertInfoCell*)cell allQAClicked:(UIButton*)sender
{
    [self showExpertDetailsIntheCell:cell];
}



- (void) showExpertDetailsIntheCell : (ExpertInfoCell*)cell
{
    //1. hide tabbar
    //    BCTabBarController* tabBarController = [(BabyAppDelegate*)[[UIApplication sharedApplication] delegate] tabBarController];
    //    tabBarController.tabBar.hidden = YES;
    
    //    CommentDataList* dataList = [[DataCenter getInstance] expertbyGroupList];
    
    //    NewsObject* oneExpert = [dataList oneObjectWithIndex:index IDList:self.CateID];
    
    //2. show detail
        NSDictionary* dict = [cell.expertModel dataDict];
        NSNumber* uid =[dict objectForKey:EXPERT_UID];
        if (uid)
        {
            ExpertDetailsViewController* details = [[ExpertDetailsViewController alloc]initWithNibName:@"ExpertDetailsViewController" bundle:nil];
            details.expertModel = cell.expertModel;
            //        details.currExpert = [uid intValue];
            //    resultVC.searchType = ExpertAllAns;
            //    resultVC.keyWords = expertuid;
            //    resultVC.title = expertnameStr;
            
                //push to viewcontroller
                if ([self.eventDelegate respondsToSelector:@selector(itemInnerCellClickedAction_PushViewController:animate:)]) {
                    [self.eventDelegate itemInnerCellClickedAction_PushViewController:details animate:YES];
                }
            
            [details release];
        }
}
@end

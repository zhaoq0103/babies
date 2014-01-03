//
//  HeaderFocusView.m
//  babyfaq
//
//  Created by YANGJINGXI on 13-6-13.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "PostInteractionDataViewController.h"
#import "DataCenter.h"
#import "MessageManager.h"
#import "defines.h"
#import "LKTipCenter.h"
#import "SeachResultViewController.h"

#define MaxWeiboContentLength       140

@interface PostInteractionDataViewController ()

@end

@implementation PostInteractionDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        anonymouse = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL  isOnLine = [self updataUI4LineStatues];
    if (isOnLine)
    {
        [self initUI];
        [self initNavigationRightItem];
        [self initNotification];
        [self.content becomeFirstResponder];
    }
}

- (void)dealloc
{
    [_contentStr release];
    [_content release];
    [_expertID release];
    [_checkBoxButton release];
    [_askHeaderView release];
    
    [_contentBK release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:self.title];
}
-(void)initUI
{
    
    int index = _contentType;
    switch (index)
    {
        case QuizeViewType_QuizeAdd:
            self.title = @"提问";
            break;
        case QuizeViewType_Comment:
            self.title = @"评论";
            break;
        case QuizeViewType_Weiborepost:
            self.title = @"转发";
            break;
        case QuizeViewType_WeiboPublish:
            self.title = @"意见反馈";
            break;
        case QuizeViewType_Reply:
        {
            self.title = @"解答问题"; 
        }
            break;
        default:
            break;
    }
    
    //set _content frame
    int height = DeviceScreenHeight - _keyboardHeight - StatusBarHeight - appNavigationBarHeight;
    _askHeaderView.hidden = YES;
    _content.frame = CGRectMake(6, 6, 308, height);//186
    if(_contentType == QuizeViewType_QuizeAdd)
    {
        _askHeaderView.hidden = NO;
        _content.frame = CGRectMake(6, 46, 308, height);//186
    }
    
    
    self.content.text = _contentStr;
    if (_contentStr && index != QuizeViewType_Weiborepost) {
        int length = [_contentStr length];
        self.content.selectedRange = NSMakeRange(length, 0);
    }
    else
    {
       self.content.selectedRange = NSMakeRange(0, 0);
    }
        
    int leftNum = MaxWeiboContentLength - _contentStr.length;
    _remainTextNumLabel.text = [NSString stringWithFormat:@"%d", leftNum];
    self.content.delegate = self;
    
    [self initNavigationTitleItem];
}

- (void) layoutOfflineSubViews
{
    _searchBar.hidden = YES;
    [super layoutOfflineSubViews];
}

- (void)initNavigationLeftItem
{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 13, 57, 28);
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [leftBtn setTitleColor:[UIColor colorWithRed:254.0/255.0 green:248.0/255.0 blue:225.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"btn_confirm_custom.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* leftItem2 = [[[UIBarButtonItem alloc] initWithCustomView:leftBtn] autorelease];

    self.navigationItem.leftBarButtonItem = leftItem2;
    
}

- (void)initNavigationRightItem
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 57, 28);
    [rightBtn setTitle:@"发送" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [rightBtn setTitleColor:[UIColor colorWithRed:254.0/255.0 green:248.0/255.0 blue:225.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"btn_confirm_custom.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(submitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    MW_RELEASE(rightBarButtonItem);
}

#pragma mark - Init Notification and It's Action
-(void)initNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //ask 
    [nc addObserver:self
           selector:@selector(QuizeObjectsAdded:)
               name:QuizeNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(QuizeObjectsFailed:)
               name:QuizeFaildedNotification
             object:nil];
    //comment
    [nc addObserver:self
           selector:@selector(QuizeObjectsAdded:)
               name:NetworkPublishSuccessNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(WeiboObjectsFailed:)
               name:NetworkPublishFaildedNotification
             object:nil];
    //专家回复
    [nc addObserver:self
           selector:@selector(QuizeObjectsAdded:)
               name:ExpertReplySuccessNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(WeiboObjectsFailed:)
               name:ExpertReplyFaildedNotification
             object:nil];
    
    //key board notification
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
}

-(void)QuizeObjectsAdded:(NSNotification*)notify
{
    [[LKTipCenter defaultCenter] postSmallTophalfTipWithMessage:@"提交成功!" time:1.0 ignoreAddition:NO parentView:self.view];
    [self performSelector:@selector(showRelativeQAs) withObject:nil afterDelay:.5];
}

// if ask , just to relative QA
-(void)showRelativeQAs
{
    if (_contentType == QuizeViewType_QuizeAdd) {
        SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
        resultVC.title = @"相关问答";
        resultVC.subjectID = self.subjectID;
        resultVC.searchType = RelativeQA;
        resultVC.keyWords = self.content.text;
        
        [self.navigationController pushViewController:resultVC animated:YES];
        [resultVC release];
    }
    else
    {
         NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:CommentSuccessNotification object:nil];
        [nc postNotificationName:ExpertCommentSuccessNotification object:nil];
        [self.navigationController popViewControllerAnimated:YES];
      
    }
    
}

-(void)QuizeObjectsFailed:(NSNotification*)notify
{
    NSDictionary* userInfo = [notify userInfo];
    NSNumber* stageNumber = [userInfo objectForKey:@"stage"];
    NSNumber* errorCode = [userInfo valueForKey:@"error_code"];
    if (!stageNumber) {
        stageNumber = [notify object];
    }
    if (stageNumber) {
        NSString* tipString = nil;
        if ([stageNumber intValue]==Stage_QuizeAdd || [stageNumber intValue]==Stage_RequestV2_Publish)
        {
            if ((errorCode&&[errorCode intValue]==20019)|| (errorCode&&[errorCode intValue] == 20)) {
                tipString = @"不要贪心哦，相同\n内容的提问发一次\n就够啦。";
            }
            else if(errorCode&&[errorCode intValue]==10016)
            {
                tipString = @"您的账号权限不足!";
            }
            else
            {
                tipString = @"分享到微博失败!";
            }
            
            if (tipString)
            {
                
                [[LKTipCenter defaultCenter] postSmallTophalfTipWithMessage:tipString time:2.0 ignoreAddition:NO parentView:self.view];
                
            }
        }
    }
}
-(void)WeiboObjectsFailed:(NSNotification*)notify
{
    NSDictionary* userInfo = [notify userInfo];
    NSNumber* stageNumber = [userInfo objectForKey:@"stage"];
    if (!stageNumber) {
        stageNumber = [notify object];
    }
    if (stageNumber) {
        NSString* tipString = nil;
        if ([stageNumber intValue]==Stage_RequestV2_RepostWeibo )
        {
            tipString = @"转发微博失败!";
        }
        
        else if ([stageNumber intValue]==Stage_RequestV2_CommentWeibo)
        {
            tipString = @"评论微博失败!";
        }
        else if ([stageNumber intValue]==QuizeViewType_Reply)
        {
            tipString = @"回复失败!";
        }
        if (tipString)
        {
            [[LKTipCenter defaultCenter] postSmallTophalfTipWithMessage:tipString time:2.0 ignoreAddition:NO parentView:self.view];
        }
    }
    
}

- (void) backBtnClick : (UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//提交
- (void) submitBtnClick : (UIButton*)sender
{
    NSString* content = self.content.text;
    content = [content stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([content length] == 0)
    {
        if (_contentType != QuizeViewType_Weiborepost )
        {
            [[LKTipCenter defaultCenter]postSmallCenterTipWithMessage:@"请输入内容" time:2.0 ignoreAddition:NO parentView:self.view ];
            return;
        }
            
    }
    else if ([content length] > 140)
    {
        
            [[LKTipCenter defaultCenter]postSmallCenterTipWithMessage:@"输入字符超出140" time:2.0 ignoreAddition:NO parentView:self.view ];
            return;
        
        
    }
    
    int index = _contentType;
    switch (index)
    {
            //提问
        case QuizeViewType_QuizeAdd:
            BabyWriteActionLog(@"QuizeAdd");
            NSString* anonymouseStr = [NSString stringWithFormat:@"%d", anonymouse];
            [[MessageManager getInstance]startaddQuizeWithSender:self args:content expert:_expertID anonymouse:anonymouseStr];
            break;
           // 评论
        case QuizeViewType_Comment:
            [[MessageManager getInstance]startCommentV2WeiboWithID:_expertID content:content];
            break;
            //转发
        case QuizeViewType_Weiborepost:
            [[MessageManager getInstance]startRepostV2WeiboWithID:_expertID content:content];
            
            break;
           // 反馈
        case QuizeViewType_WeiboPublish:
            content = [_FeedHeadStr stringByAppendingPathComponent:content];
            [[MessageManager getInstance] startPublishV2:content picUrl:nil];
            break;
            //专家回复
        case QuizeViewType_Reply:
        {
            NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:3];
            NSString* sidValue = [_dataModel valueForKey:EXPERT_SUBJECTID];
            NSString* replyidValue = [_dataModel valueForKey:@"wb_id"];
            [params setValue:sidValue forKey:@"sid"];
            [params setValue:replyidValue forKey:@"replyid"];
            [params setValue:content forKey:@"status"];
            [[MessageManager getInstance] startReplyQuestionWithObject:params];
            [params release];
        }
            break;
        default:
            break;
    }
}

#pragma -
#pragma mark -- Navigation RightBar Click Action
//over load for comment
- (void)rightBtnClick:(UIButton *)button
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"submit" message:@"submit success" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(IBAction)checkBoxButtonClicked:(id)sender
{
    if (anonymouse == 0) {
        anonymouse = 1;
        _anonymous_defaultImg.hidden = YES;
        _anonymous_selectImg.hidden = NO;
      //  [_checkBoxButton setBackgroundImage:[UIImage imageNamed:@"checked.jpg"] forState:UIControlStateNormal];
    }
    else if (anonymouse == 1)
    {
        anonymouse = 0;
        _anonymous_defaultImg.hidden = NO;
        _anonymous_selectImg.hidden = YES;

       // [_checkBoxButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
}


#pragma mark - UITextViewDelegate Method, for text lenth and remainTextNum show

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL result = NO;
    
    if (range.location >= MaxWeiboContentLength)
    {
        result = NO;
    }
    else
    {
        result = YES;
    }
    
    return result;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString* nsTextContent = textView.text;
    int  existTextNum = nsTextContent.length;
    int remainTextNum = MaxWeiboContentLength - existTextNum;
    _remainTextNumLabel.text = [NSString  stringWithFormat:@"%d", remainTextNum];
}

#pragma mark - KeyBoard Event
- (void) keyboardWillShow : (NSNotification*)notify
{
    NSDictionary* info = [notify userInfo];
    NSValue* keyboardValue = [info valueForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardHeight = [keyboardValue CGRectValue].size.height;
    
    [self refreshContentFrame];
}


-(void)refreshContentFrame
{
    //set _content frame
    int height = DeviceScreenHeight - _keyboardHeight - StatusBarHeight - appNavigationBarHeight- 10;//10 margin

    _content.frame = CGRectMake(6, 6, 308, height);//186
    
    if(_contentType == QuizeViewType_QuizeAdd)
    {
        _content.frame = CGRectMake(6, 46, 308, height);//186
    }
    _contentBK.frame = CGRectMake(6, 6, 308, height);
    _remainTextNumLabel.frame = CGRectMake(308-40, height-20, 40, 20);
}	
- (void)viewDidUnload {
    [self setContentBK:nil];
    [super viewDidUnload];
}
@end

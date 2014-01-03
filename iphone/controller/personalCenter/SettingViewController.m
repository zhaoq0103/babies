//
//  SettingViewController.m
//  babyfaq
//
//  Created by PRO on 13-5-27.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "SettingViewController.h"
#import "MessageManager.h"
#import "UpdateModule.h"
#import "AboutViewController.h"
#import "PostInteractionDataViewController.h"
#import "DataCenter.h"
#import "LoginViewController.h"

#define     TAG_BTN_UPGRADE 1
#define     TAG_BTN_SUPPORT  2
#define     TAG_BTN_SUGGEST 3
#define     TAG_BTN_ABOUT   4


#define kSinaBabyAppID      536526254
#define UpdateApi           @"http://m.sina.com.cn/js/5/20120514/31.json"

@interface SettingViewController ()

@end

@implementation SettingViewController

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
        
    }
}

- (BOOL) updataUI4LineStatues
{
    [self setIsOffline:NO];
    return YES;
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
    [label setText:@"设置"];
}

- (IBAction)btnClicked : (UIButton*)sender
{
    int iIndex = sender.tag;
    switch (iIndex) {
        case TAG_BTN_UPGRADE:
            NSLog(@"TAG_BTN_UPGRADE");
        {
            UpdateModule* update = [UpdateModule getInstance];
            update.updateDomain = UpdateApi;
            [update startCheckUpdate:YES];
        }
            break;
        case TAG_BTN_SUPPORT:
            NSLog(@"TAG_BTN_SUPPORT");
        {
            // simple rate for this app
            NSString* makeUrl = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", kSinaBabyAppID];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:makeUrl]];
        }
            break;
        case TAG_BTN_SUGGEST:
            NSLog(@"TAG_BTN_SUGGEST");
        {
            BOOL Logined = [[MessageManager getInstance] hasLogined];
            if (!Logined)
            {
                LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
                [self.navigationController pushViewController:loginView animated:NO];
                [loginView release];
            }
            else
            {
                PostInteractionDataViewController* suggest = [[PostInteractionDataViewController alloc] initWithNibName:@"PostInteractionDataViewController" bundle:nil];
                
                NSString* bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                NSString* version = [NSString stringWithFormat:@"%@",bundleVersion];
                
                NSString* content = [NSString stringWithFormat:@"@育儿专家问答 #育儿专家问答意见反馈#，版本：%@ ", version];
                suggest.contentStr = Nil;
                suggest.FeedHeadStr = content;
                suggest.contentType = QuizeViewType_WeiboPublish;
                [self.navigationController pushViewController:suggest animated:YES];
                [suggest release];
            }
        }
            break;
        case TAG_BTN_ABOUT:
            NSLog(@"TAG_BTN_ABOUT");
        {
            AboutViewController* about = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:about animated:YES];
            [about release];
        }
            break;
        default:
            break;
    }
}

- (void) layoutOfflineSubViews
{
    _searchBar.hidden = YES;
    [super layoutOfflineSubViews];
}
@end

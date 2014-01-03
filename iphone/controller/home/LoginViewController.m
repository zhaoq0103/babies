//
//  LoginViewController.m
//  babyfaq
//
//  Created by YANGJINGXI on 13-6-18.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "LoginViewController.h"
#import "MessageManager.h"
#import "defines.h"
#import "LKLoadingCenter.h"
#import "RegValueSaver.h"





@implementation LoginViewController
@synthesize passWordText, LoginaIdText, btnLogin, btnRegister;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       // self.title = @"登陆";
        // Initialization code
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL  isOnLine = [self updataUI4LineStatues];
    if (isOnLine) {
        _touchScrollView.tapDelegate = self;
        LoginaIdText.delegate = self;
        passWordText.delegate = self;
        [self initNotification];
        [LoginaIdText becomeFirstResponder];
        UIScrollView  *view =  (UIScrollView*) [self.view viewWithTag:5];
        view.contentSize = CGSizeMake(DeviceScreenWidth, DeviceScreenHeight + 100);
        
        NSString* everLogginedName = [[RegValueSaver getInstance] getSavedUserName];
        if(everLogginedName != NULL && everLogginedName.length > 0)
        {
            LoginaIdText.text = everLogginedName;
        }
    }
}
- (void)dealloc
{
    [passWordText release];
    [LoginaIdText release];
    [btnLogin release];
    [btnRegister release];
    [_touchScrollView release];
    [super dealloc];
}

- (void)initNavigationTitleItem
{
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"登录"];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)initNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(LoginSuccessed:)
               name:LoginSuccessedNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(LoginFailed:)
               name:LoginFailedNotification
             object:nil];
}

-(void)LoginSuccessed:(NSNotification*)notify
{    
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
    
    [[MessageManager getInstance] startGetSettingInfoWithSender:self];

//    BOOL needShow = [self needShowSetting];
//    if (needShow)
//    {
//        PsettingViewController* PsettingView = [[PsettingViewController alloc]initWithNibName:@"PsettingViewController" bundle:nil];
//        [self.navigationController pushViewController:PsettingView animated:NO];
//        PsettingView.FromMain = YES;
//        [PsettingView release];
//        [[RegValueSaver getInstance] saveSystemInfoValue:[NSNumber numberWithInt:YES] forKey:NeedShowSetKey encryptString:NO];
//    }
//    else
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
}
-(void)LoginFailed:(NSNotification*)notify
{
    [[LKLoadingCenter defaultCenter] disposeLoadingView];
    
    NSNumber* stageNumber = [notify object];
    NSDictionary* userInfo = [notify userInfo];
    NSNumber* errorCode = [userInfo valueForKey:@"error_code"];
    if ([stageNumber intValue]==Stage_RealLoginV2)
    {
        NSString* tips = @"用户名或密码不正确";
        if ([errorCode intValue]!=21325)
        {
            tips = @"网络状况异常,请检查网络后重试!";
        }
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示"
                                                      message:tips
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


- (IBAction)btnLoginClicked:(id)sender;
{
    NSString* userName = [LoginaIdText.text lowercaseString];
    NSString* passWord = passWordText.text;
    if (userName && ![userName isEqualToString:@""] && passWord && ![passWord isEqualToString:@""]) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:userName forKey:Key_Login_Username];
        [dict setObject:passWord forKey:Key_Login_Password];
        [[MessageManager getInstance] startRealLogin:dict];
        
        [[LKLoadingCenter defaultCenter] postLoadingWithTitle:nil message:@"登录中..." ignoreTouch:YES];
        
    }
}
- (IBAction)btnRegisterClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://weibo.cn/dpool/ttt/h5/reg.php"]];
}

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyBoard];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(_target && _editBeginAction)
    {
        [_target performSelector:_editBeginAction];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(_target && _editEndAction)
    {
        [_target performSelector:_editEndAction];
    }
}


- (void) layoutOfflineSubViews
{
    _searchBar.hidden = YES;
    [super layoutOfflineSubViews];
}
- (void)viewDidUnload {
    [self setTouchScrollView:nil];
    [super viewDidUnload];
}

- (void)hideKeyBoard
{
    [LoginaIdText resignFirstResponder];
    [passWordText resignFirstResponder];
}
#pragma mark - UIScrollViewTapDelegate

//hide key board
-(void) scrollviewTaped
{
    [self hideKeyBoard];
}

@end

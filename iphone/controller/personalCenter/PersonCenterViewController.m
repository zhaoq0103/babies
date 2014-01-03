//
//  PersonCenterViewController.m
//  babyfaq
//
//  Created by yangjx on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "PersonCenterViewController.h"
#import "SettingViewController.h"
#import "MessageManager.h"
#import "LoginViewController.h"
#import "WindowsManager.h"
#import "SeachResultViewController.h"
#import "DataCenter.h"

#import "defines.h"
#import "LKTipCenter.h"
#import "MessageManager.h"
#import "LoginViewController.h"
#import "RegValueSaver.h"
#import "MWTabBarController.h"

typedef enum
{
    SettingNotificationT = 1,
    SettingFaildedNotificationT,
    LoginSuccessedNotificationT,
    SearchNotificationT,
    NewRemendNotificationT,
    NewRemendFaildedNotificationT,
    UserInfoSuccessGetNotificationT
}personcenterNotification;

@interface PersonCenterViewController ()

@end

@implementation PersonCenterViewController
@synthesize btnReadyPregnancy,btnNowPregnancy, btnHadBaby, btnSetting, readyPregnancyView, nowPregnancyView, hadBabyView, btnMyCollection,btnMyAsk, readyPregnancySelectedView, nowPregnancySelectedView, hadBabySelectedView, givebirthDate, pickerView, datePicker, datePickFinished, btnBoy, btnGirl, boySelectedVIew, girlSelectedVIew, nicknameText, ageText;
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
        [self initUserInfo];
        nicknameText.delegate = self;
        //ageText.delegate = self;
        
        UITapGestureRecognizer *collectViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myCollectionClicked:)];
        [btnMyCollection addGestureRecognizer:collectViewGesture];
        [collectViewGesture release];
        
        UITapGestureRecognizer *askViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myAskClicked:)];
        [btnMyAsk addGestureRecognizer:askViewGesture];
        [askViewGesture release];
        
        UITapGestureRecognizer *givebirthDateGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(givebirthDateClicked:)];
        [givebirthDate addGestureRecognizer:givebirthDateGesture];
        [givebirthDateGesture release];
        
        gender = 1;
        dateChoice = 1;
        [self initUI];
        [self initNotification];
        isEdit = NO;
        isWillBirthl = YES;
        _btnPickGiveBirtnDay.enabled = NO;
        [self initPickmin];
        
        
        _uiInited = YES;
    }
}



-(void)layoutOfflineSubViews
{
    _searchBar.hidden = YES;
    [super layoutOfflineSubViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    [btnReadyPregnancy release];
    [btnNowPregnancy release];
    [btnHadBaby release];
    [btnSetting release];
    [readyPregnancyView release];
    [nowPregnancyView release];
    [hadBabyView release];
    [btnMyCollection release];
    [btnMyAsk release];
    [readyPregnancySelectedView release];
    [nowPregnancySelectedView release];
    [hadBabySelectedView release];
    [givebirthDate release];
    [pickerView release];
    [datePicker release];
    [btnBoy release];
    [btnGirl release];
    [boySelectedVIew release];
    [girlSelectedVIew release];
    [nicknameText release];
    [ageText release];
    [_userPhoto release];
    [_userDefaultPhoto release];
    [_myAnsCountLabel release];
    [_favouriteCountLabel release];
    [_giveBirthDaypickerView release];
    [_btnPickGiveBirtnDay release];
    [_giveBirthDaydatePicker release];
    [_stageDownLabel release];
    [_stageUpLabel release];
    [mensDate release];
    [_imgGivebirthSelected release];
    [_imgLastMensSelected release];
    [super dealloc];
}


#pragma - mark Init Navigation Bar and Action
- (void)initNavigationLeftItem
{
    //nothing
}
- (void)initNavigationTitleItem
{
    //self.title = @"个人中心";
    [super initNavigationTitleItem];
    UILabel* label = (UILabel*)[self.navigationItem.titleView viewWithTag:200];
    [label setText:@"个人中心"];
}

- (void)initNavigationRightItem
{
    UIButton *spaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    spaceBtn.frame = CGRectMake(0, 13, 2, 2);
    UIBarButtonItem* leftItem = [[[UIBarButtonItem alloc] initWithCustomView:spaceBtn] autorelease];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 20, 20);
    
    //[rightBtn setTitle:@"设置" forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"btn_setting"] forState:UIControlStateNormal];
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

-(void)initPickmin
{
    //预产期大于当前时间
    NSDate *date = [NSDate date];
    datePicker.minimumDate = date;
    NSDate *maxTime = [NSDate dateWithTimeInterval:280*24*60*60 sinceDate:date];
    datePicker.maximumDate = maxTime;
    //生日小于当前时间
    _giveBirthDaydatePicker.maximumDate  =date;
    
}
-(void) initUserInfo
{
    BOOL hasLogin = [[MessageManager getInstance] hasLogined];
    [self setLoginButtonImage:hasLogin];
}

-(void)initUI
{
    //
    
    //get count
    [[MessageManager getInstance]   startGetFavoriteListWithSender:self page:1];
    [[MessageManager getInstance]   startGetMyQuizeListWithSender:self param:nil page:1];
    NSDictionary* Dict = [[MessageManager getInstance]  readUserSettinginfo];
    //1
    if (!Dict) {
        stage = 1;
        readyPregnancyView.hidden = NO;
        readyPregnancySelectedView.hidden = NO;
        btnReadyPregnancy.selected = YES;
        
        nowPregnancyView.hidden = YES;
        nowPregnancySelectedView.hidden = YES;
        btnNowPregnancy.selected = NO;
        
        hadBabyView.hidden = YES;
        hadBabySelectedView.hidden = YES;
        btnHadBaby.selected = NO;
        
    }
    else
    {
       // btnSetting.titleLabel.text = @"阶段修改";
        [_stageUpLabel setText:@"修改"];
        [_stageDownLabel setText:@"阶段"];
        NSString* genderSex = [Dict objectForKey:@"gender"];
        NSString* mDate = [Dict valueForKey:@"mDate"];
        //2
        if (!genderSex) {
            stage = 2;
            readyPregnancyView.hidden = YES;
            readyPregnancySelectedView.hidden = YES;
            btnReadyPregnancy.selected = NO;
            
            nowPregnancyView.hidden = NO;
            nowPregnancySelectedView.hidden = NO;
            btnNowPregnancy.selected = YES;
            
            hadBabyView.hidden = YES;
            hadBabySelectedView.hidden = YES;
            btnHadBaby.selected = NO;
            
            _btnGivebirthDate.selected = YES;
            _btnLastMenstruation.selected = NO;
            if (mDate) {
                self.givebirthDate.text = mDate;
            }
        }
        //3
        else
        {
            stage = 3;
            readyPregnancyView.hidden = YES;
            readyPregnancySelectedView.hidden = YES;
            btnReadyPregnancy.selected = NO;
            
            nowPregnancyView.hidden = YES;
            nowPregnancySelectedView.hidden = YES;
            btnNowPregnancy.selected = NO;
            
            hadBabyView.hidden = NO;
            hadBabySelectedView.hidden = NO;
            btnHadBaby.selected = YES;
            NSString* baby_name = [Dict valueForKey:@"baby_name"];
            if (baby_name) {
                self.nicknameText.text = baby_name;
            }
            if (mDate) {
                //self.ageText.text = mDate;
                self.btnPickGiveBirtnDay.titleLabel.text = mDate;
            }
            int genderValue = [[Dict valueForKey:@"gender"]intValue];
            //男
            if (genderValue == 1)
            {
                btnBoy.selected = YES;
                btnGirl.selected = NO;
                boySelectedVIew.hidden = NO;
                girlSelectedVIew.hidden = YES;
            }
            //女
            else
            {
                btnBoy.selected = NO;
                btnGirl.selected = YES;
                boySelectedVIew.hidden = YES;
                girlSelectedVIew.hidden = NO;
            }
        }
    }
    

}
- (void) rightBtnClick : (UIButton*)sender
{
    SettingViewController* settingVC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    [self.navigationController pushViewController:settingVC animated:YES];
    [settingVC release];
}

- (IBAction)btnReadyPregnancyClicked:(id)sender
{
    if (isEdit) {
        stage = 1;
        readyPregnancyView.hidden = NO;
        readyPregnancySelectedView.hidden = NO;
        btnReadyPregnancy.selected = YES;
        
        nowPregnancyView.hidden = YES;
        nowPregnancySelectedView.hidden = YES;
        btnNowPregnancy.selected = NO;
        
        hadBabyView.hidden = YES;
        hadBabySelectedView.hidden = YES;
        btnHadBaby.selected = NO;
    }
    else
    {
        return;
    }
    

}
- (IBAction)btnNowPregnancyClicked:(id)sender
{
    if (isEdit) {
        stage = 2;
        readyPregnancyView.hidden = YES;
        readyPregnancySelectedView.hidden = YES;
        btnReadyPregnancy.selected = NO;
        
        nowPregnancyView.hidden = NO;
        nowPregnancySelectedView.hidden = NO;
        btnNowPregnancy.selected = YES;
        
        hadBabyView.hidden = YES;
        hadBabySelectedView.hidden = YES;
        btnHadBaby.selected = NO;
        
        _btnGivebirthDate.selected = YES;
        _btnLastMenstruation.selected = NO;
    }
    else
    {
        return;
    }
    
}
- (IBAction)btnHadBabyClicked:(id)sender
{
    if (isEdit) {
        stage = 3;
        readyPregnancyView.hidden = YES;
        readyPregnancySelectedView.hidden = YES;
        btnReadyPregnancy.selected = NO;
        
        nowPregnancyView.hidden = YES;
        nowPregnancySelectedView.hidden = YES;
        btnNowPregnancy.selected = NO;
        
        hadBabyView.hidden = NO;
        hadBabySelectedView.hidden = NO;
        btnHadBaby.selected = YES;
        
    }
    else
    {
        return;
    }
    
}

- (IBAction)btnSettingClicked:(id)sender{
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (!Logined)
    {
        LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginView animated:NO];
        [loginView release];
    }
    else
    {
        if (!isEdit) {
            isEdit = YES;
            //[btnSetting setTitle:@"设置完成" forState:UIControlStateNormal];
            [_stageUpLabel setText:@"设置"];
            [_stageDownLabel setText:@"完成"];
            //ageText.enabled = YES;
            [_btnPickGiveBirtnDay setTitle:self.btnPickGiveBirtnDay.titleLabel.text forState:UIControlStateNormal];
            _btnPickGiveBirtnDay.enabled = YES;
            nicknameText.enabled = YES;
            
        }
        else
        {
            if (stage == 1) {
                [[MessageManager getInstance]  startClearSetting];
                [[MessageManager getInstance]  removeUserSettinginfo];
                [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"设置成功！" time:2.0 ignoreAddition:NO parentView:self.view];
            }
            else if(stage == 2)
            {
                NSString* mDate;
                if (isWillBirthl) {
                    mDate = self.givebirthDate.text;
                }
                else
                {
                    mDate = mensDate;
                }
                
                if ([mDate length] == 0 || [mDate isEqualToString:@"点击选择日期"])
                {
                   [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"请选择日期！" time:2.0 ignoreAddition:NO parentView:self.view];
                    return;
                }
                //upload log
                BabyWriteActionLog(@"save setting info");
                [[MessageManager getInstance]startAddSettingWithDate:mDate gender:nil baby_name:nil];
            }
            else if (stage == 3)
            {
               // NSString* mDate = self.ageText.text;
                NSString* mDate = self.btnPickGiveBirtnDay.titleLabel.text;
                if ([mDate length] == 0 || [mDate isEqualToString:@"点击选择出生日期"]) {
                    [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"请选择日期！" time:2.0 ignoreAddition:NO parentView:self.view];
                    return;
                }
                NSString* mName = self.nicknameText.text;
                if ([mName length] == 0) {
                    mName = @"宝宝";
                }
//
                NSString* sex = [NSString stringWithFormat:@"%d", gender];
//                if ([sex isEqualToString:@"0"]) {
//                    [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"请选择宝宝性别！" time:2.0 ignoreAddition:NO parentView:self.view];
//                    return;
//                }
                //upload log
                BabyWriteActionLog(@"save setting info");
                [[MessageManager getInstance]startAddSettingWithDate:mDate gender:sex baby_name:mName];
                [_btnPickGiveBirtnDay setTitle:mDate forState:UIControlStateNormal];
            }
            isEdit = NO;
           // [btnSetting setTitle:@"阶段修改" forState:UIControlStateNormal];
            [_stageUpLabel setText:@"修改"];
            [_stageDownLabel setText:@"阶段"];
            //ageText.enabled = NO;
            _btnPickGiveBirtnDay.enabled = NO;
            nicknameText.enabled = NO;

        }
    }
}
- (void)myCollectionClicked:(UITapGestureRecognizer*)recognizer
{
    //我的收藏
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (!Logined)
    {
        LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginView animated:NO];
        [loginView release];
    }
    else
    {        
        SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
        resultVC.title = @"我的收藏";
        resultVC.searchType = FavoriteList;
        [self.navigationController pushViewController:resultVC animated:YES];
        [resultVC release];
        
    }
    
}
- (void)myAskClicked:(UITapGestureRecognizer*)recognizer
{
     //我的问题
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (!Logined)
    {
        LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginView animated:NO];
        [loginView release];
    }
    else
    {
        SeachResultViewController* resultVC = [[SeachResultViewController alloc] initWithNibName:@"SeachResultViewController" bundle:nil];
        resultVC.title = QuizeListTitle;
         resultVC.searchType = QuizeList;
        [self.navigationController pushViewController:resultVC animated:YES];
        [resultVC release];
       
    }
}
- (void)givebirthDateClicked:(UITapGestureRecognizer*)recognizer
{
    //点击选择预产期
    if (isEdit) {
        pickerView.hidden = NO;
        ((MWTabBarController*)[[UIApplication sharedApplication].keyWindow rootViewController]).tabBar.hidden = YES;
        [self.view bringSubviewToFront:pickerView];
    }
    else
    {
        return;
    }
}
- (IBAction)btnDatePickedClicked:(id)sender
{
    NSDate *selected = [datePicker date];
    pickerView.hidden = YES;
    ((MWTabBarController*)[[UIApplication sharedApplication].keyWindow rootViewController]).tabBar.hidden = NO;
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc]init];    
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    NSString* pickedDateStr = [dateFormat stringFromDate:selected];
    if (!isWillBirthl) {
        //280天后
        NSDate *time = [NSDate dateWithTimeInterval:280*24*60*60 sinceDate:selected];
        mensDate = [[dateFormat stringFromDate:time] retain];
    }
    
    [dateFormat release];
    self.givebirthDate.text = pickedDateStr;
}
- (IBAction)btnDatePickedCancelClicked:(id)sender
{
    pickerView.hidden = YES;
    ((MWTabBarController*)[[UIApplication sharedApplication].keyWindow rootViewController]).tabBar.hidden = NO;
}


- (IBAction)btnGivebirthDateClicked:(id)sender
{
    if (isEdit) {
        _btnGivebirthDate.selected = YES;
        _btnLastMenstruation.selected = NO;
        _imgGivebirthSelected.hidden = NO;
        _imgLastMensSelected.hidden = YES;
        dateChoice = 1;
        if (!isWillBirthl) {
            isWillBirthl = YES;
            NSDate *date = [NSDate date];
            datePicker.minimumDate = date;
            NSDate *maxTime = [NSDate dateWithTimeInterval:280*24*60*60 sinceDate:date];
            datePicker.maximumDate = maxTime;
        }
    }
    else
    {
        return;
    }
    
}
- (IBAction)btnLastMenstruationClicked:(id)sender
{
    if (isEdit) {
        _btnGivebirthDate.selected = NO;
        _btnLastMenstruation.selected = YES;
        _imgGivebirthSelected.hidden = YES;
        _imgLastMensSelected.hidden = NO;
        dateChoice = 2;
        if (isWillBirthl) {
            isWillBirthl = NO;
            NSDate *date = [NSDate date];
            NSDate *minTime = [NSDate dateWithTimeInterval:-280*24*60*60 sinceDate:date];
            datePicker.minimumDate = minTime;
            datePicker.maximumDate = date;
        }
    }
    else
    {
        return;
    }    
}

- (IBAction)btnBoyClicked:(id)sender
{
    if (isEdit) {
        boySelectedVIew.hidden = NO;
        girlSelectedVIew.hidden = YES;
        btnBoy.selected = YES;
        btnGirl.selected = NO;
        gender = 1;
    }
    else
    {
        return;
    }
   
}
- (IBAction)btnGirlClicked:(id)sender
{
    if (isEdit) {
        btnBoy.selected = NO;
        btnGirl.selected = YES;
        boySelectedVIew.hidden = YES;
        girlSelectedVIew.hidden = NO;
        gender = 2;
    }
    else
    {
        return;
    }
    
}

- (IBAction)btnPickGiveBirthDayClicked:(id)sender
{
    _giveBirthDaypickerView.hidden = NO;
    ((MWTabBarController*)[[UIApplication sharedApplication].keyWindow rootViewController]).tabBar.hidden = YES;
}

- (IBAction)giveBirthDayPickCancelClicked:(id)sender
{
    _giveBirthDaypickerView.hidden = YES;
    ((MWTabBarController*)[[UIApplication sharedApplication].keyWindow rootViewController]).tabBar.hidden = NO;
}

- (IBAction)giveBirthDayPickFinshedClicked:(id)sender
{
    ((MWTabBarController*)[[UIApplication sharedApplication].keyWindow rootViewController]).tabBar.hidden = NO;
    NSDate *selected = [_giveBirthDaydatePicker date];
    _giveBirthDaypickerView.hidden = YES;
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc]init];
    
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    NSString* pickedDateStr = [dateFormat stringFromDate:selected];
    [dateFormat release];
    self.btnPickGiveBirtnDay.titleLabel.text = pickedDateStr;
}

#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    [nicknameText resignFirstResponder];
    //[ageText resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

//    if( _editBeginAction)
    {
        [_target performSelector:_editBeginAction];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    if(_editEndAction)
    {
        [_target performSelector:_editEndAction];
    }
}

#pragma mark - Init Notification and It's Action
-(void)initNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    SEL action = @selector(handleNotification:);
    //setting
    [nc addObserver:self
           selector:@selector(SettingObjectsAdded:)
               name:SettingNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(SettingObjectsFailed:)
               name:SettingFaildedNotification
             object:nil];
    //login
    [nc addObserver:self
           selector:@selector(loginSuccessed:)
               name:LoginSuccessedNotification
             object:nil];
    //search
    [nc addObserver:self
           selector:action
               name:SearchNotification
             object:nil];
    //remind
    [nc addObserver:self
           selector:action
               name:NewRemendNotification
             object:nil];
    
    [nc addObserver:self
           selector:action
               name:NewRemendFaildedNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(loginOutSuccess:)
               name:LogoutSuccessedNotification
             object:nil];
    
    //UserInfoSuccessGetNotification
    [nc addObserver:self
           selector:@selector(userInfoGetSuccessd:)
               name:UserInfoSuccessGetNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(settingGetSuccessd:)
               name:SettingSuccessGetNotification
             object:nil];
    
    //key board notification
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void) keyboardWillShow : (NSNotification*)notify
{
    NSDictionary* info = [notify userInfo];
    NSValue* keyboardValue = [info valueForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardHeight = [keyboardValue CGRectValue].size.height;
    self.view.frame = CGRectMake(0, -_keyboardHeight+160, DeviceScreenWidth, DeviceScreenHeight);
}

- (void) keyboardWillHide : (NSNotification*)notify
{
    self.view.frame = CGRectMake(0, 0, DeviceScreenWidth, DeviceScreenHeight);
}

-(void)settingGetSuccessd:(NSNotification*)notify
{
    [self initUI];
}

-(void)userInfoGetSuccessd:(NSNotification*)notify
{
    //up date profile_image, we do not use the notify info but it has all userinfo
    [self setLoginButtonImage:YES];
}

- (void) handleNotification:(NSNotification*)notify
{
    //1. if this notify is about self
    BOOL myNotify = [self isThisNotificationWanted:notify];
    if (!myNotify && ![[notify name] isEqualToString:NewRemendNotification] )
        return;
    
    NSArray* notifyNames = @[SettingNotification, SettingFaildedNotification, LoginSuccessedNotification,SearchNotification, NewRemendNotification, NewRemendFaildedNotification,LogoutSuccessedNotification];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:notifyNames.count];
    for (int i=1; i<notifyNames.count+1; ++i) {
        [dic setValue:[NSNumber numberWithInt:i] forKey:notifyNames[i-1]];
    }
    NSString* name = [notify name];
    personcenterNotification type = [[dic valueForKey:name] intValue];
    
    switch (type) {
        case SettingNotificationT:
        {
            [self SettingObjectsAdded:notify];
        }
            break;
        case SettingFaildedNotificationT:
        {
            [self SettingObjectsFailed:notify];
        }
            break;
        case LoginSuccessedNotificationT:
        {
            [self loginSuccessed:notify];
        }
            break;
        case SearchNotificationT:
        {
            [self SearchObjectsAdded:notify];
        }
            break;
        case NewRemendNotificationT:
        {
            [self NewRemendAddObjects:notify];
        }
            break;
        case NewRemendFaildedNotificationT:
        {
            [self NewRemendFailedObjects:notify];
        }
            break;
        default:
            break;
    }
}

- (void)clearDataAfterLogout
{
    [self setLoginButtonImage:NO];
    
    _favouriteCountLabel.text = @"";
    _myAnsCountLabel.text = @"";
}

-(void)SearchObjectsAdded:(NSNotification*)notify
{
    NSDictionary* usrInfo = [notify userInfo];
    NSString*  type = [usrInfo valueForKey:@"favourite"];
    if (type)
    {
        NSString* favCount = [usrInfo valueForKey:@"total"];
        favouriteCount = [favCount intValue];
        _favouriteCountLabel.text = [NSString stringWithFormat:@"%d", favouriteCount ];
    }
    else
    {
        NSString* ansCount = [usrInfo valueForKey:@"total"];
        myAnsCount = [ansCount intValue];
        _myAnsCountLabel.text = [NSString stringWithFormat:@"%d", myAnsCount ];
    }
}

-(void)SettingObjectsAdded:(NSNotification*)notify
{
    /////
    if (stage == 2) {
        NSString* mDate = self.givebirthDate.text;
        if ([mDate length] == 0) {
            return;
        }
        if (!isWillBirthl) {
            mDate = mensDate;
        }
        NSDictionary* dict = [NSDictionary dictionaryWithObject:mDate forKey:@"mDate"];
        [[MessageManager getInstance]removeUserSettinginfo];
        [[MessageManager getInstance] saveUserSetting:dict];
        
        [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"保存成功！" time:2.0 ignoreAddition:NO parentView:self.view];
    }
   else if(stage == 3)
   {
       //////
       //NSString* mDate = self.ageText.text;
       NSString* mDate = self.btnPickGiveBirtnDay.titleLabel.text;
       if ([mDate length] == 0) {
           return;
       }
       NSString* baby_name = self.nicknameText.text;
       if ([baby_name length] == 0) {
           baby_name = @"宝宝";
       }
       NSString* sex = [NSString stringWithFormat:@"%d", gender];
       
       NSArray* values = [NSArray arrayWithObjects:mDate, sex, baby_name, nil];
       NSArray* keys = [NSArray arrayWithObjects:@"mDate", @"gender", @"baby_name", nil];
       NSDictionary* dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
       [[MessageManager getInstance]removeUserSettinginfo];
       [[MessageManager getInstance] saveUserSetting:dict];
       
       [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"设置成功！" time:2.0 ignoreAddition:NO parentView:self.view];
   }

//    {
//        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(popSelfView) userInfo:nil repeats:NO];
//    }
}
-(void)SettingObjectsFailed:(NSNotification*)notify
{
    [[LKTipCenter defaultCenter] postSmallCenterTipWithMessage:@"设置失败！" time:2.0 ignoreAddition:NO parentView:self.view];
}

-(void)loginSuccessed:(NSNotification*)notify
{
    [self initUI];
    [[MessageManager getInstance] startGetUserInfo];
    [[MessageManager getInstance] startGetSettingInfoWithSender:self];
    [[MessageManager getInstance]   startGetFavoriteListWithSender:self page:1];
    [[MessageManager getInstance]   startGetMyQuizeListWithSender:self param:nil page:1];
    //judge if is an expert
    NSString* userID = [[RegValueSaver getInstance] readSystemInfoForKey:RegKey_CurrentAccount];
    [[MessageManager getInstance] startGetExpertInfoWithSender:self args:@[userID]];
    
    isEdit = NO;
}

-(void)loginOutSuccess:(NSNotification*)notify
{
    [self initUI];
    [self clearDataAfterLogout];
    isEdit = NO;
    [_stageUpLabel setText:@"设置"];
    [_stageDownLabel setText:@"阶段"];
}

-(void)NewRemendAddObjects:(NSNotification*)notify
{
    NSDictionary* userInfo = [notify userInfo];
    int count = [[userInfo objectForKey:@"count"] intValue];
    
    [self showBadge:count];
}
-(void)NewRemendFailedObjects:(NSNotification*)notify
{
    [self showBadge:0];
}

- (void) showBadge : (int) count
{
    //1.my Question Btn
    [btnMyAsk setBadge:(count > 0 ? count : 0)];
    
    //2.tabbar
    UIButton* personCenter = ((MWTabBarController*)[WindowsManager sharedInstance].window.rootViewController).tabBar.buttons[3];
    [personCenter setBadge:(count > 0 ? count : 0)];
}
//
#pragma mark - UIAlertViewDelegate  - login out
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)// make sure to logout
    {
        [[MessageManager getInstance] startLogout];
        [self clearDataAfterLogout];
    }
}
- (void)setLoginButtonImage : (BOOL)bLogined
{
    _uesrName.text = @"未登录";    
    _userPhoto.hidden = YES;
    _userDefaultPhoto.hidden = NO;
    if (bLogined) //用户头像
    {
        UIImageView* userHeadImage = [[[UIImageView alloc] initWithFrame:CGRectMake(6.5, 6.5, 56, 56)] autorelease];
        userHeadImage.image = [UIImage imageNamed:@"img_personalcenter_headpicture_default.png"]; //默认头像
        userHeadImage.layer.cornerRadius = 28;
        userHeadImage.layer.masksToBounds = YES;
        
        NSString* imageUrl = [[[RegValueSaver  getInstance] readAccountDict] valueForKey:@"profile_image_url"];
        if ( imageUrl )
        {
            NSURL* url = [NSURL URLWithString:imageUrl];
            [userHeadImage setImageWithURL:url];
        }
        
        NSString *mName = [[[RegValueSaver  getInstance] readAccountDict] valueForKey:@"screen_name"];
        if ( mName )
        {
            _uesrName.text = mName;
        }
        _userPhoto.hidden = NO;
        _userDefaultPhoto.hidden = YES;
        [_userPhoto addSubview:userHeadImage];
    }
    else
    {
        UIImageView* userHeadImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 69, 69)] autorelease];
        userHeadImage.image = [UIImage imageNamed:@"img_personalcenter_headpicture_default.png"]; //默认头像
        [_userDefaultPhoto addSubview:userHeadImage];
    }

}

- (IBAction)btnUserPhotoClicked:(id)sender
{
    //登陆界面
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (!Logined)
    {
        LoginViewController* loginView = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginView animated:NO];
        [loginView release];
    }
    else
    {
        UIAlertView* loginAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经登录, 确定要退出登录吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [loginAlertView show];
        [loginAlertView release];
    }
}


#pragma mark - Hide Keyboard

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [nicknameText resignFirstResponder];
}
@end

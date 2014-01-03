//
//  HeaderFocusView.m
//  babyfaq
//
//  Created by YANGJINGXI on 13-6-13.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "RootViewController.h"

@interface PersonCenterViewController : RootViewController<UITextFieldDelegate, UIAlertViewDelegate>
{
    NSInteger gender;
    NSInteger dateChoice;
    NSInteger stage;
    NSInteger favouriteCount;
    NSInteger myAnsCount;
    BOOL isEdit;
    BOOL isWillBirthl;
    NSString *mensDate;
    
    CGFloat         _keyboardHeight;
}
@property (retain, nonatomic) IBOutlet UILabel *stageUpLabel;
@property (retain, nonatomic) IBOutlet UILabel *stageDownLabel;
@property (retain, nonatomic) IBOutlet UILabel *favouriteCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *myAnsCountLabel;
@property (retain, nonatomic) IBOutlet UIImageView *userPhoto;
@property (retain, nonatomic) IBOutlet UILabel *uesrName;
@property (retain, nonatomic) IBOutlet UIImageView *userDefaultPhoto;
@property (retain, nonatomic) IBOutlet UIButton *btnReadyPregnancy;
@property (retain, nonatomic) IBOutlet UIButton *btnNowPregnancy;
@property (retain, nonatomic) IBOutlet UIButton *btnHadBaby;
@property (retain, nonatomic) IBOutlet UIButton *btnSetting;
@property (retain, nonatomic) IBOutlet UIView *btnMyCollection;
@property (retain, nonatomic) IBOutlet UIView *btnMyAsk;
@property (retain, nonatomic) IBOutlet UIView *readyPregnancyView;
@property (retain, nonatomic) IBOutlet UIView *nowPregnancyView;
@property (retain, nonatomic) IBOutlet UIView *hadBabyView;

@property (retain, nonatomic) IBOutlet UIView *readyPregnancySelectedView;
@property (retain, nonatomic) IBOutlet UIView *nowPregnancySelectedView;
@property (retain, nonatomic) IBOutlet UIView *hadBabySelectedView;

//
@property (retain, nonatomic) IBOutlet UILabel *givebirthDate;
@property (retain, nonatomic) IBOutlet UIView *pickerView;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (retain, nonatomic) IBOutlet UIButton *datePickFinished;
@property (retain, nonatomic) IBOutlet UIButton *btnGivebirthDate;
@property (retain, nonatomic) IBOutlet UIButton *btnLastMenstruation;
@property (retain, nonatomic) IBOutlet UIImageView *imgGivebirthSelected;
@property (retain, nonatomic) IBOutlet UIImageView *imgLastMensSelected;
//
@property (retain, nonatomic) IBOutlet UIButton *btnBoy;
@property (retain, nonatomic) IBOutlet UIButton *btnGirl;
@property (retain, nonatomic) IBOutlet UIView  *boySelectedVIew;
@property (retain, nonatomic) IBOutlet UIView  *girlSelectedVIew;
@property (nonatomic, retain) IBOutlet UITextField *ageText;
@property (nonatomic, retain) IBOutlet UITextField *nicknameText;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL editBeginAction;
@property (nonatomic, assign) SEL editEndAction;
@property (retain, nonatomic) IBOutlet UIView *giveBirthDaypickerView;
@property (retain, nonatomic) IBOutlet UIDatePicker *giveBirthDaydatePicker;
@property (retain, nonatomic) IBOutlet UIButton *btnPickGiveBirtnDay;

- (IBAction)btnReadyPregnancyClicked:(id)sender;
- (IBAction)btnNowPregnancyClicked:(id)sender;
- (IBAction)btnHadBabyClicked:(id)sender;
- (IBAction)btnSettingClicked:(id)sender;
- (IBAction)btnDatePickedClicked:(id)sender;
- (IBAction)btnBoyClicked:(id)sender;
- (IBAction)btnGirlClicked:(id)sender;
- (IBAction)btnGivebirthDateClicked:(id)sender;
- (IBAction)btnLastMenstruationClicked:(id)sender;
- (IBAction)btnUserPhotoClicked:(id)sender;
- (IBAction)btnDatePickedCancelClicked:(id)sender;
- (IBAction)giveBirthDayPickCancelClicked:(id)sender;
- (IBAction)giveBirthDayPickFinshedClicked:(id)sender;
- (IBAction)btnPickGiveBirthDayClicked:(id)sender;

- (void)myCollectionClicked:(UITapGestureRecognizer*)recognizer;
- (void)myAskClicked:(UITapGestureRecognizer*)recognizer;
- (void)givebirthDateClicked:(UITapGestureRecognizer*)recognizer;
- (void)birthdayDateClicked:(UITapGestureRecognizer*)recognizer;
-(void)initUI;
-(void) initUserInfo;


@end

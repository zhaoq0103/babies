//
//  LoginViewController.h
//  babyfaq
//
//  Created by YANGJINGXI on 13-6-18.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "UITouchScrollView.h"

@interface LoginViewController : RootViewController<UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITextField *LoginaIdText;
@property (nonatomic, retain) IBOutlet UITextField *passWordText;
@property (retain, nonatomic) IBOutlet UIButton *btnLogin;
@property (retain, nonatomic) IBOutlet UIButton *btnRegister;
@property (retain, nonatomic) IBOutlet UITouchScrollView *touchScrollView;

- (IBAction)btnLoginClicked:(id)sender;
- (IBAction)btnRegisterClicked:(id)sender;
-(void)initNotification;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL editBeginAction;
@property (nonatomic, assign) SEL editEndAction;
@end

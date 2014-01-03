//
//  BCSearchBar.m
//  SinaNews
//
//  Created by shieh exbice on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BCSearchBar.h"

#define kSearchBarMargin 4

@interface BCSearchBar() 
-(void)initCancelBtn;
@end

@implementation BCSearchBar
@synthesize delegate;
@synthesize inputZoneView,cancelBtn,modeBtn,inputField,inputBackgroundView,backgroundField,pullmenuView,separateView;
@synthesize placeHoder;


-(void)dealloc
{
    [cancelBtn removeFromSuperview];
    [cancelBtn release];
    [inputZoneView release];
    [modeBtn release];
    [inputBackgroundView release];
    [placeHoder release];
    [inputField release];
    [backgroundField release];
    [pullmenuView release];
    [separateView release];
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        UIImageView* aInputZoneView = [[UIImageView alloc] initWithFrame:frame];
        aInputZoneView.userInteractionEnabled = YES;
        [self addSubview:aInputZoneView];
        self.inputZoneView = aInputZoneView;
        [aInputZoneView release];
        UIImageView* backGroundField = [[UIImageView alloc] initWithFrame:inputZoneView.bounds];
        backGroundField.userInteractionEnabled = NO;
        backGroundField.autoresizingMask =UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [inputZoneView addSubview:backGroundField];
        self.backgroundField = backGroundField;
        [backGroundField release];
        
        UIImageView* pullmune = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.pullmenuView = pullmune;
        [inputZoneView addSubview:pullmune];
        [pullmune release];
        UIImageView* separate = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.separateView = separate;
        [inputZoneView addSubview:separate];
        [separate release];
        
        UITextField* input = [[UITextField alloc] initWithFrame:CGRectZero];
        input.background = nil;
        input.backgroundColor = [UIColor clearColor];
        input.placeholder = @"搜索";
        input.font = [UIFont systemFontOfSize:14.0];
        input.clearButtonMode = UITextFieldViewModeWhileEditing;
        input.returnKeyType = UIReturnKeySearch;
        input.delegate = (id<UITextFieldDelegate>)self;
        self.inputField = input;
        [inputZoneView addSubview:input];
        [input release];
        
    }
    
    return self;
}

-(void)initCancelBtn
{
    if (!cancelBtn) {
        UIButton* tempBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        tempBtn.frame = CGRectMake(0, 0, 50.0, 50.0);
        [tempBtn setTitle:@"取消" forState:UIControlStateNormal];
        self.cancelBtn = tempBtn;
    }
}

-(void)setModeBtn:(UIButton *)aModeBtn
{
    if (modeBtn!=aModeBtn) {
        [modeBtn release];
        modeBtn = aModeBtn;
        [modeBtn retain];
    }
    [self.inputZoneView addSubview:modeBtn];
}

-(void)setCancelBtn:(UIButton *)aCancelBtn
{
    if (cancelBtn!=aCancelBtn) {
        [cancelBtn removeTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn removeFromSuperview];
        [cancelBtn release];
        cancelBtn = aCancelBtn;
        [cancelBtn retain];
        [self addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(UIImageView*)inputBackgroundView
{
    if (!inputBackgroundView) {
        inputBackgroundView = [[UIImageView alloc] init];
        backgroundField.hidden = YES;
        CGRect inputZoneFrame = self.inputZoneView.bounds;
        inputBackgroundView.frame = inputZoneFrame;
        inputBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.inputZoneView addSubview:inputBackgroundView];
        [self.inputZoneView sendSubviewToBack:inputBackgroundView];
    }
    return inputBackgroundView;
}

-(void)setPlaceHoder:(NSString *)aPlaceHoder
{
    if (placeHoder!=aPlaceHoder) {
        [placeHoder release];
        placeHoder = aPlaceHoder;
        [placeHoder retain];
    }
    inputField.placeholder = placeHoder;
}

-(void)cancelBtnClicked:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(searchBar:cancelClicked:)]) {
        [self.delegate searchBar:self cancelClicked:sender];
    }
}

-(void)layoutSubviews
{
    CGRect mainRect = self.bounds;
    [self initCancelBtn];
    CGRect cancelRect = cancelBtn.frame;
    CGRect inputZoneRect = inputZoneView.frame;
    cancelRect.origin.x = mainRect.size.width - (cancelRect.size.width + kSearchBarMargin);
    cancelRect.size.height = (cancelRect.size.height)>(mainRect.size.height-2*kSearchBarMargin)?(mainRect.size.height-2*kSearchBarMargin):(cancelRect.size.height);
    cancelRect.origin.y = mainRect.size.height/2 - cancelRect.size.height/2;
    cancelBtn.frame = cancelRect;
    inputZoneRect.size.width = mainRect.size.width - cancelRect.size.width - 3*kSearchBarMargin;
    inputZoneRect.size.height = mainRect.size.height - 2*kSearchBarMargin;
    inputZoneRect.origin.x = kSearchBarMargin;
    inputZoneRect.origin.y = kSearchBarMargin;
    inputZoneView.frame = inputZoneRect;
    
    if (modeBtn) {
        CGRect modeFrame = modeBtn.bounds;
        modeFrame.origin.x = kSearchBarMargin;
        modeFrame.origin.y = inputZoneRect.size.height/2 - modeFrame.size.height/2;
        modeBtn.frame = modeFrame;
        
        CGRect pullmanuFrame = self.inputZoneView.bounds;
        pullmanuFrame.origin.x = modeFrame.size.width + modeFrame.origin.x + kSearchBarMargin;
        pullmanuFrame.origin.y = 12;
        pullmanuFrame.size.width = 6;
        pullmanuFrame.size.height = 4;
        
        self.pullmenuView.frame = pullmanuFrame;
        
        CGRect separateFrame = self.inputZoneView.bounds;
        separateFrame.origin.x = modeFrame.size.width + modeFrame.origin.x + kSearchBarMargin + pullmanuFrame.size.width + kSearchBarMargin;
        separateFrame.origin.y = kSearchBarMargin;
        separateFrame.size.width = 1;
        separateFrame.size.height = 23;
        
        self.separateView.frame = separateFrame;
        /*
        CGRect inputFrame = self.inputZoneView.bounds;
        inputFrame.origin.x = modeFrame.size.width + modeFrame.origin.x + kSearchBarMargin;
        inputFrame.origin.y = kSearchBarMargin;
        inputFrame.size.width = inputZoneRect.size.width - inputFrame.origin.x - kSearchBarMargin;
        inputFrame.size.height = inputZoneRect.size.height - 2*kSearchBarMargin;
        self.inputField.frame = inputFrame;
         */
        CGRect inputFrame = self.inputZoneView.bounds;
        inputFrame.origin.x = modeFrame.size.width + modeFrame.origin.x + kSearchBarMargin + pullmanuFrame.size.width + kSearchBarMargin + separateFrame.size.width + kSearchBarMargin;
        inputFrame.origin.y = kSearchBarMargin;
        inputFrame.size.width = inputZoneRect.size.width - inputFrame.origin.x - kSearchBarMargin - pullmanuFrame.size.width - kSearchBarMargin;
        inputFrame.size.height = inputZoneRect.size.height - 2*kSearchBarMargin;
        self.inputField.frame = inputFrame;
    }
    else
    {
        CGRect inputFrame = self.inputField.frame;
        inputFrame = inputZoneView.bounds;
        inputFrame.origin.x += kSearchBarMargin;
        inputFrame.origin.y += kSearchBarMargin;
        inputFrame.size.width = inputFrame.size.width - 2*kSearchBarMargin;
        inputFrame.size.height = inputFrame.size.height - 2*kSearchBarMargin;
        self.inputField.frame = inputFrame;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString* searchText = textField.text;
    if ([delegate respondsToSelector:@selector(searchBar:returnContent:)]) {
        [delegate searchBar:self returnContent:searchText];
    }
    
    return YES;
}

-(BOOL)resignFirstResponder
{
    [self.inputField resignFirstResponder];
    return YES;
}

@end

//
//  BCViewController.m
//  SinaNews
//
//  Created by shieh exbice on 11-11-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BCViewController.h"
#import "BCNavigationBar.h"

@interface BCViewControllerDefaultData : NSObject
{
    UIImage* navBackgroundImage;
    float navigationBarHeight;
    UIButton* navBackBtn;
    UIColor* navTitileColor;
}
@property(retain)UIImage* navBackgroundImage;
@property(assign)float navigationBarHeight;
@property(retain)UIButton* navBackBtn;
@property(retain)UIColor* navTitileColor;
@property(retain)UIImageView* navExtraView;


+ (id)getInstance;
@end

static BCViewControllerDefaultData* s_BCViewControllerData = nil;

@implementation BCViewControllerDefaultData
@synthesize navBackgroundImage,navigationBarHeight;
@synthesize navBackBtn;
@synthesize navTitileColor;
@synthesize navExtraView;

+ (id)getInstance
{
	if (s_BCViewControllerData == nil)
	{
		//没有创建则创建
		s_BCViewControllerData = [[BCViewControllerDefaultData alloc] init];
	}
	return s_BCViewControllerData;
}

-(id)init
{
    self = [super init];
    navigationBarHeight = 45.0;
    return self;
}

-(void)dealloc
{
    [navBackgroundImage release];
    [navBackBtn release];
    [navTitileColor release];
    [navExtraView release];
    
    [super dealloc];
}

@end

@interface BCViewController()
-(void)realInit;
@end

@implementation BCViewController

@synthesize navigationBar = mNavigationBar;
@synthesize navigationBarHiden = mNavigationBarHiden;
@synthesize navigationBarHeight = mNavigationBarHeight;
@synthesize containView,titleView,backButton,showBackBtn;
@synthesize titleColor,titleFont,titleImage;
@synthesize containFillBounds;

+(void)setDefaultNavigationBarBackgroundImage:(UIImage*)aImage
{
    [[BCViewControllerDefaultData getInstance] setNavBackgroundImage:aImage];
}

+(void)setDefaultNavigationBarHeight:(float)height
{
    [[BCViewControllerDefaultData getInstance] setNavigationBarHeight:height];
}

+(void)setDefaultNavigationBarBackBtn:(UIButton*)backBtn
{
    [[BCViewControllerDefaultData getInstance] setNavBackBtn:backBtn];
}

+(void)setDefaultNavigationBarTitleColor:(UIColor*)titleColor
{
    [[BCViewControllerDefaultData getInstance] setNavTitileColor:titleColor];
}

+(void)setDefaultNavigationBarExtraImageView:(UIImageView*)extraView
{
    [[BCViewControllerDefaultData getInstance] setNavExtraView:extraView];
}

-(void)dealloc
{
    [mNavigationBar release];
    [containView release];
    [backButton release];
    [titleView release];
    [titleColor release];
    [titleFont release];
    [titleImage release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self realInit];
        showBackBtn = YES;
        mNavigationBarHiden = NO;
        hasNib = NO;
        if (nibNameOrNil) {
            hasNib = YES;
        }
    }
    return self;
}

-(void)realInit
{
    mNavigationBarHeight = [[BCViewControllerDefaultData getInstance] navigationBarHeight];
    if (!mNavigationBar) {
        BCNavigationBar* navBar = [[BCNavigationBar alloc] init];
        navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        navBar.userInteractionEnabled = YES;
        navBar.backgroundColor = [UIColor clearColor];
        if ([[BCViewControllerDefaultData getInstance] navBackgroundImage]) 
        {
            navBar.image = [[BCViewControllerDefaultData getInstance] navBackgroundImage];
        }
        self.navigationBar = navBar;
        [navBar release];
        
        UIImageView* extraView = [[BCViewControllerDefaultData getInstance] navExtraView];
        if (extraView) {
            UIImageView* newExtraView = [[UIImageView alloc] initWithFrame:extraView.frame];
            newExtraView.image = extraView.image;
            newExtraView.tag = 123456;
            [self.navigationBar addSubview:newExtraView];
            [newExtraView release];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    /*
    if (!hasNib) {
        if (!containView) {
            containView = [[UIView alloc] init];
            containView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
        CGRect superFrame = [[UIScreen mainScreen] applicationFrame];
        UIView* superView = [[UIView alloc] initWithFrame:superFrame];
        self.view = superView;
        mNavigationBar.frame = CGRectMake(0, 0, superFrame.size.width, mNavigationBarHeight);
        CGRect containFrame = superView.bounds;
        containFrame.size.height = containFrame.size.height - mNavigationBarHeight;
        containFrame.origin.y = mNavigationBarHeight;
        containView.frame = containFrame;
        [superView addSubview:mNavigationBar];
        [superView addSubview:containView];
        [superView release];
    }
     */
}

-(void)setTitleView:(UIView *)aTitleView
{
    if (titleView) {
        [titleView removeFromSuperview];
        UIView* oldView = titleView;
        titleView = aTitleView;
        [titleView retain];
        [oldView release];
    }
    else
    {
        titleView = aTitleView;
        [titleView retain];
    }
    [self.navigationBar addSubview:titleView];
}

-(UIButton*)backButton
{
    if (!backButton&&showBackBtn) {
        UIButton* defaultBtn = [[BCViewControllerDefaultData getInstance] navBackBtn];
        if (!defaultBtn) {
            UIButton* aBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            backButton = aBtn;
            [backButton retain];
            [backButton setTitle:@"返回" forState:UIControlStateNormal];
            [backButton sizeToFit];
            CGRect backFrame = backButton.frame;
            backFrame.size.height = backFrame.size.height+6>self.navigationBarHeight?(self.navigationBarHeight-6):backFrame.size.height;
            backButton.frame = backFrame;
        }
        else
        {
            UIButton* aBtn = [[UIButton alloc] init];
            aBtn.frame = defaultBtn.frame;
            NSString* title = [defaultBtn titleForState:UIControlStateNormal];
            [aBtn setTitle:title forState:UIControlStateNormal];
            UIImage* normalImage = [defaultBtn backgroundImageForState:UIControlStateNormal];
            [aBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
            UIImage* highlyImage = [defaultBtn backgroundImageForState:UIControlStateHighlighted];
            [aBtn setBackgroundImage:highlyImage forState:UIControlStateHighlighted];
            UIImage* normalForceImage = [defaultBtn imageForState:UIControlStateNormal];
            [aBtn setImage:normalForceImage forState:UIControlStateNormal];
            UIImage* highlyForceImage = [defaultBtn imageForState:UIControlStateHighlighted];
            if (highlyForceImage!=normalForceImage) {
                [aBtn setImage:highlyForceImage forState:UIControlStateHighlighted];
            }
            aBtn.titleLabel.font = defaultBtn.titleLabel.font;
            UIColor* normalColor = [defaultBtn titleColorForState:UIControlStateNormal];
            [aBtn setTitleColor:normalColor forState:UIControlStateNormal];
            UIColor* highlyColor = [defaultBtn titleColorForState:UIControlStateHighlighted];
            [aBtn setTitleColor:highlyColor forState:UIControlStateHighlighted];
            self.backButton = aBtn;
            [aBtn release];
        }
    }
    return backButton;
}

-(void)backBtnClicked:(UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)initTitleView
{
    if (!titleView) {
        TitleView* newTitleView = [[TitleView alloc] init];
        self.titleView = newTitleView;
        UIColor* showColor = titleColor;
        if (!showColor) {
            showColor =[[BCViewControllerDefaultData getInstance] navTitileColor];
        }
        if (showColor) {
            newTitleView.titleColor = showColor;
        }
        [self.navigationBar addSubview:newTitleView];
        [newTitleView release];
    }
}

-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    [self initTitleView];
    if ([titleView isKindOfClass:[TitleView class]]) {
        ((TitleView*)titleView).title = title;
    }
    
}

-(void)setTitleColor:(UIColor*)aColor
{
    [self initTitleView];
    if ([titleView isKindOfClass:[TitleView class]]) {
        ((TitleView*)titleView).titleColor = aColor;
    }
}

-(void)setTitleiFont:(UIFont*)aFont
{
    [self initTitleView];
    if ([titleView isKindOfClass:[TitleView class]]) {
        ((TitleView*)titleView).titleFont = aFont;
    }
}

-(void)setTitleImage:(UIImage *)aTitleImage
{
    [self initTitleView];
    if ([titleView isKindOfClass:[TitleView class]]) {
        ((TitleView*)titleView).titleImage = aTitleImage;
    }
}

-(void)setContainFillBounds:(BOOL)bContainFillBounds
{
    containFillBounds = bContainFillBounds;
    if (self.containView) {
        if (bContainFillBounds) {
            containView.frame = self.view.bounds;
        }
        else
        {
            CGRect containRect = self.view.bounds;
            containRect.size.height = containRect.size.height - mNavigationBarHeight;
            containRect.origin.y = mNavigationBarHeight;
            containView.frame = containRect;
        }
    }
}

-(void)setNavigationBarHiden:(BOOL)aNavigationBarHiden
{
    mNavigationBarHiden = aNavigationBarHiden;
    if (aNavigationBarHiden) {
        self.navigationBar.hidden = YES;
        CGRect containRect = self.containView.superview.bounds;
        self.containView.frame = containRect;
    }
    else
    {
        self.navigationBar.hidden = NO;
        CGRect containRect = self.containView.superview.bounds;
        if (!containFillBounds) {
            containRect.size.height = containRect.size.height - mNavigationBarHeight;
            containRect.origin.y = mNavigationBarHeight;
        }
        containView.frame = containRect;
    }
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (hasNib) {
        CGRect superFrame = self.view.frame;
        if (!self.containView) {
            self.containView = self.view;
            containView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
        UIView* superView = [[UIView alloc] initWithFrame:superFrame];
        self.view = superView;
        mNavigationBar.frame = CGRectMake(0, 0, superFrame.size.width, mNavigationBarHeight);
        if (self.navigationBarHiden) {
            mNavigationBar.hidden = YES;
        }
        CGRect containFrame = superView.bounds;
        if (!containFillBounds&&!self.navigationBarHiden) {
            containFrame.size.height = containFrame.size.height - mNavigationBarHeight;
            containFrame.origin.y = mNavigationBarHeight;
        }
        
        containView.frame = containFrame;
        [superView addSubview:mNavigationBar];
        [superView addSubview:containView];
        [superView sendSubviewToBack:containView];
        [superView release];
    }
    else
    {
        CGRect superFrame = self.view.frame;
        //CGRect superFrame = [[UIScreen mainScreen] applicationFrame];
        UIView* superView = [[UIView alloc] initWithFrame:superFrame];
        superView.autoresizingMask = self.view.autoresizingMask;
        self.view = superView;
        
        /*
         UIView* superView = self.view;
         CGRect superFrame = superView.frame;
         */
        
        mNavigationBar.frame = CGRectMake(0, 0, superFrame.size.width, mNavigationBarHeight);
        [superView addSubview:mNavigationBar];
        if (self.navigationBarHiden) {
            mNavigationBar.hidden = YES;
        }
        if (!containView) 
        {
            containView = [[UIView alloc] init];
            containView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
        
        
        
        CGRect containFrame = superView.bounds;
        if (!containFillBounds&&!self.navigationBarHiden) {
            containFrame.size.height = containFrame.size.height - mNavigationBarHeight;
            containFrame.origin.y = mNavigationBarHeight;
        }
        
        containView.frame = containFrame;
        [superView addSubview:containView];
        [superView sendSubviewToBack:containView];
        [superView release];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end

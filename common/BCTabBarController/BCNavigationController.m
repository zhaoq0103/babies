//
//  BCNavigationController.m
//  SinaNews
//
//  Created by shieh exbice on 11-11-4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BCNavigationController.h"
#import "BCViewController.h"

#define NavBackViewtag 1998767
#define NavBackViewtag_ImageView 1998768
/*
@interface MyNavigationBar : UINavigationBar
@end
@implementation MyNavigationBar
- (void)drawRect:(CGRect)rect 
{
    [super drawRect:rect];
}
@end

@implementation UINavigationBar (UINavigationBarCategory)

+ (Class)class 
{  
    return NSClassFromString(@"MyNavigationBar");
}

-(void)setBackgroundImage:(UIImage *)backgroundImage
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:backgroundImage]; 
    imageView.hidden = YES;
    imageView.frame = CGRectZero;
    imageView.tag = NavBackViewtag;
    [self addSubview:imageView];
    [imageView release];
}

-(UIImage*)backgroundImage
{
    UIImageView* backgroundView = (UIImageView*)[self viewWithTag:NavBackViewtag];
    return backgroundView.image;
}


- (void)drawRect:(CGRect)rect
{
    UIImage *image = [self backgroundImage];
    [image drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
}

@end
*/

@implementation BCNavigationController

@synthesize tabBarImage,tabBarHighlyImage,tabBarTitle,tabBarTitleColor,tabBarTitleHighlyColor, bubbleImage;

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    
    self = [super initWithRootViewController:rootViewController];
    if ([rootViewController isKindOfClass:[BCViewController class]]) {
        [self setNavigationBarHidden:YES];
    }
    
    return self;
}

-(void)dealloc
{
    [tabBarImage release];
    [tabBarHighlyImage release];
    [tabBarTitle release];
    [tabBarTitleColor release];
    [tabBarTitleHighlyColor release];
    [bubbleImage release];
    [super dealloc];
}

-(void)didBeforeShowSubViewController:(UIViewController*)viewController
{
    UIViewController* topController = self.topViewController;
    if (topController&&topController!=viewController) {
        if ([viewController isKindOfClass:[BCViewController class]]) {
            BCViewController* bcViewController = (BCViewController*)viewController;
            if (bcViewController.showBackBtn) {
                UIButton* backBtn = bcViewController.backButton;
                CGRect backBtnFrame = backBtn.frame;
//                UIView* controllerView = bcViewController.view;
//                CGRect navBarFrame = bcViewController.navigationBar.frame;
//                backBtnFrame.origin.y = navBarFrame.origin.y + (navBarFrame.size.height/2 - backBtnFrame.size.height/2);
                backBtnFrame.origin.x = 4;
                backBtn.frame = backBtnFrame;
                [backBtn addTarget:bcViewController action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [bcViewController.navigationBar addSubview:backBtn];
            }
        }
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self didBeforeShowSubViewController:viewController];
    [super pushViewController:viewController animated:animated];
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    [self didBeforeShowSubViewController:modalViewController];
    [super presentModalViewController:modalViewController animated:animated];
}

@end

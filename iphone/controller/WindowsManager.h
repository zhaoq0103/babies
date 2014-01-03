//
//  WindowsManager.h
//  babyfaq
//
//  Created by mayanwei on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MWTabBarController;
@class NewUserHelpScroll;

@interface WindowsManager : NSObject<UIScrollViewDelegate, UINavigationControllerDelegate>
{
    MWTabBarController*     mwTabBarController;
    NewUserHelpScroll*      _helpScroll;
    BOOL                    _endHelp;
}

@property (strong, nonatomic) UIWindow *window;


+ (WindowsManager *)sharedInstance;
- (void)showTabbarViewController;
- (void)showHelperViewController;

@end
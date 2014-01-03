//
//  AppDelegate.m
//  babyfaq
//
//  Created by xie shuigeng on 13-5-22.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "AppDelegate.h"
#import "WindowsManager.h"
#import "RegValueSaver.h"
#import "defines.h"
#import "MessageManager.h"
#import "Reachability.h"
#import "MobClick.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _internetReach = (Reachability*)[[Reachability reachabilityForInternetConnection] retain];
	[_internetReach startNotifier];
    //
    NSNumber* newUserFlag = [[RegValueSaver getInstance] readSystemInfoForKey:APP_SINABABY_FIRSTRUN];
    if (!newUserFlag || ![newUserFlag boolValue])
    {
        [[WindowsManager sharedInstance] showHelperViewController];
    }
    else
    {
        [[MessageManager getInstance] startLogin:nil];
        [[WindowsManager sharedInstance] showTabbarViewController];
    }
    
    application.applicationIconBadgeNumber = 0;
    //clear all, gan jing li suo!
    [application cancelAllLocalNotifications];
    
    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector: @selector(GetNewRemind) userInfo:nil repeats:YES];
    
    //NSString *cid = [NSString stringWithFormat:@"SinaBabyfaq%@", (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    //MobClick startWithAppkey:kAppKeyFromUMeng reportPolicy:SEND_INTERVAL channelId:cid];
    //[MobClick setLogSendInterval:120.0f];
    [MobClick startWithAppkey:kAppKeyFromUMeng];
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#endif
    
    return YES;
}		

- (void)dealloc
{
    [_internetReach release];
    [super dealloc];
}

- (NetworkStatus) netWorkStatus
{
    return _internetReach.currentReachabilityStatus;
}

-(void)GetNewRemind
{
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (Logined) {
        [[MessageManager getInstance]   startGetNewRecomendWithSender:self];
    }
}

- (void)getNewRemindBackground
{
    BOOL Logined = [[MessageManager getInstance] hasLogined];
    if (Logined) {
        [[MessageManager getInstance]   startGetNewRecomendBackground];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:
//        ^(void){
//            [self getNewRemindBackground];
//        }
//    ];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self removeLocalNotification];
    [[UIApplication  sharedApplication] clearKeepAliveTimeout];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) createLocalNotification : (int)badgeCount
{
    
    UIApplication* app = [UIApplication sharedApplication];
    //clear all, gan jing li suo!
    [app cancelAllLocalNotifications];
    
    
    UILocalNotification* notify = [[UILocalNotification alloc] init];
    if (notify) {
        notify.alertBody = [NSString stringWithFormat:@"你的提问有了 %d条 新的回答!", badgeCount];
        notify.applicationIconBadgeNumber = badgeCount;
        notify.repeatInterval = 0;
        notify.timeZone = [NSTimeZone defaultTimeZone];
        notify.soundName = UILocalNotificationDefaultSoundName;
        notify.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        notify.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2013] forKey:@"tag"];
        
        
        [app scheduleLocalNotification:notify];
        [notify release];
    }
}

- (void) removeLocalNotification
{
    UIApplication* app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = 0;
    
    if (app) {
        NSArray* notifies = [app scheduledLocalNotifications];
        if (notifies && notifies.count > 0) {
            for (UILocalNotification* notify in notifies)
            {
                NSNumber* tag = [[notify userInfo] valueForKey:@"tag"];
                
                if ([tag intValue] == 2013) {
                    [app cancelLocalNotification:notify];
                    break;
                }
            }
        }
        
    }
    
}

@end

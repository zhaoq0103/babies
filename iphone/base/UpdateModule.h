//
//  UpdateModule.h
//  SinaFinance
//
//  Created by shieh exbice on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//程序启动后调用[[UpdateModule getInstance]setUpdateDomain:@"http://m.sina.com.cn/js/5/20120119/7.json"];[[UpdateModule getInstance] start];
//设置中增加[[UpdateModule getInstance]startCheckUpdate:YES];

#import <Foundation/Foundation.h>

#define UpdateCheckedNotification @"UpdateCheckedNotification"

@interface UpdateModule : NSObject
{
    NSString* updateDomain;
}
@property(nonatomic,retain)NSString* updateDomain;
+(id)getInstance;
-(void)startrequest;
-(void)stop;
-(void)startCheckUpdate:(BOOL)forceShow;
@end

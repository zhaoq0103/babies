//
//  ProjectLogUploader.h
//  SinaFinance
//
//  Created by shieh exbice on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//程序启动后调用
//[[ProjectLogUploader getInstance] setAppKey:@"3346933778"];
//[[ProjectLogUploader getInstance] startup];

//应用程序的- (void)applicationDidBecomeActive:(UIApplication *)application函数中调用
//[[ProjectLogUploader getInstance] refreshSID];

//其他功能点中调用
//[[ProjectLogUploader getInstance] writeDataString:@"xxxx"];

//程序退出时可以调用也可不调用，用来关闭文件
//[[ProjectLogUploader getInstance] stop];

//appkey去这里申请http://rddss.intra.sina.com.cn/app/auth/index.php具体问王鑫
//登录后->应用中心->sina api->api调用->申请app_key.之后找王鑫再开授权就时这样。have fun!

#import <Foundation/Foundation.h>

@interface ProjectLogUploader : NSObject

+ (id)getInstance;
@property(nonatomic,retain)NSString* appKey;
-(BOOL)writeDataString:(NSString*)dataString;
-(void)startup;
-(void)stop;
-(void)refreshSID;

@end

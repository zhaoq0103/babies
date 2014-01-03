//
//  BCNavigationController.h
//  SinaNews
//
//  Created by shieh exbice on 11-11-4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
@interface UINavigationBar (UINavigationBarCategory) 

@property(nonatomic,retain)UIImage* backgroundImage;

@end
 */

@interface BCNavigationController : UINavigationController
{
@private 
    UIImage* tabBarImage;
    UIImage* tabBarHighlyImage;
    NSString* tabBarTitle;
    UIColor* tabBarTitleColor;
    UIColor* tabBarTitleHighlyColor;
    
    UIImage* bubbleImage;
}

@property(nonatomic,retain)UIImage* tabBarImage;
@property(nonatomic,retain)UIImage* tabBarHighlyImage;
@property(nonatomic,retain)NSString* tabBarTitle;
@property(nonatomic,retain)UIColor* tabBarTitleColor;
@property(nonatomic,retain)UIColor* tabBarTitleHighlyColor;

@property(nonatomic,retain)UIImage* bubbleImage;

@end

//
//  UserModel.h
//
//  Created by pro on 13-6-5.
//  Copyright (c) 2013年 liaohy. All rights reserved.
//

//PAGE
/*
 id             int         page id
 title          string      page title
 summary        string      概要
 text           string      详情
 
 sections       NSArray     
 */

//SECTION
/*
 id             int         section id
 title          string      section title
 summary        string      概要
 text           string      详情
 pic            string      图片
 picurl         string      图片地址
 tags           NSArray     ?
 */

//TAG
/*
 id             int         tag id
 title          string      tag title
 
 text           string(or NSArray)     ?
 */

//TAGtextContent if text is array
/*
 content        string         title
 url            string         url or text content
 */

#import "BaseModel.h"

@interface UserModel : BaseModel

@property(nonatomic,copy)NSString * profile_image_url;  //用户头像地址，50×50像素
@property(nonatomic,copy)NSString * avatar_large;  //用户大头像地址
@property(nonatomic,copy)NSString * gender;             //性别，m：男、f：女、n：未知
@property(nonatomic,retain)NSNumber * followers_count;    //粉丝数

@end

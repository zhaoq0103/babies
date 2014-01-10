//
//  UserModel.m
//
//  Created by pro on 13-6-5.
//  Copyright (c) 2013年 liaohy. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel


- (NSDictionary *)attributeMapDictionary {
    NSDictionary *mapAtt = @{
                             @"idstr":@"created_at",
                             @"screen_name":@"screen_name",
                             @"name":@"name",
                             @"location":@"location",
                             @"description":@"description",
                             @"url":@"url",
                             @"profile_image_url":@"profile_image_url",
                             @"avatar_large":@"avatar_large",
                             @"gender":@"gender",
                             @"followers_count":@"followers_count",
                             @"friends_count":@"friends_count",
                             @"statuses_count":@"statuses_count",
                             @"favourites_count":@"favourites_count",
                             @"verified":@"verified",
                             @"online_status":@"online_status"
                             };
    
    return mapAtt;
}

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    
//    NSDictionary *retweetDic = [dataDic objectForKey:@"retweeted_status"];
//    if (retweetDic != nil) {
//        WeiboModel *relWeibo = [[WeiboModel alloc] initWithDataDic:retweetDic];
//        self.relWeibo = relWeibo;
//        [relWeibo release];
//    }
//    
//    NSDictionary *userDic = [dataDic objectForKey:@"user"];
//    if (userDic != nil) {
//        UserModel *user = [[UserModel alloc] initWithDataDic:userDic];
//        self.user = user;
//        [user release];
//    }
}

@end

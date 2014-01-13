//
//  UserModel.m
//
//  Created by pro on 13-6-5.
//  Copyright (c) 2013年 liaohy. All rights reserved.
//

#import "TaskModel.h"

@implementation TaskModel

- (NSDictionary *)attributeMapDictionary {
    NSDictionary *mapAtt = @{
                             @"weekID":@"week",
                             };
    
    return mapAtt;
}

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    NSArray *secArray = [dataDic objectForKey:@"weektask"];
    if (secArray != nil && [secArray isKindOfClass:[NSArray class]] && secArray.count > 0) {
        self.tasksData = [[NSMutableArray alloc] initWithCapacity:secArray.count];
        for (NSDictionary* secDic in secArray) {
            TaskDetailModel* secModel = [[TaskDetailModel alloc] initWithDataDic:secDic];
            [_tasksData addObject:secModel];
            [secModel release];
        }
    }
}

- (void)dealloc
{
    OCSafeRelease(_weekID);
    OCSafeRelease(_tasksData);
    
    [super dealloc];
}

@end


//task detail
@implementation TaskDetailModel

- (NSDictionary *)attributeMapDictionary {
    NSDictionary *mapAtt = @{
                             @"name":@"name",
                             @"detail":@"detail",
                             };
    
    return mapAtt;
}

- (void)dealloc
{
    OCSafeRelease(_name);
    OCSafeRelease(_detail);
    
    [super dealloc];
}
@end
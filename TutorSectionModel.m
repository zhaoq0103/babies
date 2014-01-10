//
//  ExpertModel.m
//  babyfaq
//
//  Created by PRO on 13-6-8.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "TutorSectionModel.h"

@implementation TutorSectionModel

- (NSDictionary *)attributeMapDictionary {
    NSDictionary *mapAtt = @{
                             @"title":@"title",
                             @"summary":@"summary",
                             @"text":@"text",
                             @"pageID":@"id",
                             };
    
    return mapAtt;
}

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    
    NSArray *secArray = [dataDic objectForKey:@"section"];
    if (secArray != nil && [secArray isKindOfClass:[NSArray class]] && secArray.count > 0) {
        self.sectionsData = [[NSMutableArray alloc] initWithCapacity:secArray.count];
        for (NSDictionary* secDic in secArray) {
            SectionModel* secModel = [[SectionModel alloc] initWithDataDic:secDic];
            [_sectionsData addObject:secModel];
            [secModel release];
        }
    }
}

- (void)dealloc
{
    self.title = nil;
    self.summary = nil;
    self.text = nil;
    self.pageID = nil;
    
    self.sectionsData = nil;
    self.taskModel = nil;
    
    [super dealloc];
}

@end



@implementation SectionModel

- (NSDictionary *)attributeMapDictionary {
    NSDictionary *mapAtt = @{
                             @"title":@"title",
                             @"summary":@"summary",
                             @"text":@"text",
                             @"pic":@"pic",
                             @"picurl":@"picurl",
                             @"sectionID":@"id",
                             };
    
    return mapAtt;
}

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    

    NSArray *tagArray = [dataDic objectForKey:@"tag"];
    if (tagArray != nil && [tagArray isKindOfClass:[NSArray class]] && tagArray.count > 0) {
        self.tagsData = [[NSMutableArray alloc] initWithCapacity:tagArray.count];
        for (NSDictionary* tagDic in tagArray) {
            TagModel* tagM = [[TagModel alloc] initWithDataDic:tagDic];
            [_tagsData addObject:tagM];
            [tagM release];
        }
    }
}

- (void)dealloc
{
    self.title = nil;
    self.summary = nil;
    self.text = nil;
    self.sectionID = nil;
    
    self.tagsData = nil;
    self.pic = nil;
    self.picurl = nil;
    
    [super dealloc];
}

@end



@implementation TagModel

- (NSDictionary *)attributeMapDictionary {
    NSDictionary *mapAtt = @{
                             @"title":@"title",
                             @"tagID":@"id",
                             };
    
    return mapAtt;
}

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    
    NSArray *tagArray = [dataDic objectForKey:@"text"];
    if (tagArray != nil && [tagArray isKindOfClass:[NSArray class]] && tagArray.count > 0) {
        self.textData = [[NSMutableArray alloc] initWithCapacity:tagArray.count];
        for (NSDictionary* tagDic in tagArray) {
            TagTextModel* tagM = [[TagTextModel alloc] initWithDataDic:tagDic];
            [_textData addObject:tagM];
            [tagM release];
        }
    }
}

- (void)dealloc
{
    self.title = nil;
    self.tagID = nil;
    self.text = nil;
    
    self.textData = nil;
    
    [super dealloc];
}

@end




@implementation TagTextModel

- (NSDictionary *)attributeMapDictionary {
    NSDictionary *mapAtt = @{
                             @"content":@"content",
                             @"url":@"url",
                             };
    
    return mapAtt;
}

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
}

- (void)dealloc
{
    self.content = nil;
    self.url = nil;
    
    [super dealloc];
}
@end


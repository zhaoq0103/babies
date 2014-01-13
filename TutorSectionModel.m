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
        NSMutableArray* temp = [[NSMutableArray alloc] initWithCapacity:secArray.count];
        self.sectionsData = temp;
        [temp release];
        for (NSDictionary* secDic in secArray) {
            SectionModel* secModel = [[SectionModel alloc] initWithDataDic:secDic];
            [_sectionsData addObject:secModel];
            [secModel release];
        }
    }
}

- (void)dealloc
{
    OCSafeRelease(_title);
    OCSafeRelease(_summary);
    OCSafeRelease(_text);
    OCSafeRelease(_pageID);
    OCSafeRelease(_sectionsData);
    OCSafeRelease(_taskModel);
    
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
    OCSafeRelease(_title);
    OCSafeRelease(_summary);
    OCSafeRelease(_text);
    OCSafeRelease(_sectionID);
    OCSafeRelease(_tagsData);
    OCSafeRelease(_pic);
    OCSafeRelease(_picurl);
    
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
    OCSafeRelease(_title);
    OCSafeRelease(_text);
    OCSafeRelease(_tagID);
    OCSafeRelease(_textData);
    
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
    OCSafeRelease(_content);
    OCSafeRelease(_url);
    
    [super dealloc];
}
@end


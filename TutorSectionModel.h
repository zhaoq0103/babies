//
//  ExpertModel.h
//  babyfaq
//
//  Created by PRO on 13-6-8.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "BaseModel.h"
#import "TaskModel.h"

//page
@interface TutorSectionModel : BaseModel

@property(nonatomic,copy)NSString           * title;      
@property(nonatomic,copy)NSString           * summary;  
@property(nonatomic,copy)NSString           * text;
@property(nonatomic,retain)NSNumber         * pageID;

@property (retain, nonatomic) NSMutableArray                    *sectionsData;
@property(nonatomic,retain)TaskModel*                           taskModel;

@end


//section
@interface SectionModel : BaseModel

@property(nonatomic,copy)NSString           * title;
@property(nonatomic,copy)NSString           * summary;
@property(nonatomic,copy)NSString           * text;
@property(nonatomic,copy)NSString           * pic;
@property(nonatomic,copy)NSString           * picurl;
@property(nonatomic,retain)NSNumber         * sectionID;

@property (retain, nonatomic) NSMutableArray                    *tagsData;

@end

//tag
@interface TagModel : BaseModel

@property(nonatomic,copy)NSString           * title;
@property(nonatomic,retain)NSNumber         * tagID;
@property(nonatomic,retain)NSNumber         * text;

@property (retain, nonatomic) NSMutableArray                    *textData;

@end

//tag text
@interface TagTextModel : BaseModel

@property(nonatomic,copy)NSString           * content;
@property(nonatomic,copy)NSString           * url;

@end

//
//  DataModel.m
//  SinaNews
//
//  Created by shieh exbice on 11-7-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DataModel.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJSON.h"
#import "defines.h"
#import "CommentDataList.h"

NSString* DataModel_Seperate = @"|>";

NSString* DataModel_Images = @"images";
NSString* DataModel_TypeKey = @"TypeKey{}";



@implementation ImageURLData

@synthesize imageURL=_imageURL,imageSize=_imageSize,imageTitle=_imageTitle,image=_image;

-(id)init
{
    self = [super init];
    _imageSize = CGSizeZero;
    
    return self;
}

-(void)dealloc
{
    [_image release];
    [_imageTitle release];
    [_imageURL release];
    
    [super dealloc];
}

@end

@interface DataModel ()

@property(retain)NSDictionary* newsData;
@property(retain)NSMutableDictionary* userInfo;

@end

@implementation DataModel

@synthesize newsData = mNewsData;
@synthesize newsType = mNewsType;
@synthesize userInfo=mUserInfo;
@synthesize dataString;
@synthesize data;
@synthesize parentList;
@synthesize IDListInParentList;
@synthesize rowInParentList;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        mNewsType = DataModelType_News;
    }
    
    return self;
}

-(void)dealloc
{
    [mNewsData release];
    [mUserInfo release];
    [IDListInParentList release];
    
    [super dealloc];
}

+(DataModel*)objectWithJsonDict:(NSDictionary*)aJson
{
    DataModel* rtval = nil;
    if (aJson&&[aJson isKindOfClass:[NSDictionary class]]) {
        rtval = [[[DataModel alloc] init] autorelease];
        rtval.newsData = aJson;
    }
    return rtval;
}

+(DataModel*)objectWithJsonString:(NSString*)aJson
{
    DataModel* rtval = nil;
    NSDictionary* dict = [aJson JSONValue];
    if (dict&&[dict isKindOfClass:[NSDictionary class]]) {
        rtval = [[[DataModel alloc] init] autorelease];
        rtval.newsData = dict;
    }
    return rtval;
}

-(id)initWithCoder: (NSCoder *) decoder
{
    if (self=[super init]) {
        mNewsData = [[decoder decodeObjectForKey:@"data"] retain];
        mNewsType = [decoder decodeIntForKey:@"type"];
        mUserInfo = [[decoder decodeObjectForKey:@"userinfo"] retain];
    }
    return self;
}

-(void)encodeWithCoder: (NSCoder*)encoder
{
    if (self.newsData) {
        [encoder encodeObject:self.newsData forKey:@"data"];
    }
	[encoder encodeInt:self.newsType forKey:@"type"];
    if (self.userInfo) {
        [encoder encodeObject:self.userInfo forKey:@"userinfo"];
    }
}

-(id)initWithDataModel:(DataModel*)object
{
    self = [super init];
    if (self) {
        self.newsData = object.newsData;
    }
    return self;
}

-(id)initWithJsonDictionary:(NSDictionary*)aJson
{
    self = [super init];
    if (self) {
        if (aJson && [aJson isKindOfClass:[NSDictionary class]]) {
             mNewsData = aJson;
            [mNewsData retain];
        }
    }
    return self;
}

-(id)initWithNewsData:(NSData*)aData
{
    self = [super init];
    if (self) {
        if (aData&&[aData isKindOfClass:[NSData class]]) {
            NSString* tempString = [[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding];
            NSDictionary* dict = [tempString JSONValue];
            if (dict&&[dict isKindOfClass:[NSDictionary class]]) {
                mNewsData = dict;
                [mNewsData retain];
            }
            [tempString release];
        }
    }
    return self;
}

-(id)initWithJsonString:(NSString*)aJson
{
    self = [super init];
    if(self){
        NSDictionary* dict = [aJson JSONValue];
        if(dict&&[dict isKindOfClass:[NSDictionary class]]){
            mNewsData = dict;
            [mNewsData retain];
        }
    }
    return self;
}

-(NSString*)dataString
{
    NSString* rtval = nil;
    rtval = [mNewsData JSONRepresentation];
    return rtval;
}

-(NSString*)valueForKey:(NSString*)newsKey
{
    NSString* rtval = nil;
    if (newsKey) {
        NSArray* keysArray = [newsKey componentsSeparatedByString:DataModel_Seperate];
        id parentDict = mNewsData;
       
        for (int i=0; i<[keysArray count]; i++) {
            NSString* key = [keysArray objectAtIndex:i];
            id ret = nil;
            if ([parentDict isKindOfClass:[NSDictionary class]]) {
                NSDictionary* dict = (NSDictionary*)parentDict;
                ret = [dict objectForKey:key];
            }
            else if ([parentDict isKindOfClass:[NSArray class]]) {
                NSArray* array = (NSArray*)parentDict;
                int keyInt = [key intValue];
                if ([array count]>keyInt) {
                    ret = [array objectAtIndex:keyInt];
                }
            }
            
            if ([ret isKindOfClass:[NSString class]]) {
                rtval = (NSString*)ret;
                break;
            }
            else
            {
                parentDict = ret;
            }
            if (i==[keysArray count]-1) {
                rtval = ret;
            }
        }
        
    }
    if ([rtval isKindOfClass:[NSNumber class]]) {
        rtval = [(NSNumber*)rtval stringValue];
    }
    return rtval;
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    if ([self.newsData isKindOfClass:[NSMutableDictionary class]]) {
        NSMutableDictionary* customData = (NSMutableDictionary*)self.newsData;
        [customData setValue:value forKey:key];
    }
}

-(NSArray*)imageURLDataList
{
    NSMutableArray* rtval = [NSMutableArray arrayWithCapacity:0];
    NSArray* images = [mNewsData objectForKey:DataModel_Images];
    if (images) {
        for (NSDictionary* imageDict in images) {
            ImageURLData* urlData = [[ImageURLData alloc] init];
            urlData.imageURL = [imageDict objectForKey:@"url"];
            urlData.imageTitle = [imageDict objectForKey:@"title"];
            NSNumber* width = (NSNumber*)[imageDict objectForKey:@"width"];
            NSNumber* height = (NSNumber*)[imageDict objectForKey:@"height"];
            if (width&&height) {
                if (isRetina) {
                    urlData.imageSize = CGSizeMake([width intValue]/2, [height intValue]/2);
                }
                else
                {
                    urlData.imageSize = CGSizeMake([width intValue], [height intValue]);
                }
            }
            [rtval addObject:urlData];
            [urlData release];
        }
    }
    
    if ([rtval count]>0) {
        return rtval;
    }
    else
    {
        return nil;
    }
}

-(void)setUserInfoValue:(id)value forKey:(NSString *)key
{
    if (!mUserInfo) {
        mUserInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    [self.userInfo setValue:value forKey:key];
}

-(id)userInfoValueForKey:(NSString*)newsKey
{
    return [self.userInfo valueForKey:newsKey];
}

-(NSData*)data
{
    NSData* rtval = nil;
    NSString* dataStr = [mNewsData JSONRepresentation];
    rtval = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    return rtval;
    
}
-(NSDictionary*)dataDict
{
    return self.newsData;
}
-(void)refreshToDataBase
{
    [self.parentList refreshDataBaseWithOneCommnetContent:self dataIDList:self.IDListInParentList row:self.rowInParentList];
}

@end

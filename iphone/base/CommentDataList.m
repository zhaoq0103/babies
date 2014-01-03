//
//  CommentDataList.m
//  SinaNews
//
//  Created by shieh exbice on 11-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CommentDataList.h"
#import "NSString+SBJSON.h"
//#import "MyTool.h"
#import "DataBaseSaver.h"
#import "RegValueSaver.h"
#import "NSData+base64.h"

enum NameListType
{
    NameListType_queue,
    NameListType_nest,
    NameListType_unKnown
};

NSString* CommentDataList_DataKey = @"data";
NSString* CommentDataList_ReplaceString = @"~{}";

@implementation AdjustOrderData

@synthesize type,key,value,movable,subArray;

-(id)init
{
    self = [super init];
    type = AdjustOrderType_abled;
    movable = YES;
    return self;
}

-(void)dealloc
{
    [key release];
    [value release];
    [subArray release];
    
    [super dealloc];
}

-(id)initWithCoder: (NSCoder *) decoder
{
    if (self=[super init]) {
        type = [decoder decodeIntForKey:@"type"];
        movable = [decoder decodeBoolForKey:@"movable"];
        key = [[decoder decodeObjectForKey:@"key"] retain];
        value = [[decoder decodeObjectForKey:@"value"] retain];
        subArray = [[decoder decodeObjectForKey:@"subArray"] retain];
    }
    return self;
}

-(void)encodeWithCoder: (NSCoder*)encoder
{
    if (self.key) {
        [encoder encodeObject:self.key forKey:@"key"];
    }
    if (self.value) {
        [encoder encodeObject:self.value forKey:@"value"];
    }
    if (self.subArray) {
        [encoder encodeObject:self.value forKey:@"subArray"];
    }
	[encoder encodeInt:self.type forKey:@"type"];
    [encoder encodeBool:self.movable forKey:@"movable"];
}

+(AdjustOrderData*)dataWithData:(NSData*)savableData
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:savableData];
}

-(NSData*)savableData
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

@end


@interface CommentDataList()
@property(retain)NSMutableArray* cellObjects;
@property(retain)NSMutableArray* showedObjects;
@property(retain)NSLock* lock;
@property(retain)NSLock* showedLock;
@property(retain)NSLock* nameLock;
@property(retain)NSLock* dataBaseLock;
@property(retain)NSLock* orderLock;


@property(retain)NSString* fileName;
@property(retain)NSArray* nameList;
@property(assign)NSInteger nameListType;
@property(assign)NSInteger idListCount;
@property(retain)NSMutableArray* loadedList;
@property(retain)NSMutableDictionary* listInfo;
@property(retain)NSMutableArray* showableOrderArray;
@property(retain)NSMutableArray* totalOrderArray;
@property(retain)NSMutableArray* reloadedIDArray;
@property(retain)NSLock* reloadedLock;


-(void)initNameList;
-(void)initOrderArray;
-(void)initAllObjects;
-(void)checkNameListType;
-(NSArray*)subCommentNamelistWithQueueTypeAtRowColumns:(NSArray*)rowColumns;
-(NSArray*)curCommentAPICodeWithQueueTypeAtRowColumns:(NSArray*)rowColumns;
-(NSArray*)subNewsNameListWithNestTypeAtRowColumns:(NSArray*)rowColumns;
-(NSArray*)curCommentAPICodeWithNestTypeAtRowColumns:(NSArray*)rowColumns;
-(NSArray*)sourceListWithOrderedList:(NSArray*)orderedArray;
-(NSArray*)orderedListWithSourceList:(NSArray*)sourceArray;
-(NSMutableDictionary*)findContentsDataDictWithObjects:(NSMutableArray*)objects IDList:(NSArray*)IDList;
-(void)addCommnetContents:(NSArray*)objects IDList:(NSArray*)IDList refresh:(BOOL)bRefresh;
-(BOOL)hasLoadedWithIDList:(NSArray*)IDList;
-(void)reloadDataFromDataBaseWithDataIDList:(NSArray*)dataIDList sourceID:(NSArray*)sourceIDList;
-(void)addReloadedIDList:(NSArray*)IDList;
-(void)removeReloadedIDList:(NSArray*)IDList;
@end

@implementation CommentDataList
@synthesize nameList = mNameList;
@synthesize cellObjects=mCellObjects,showedObjects=mShowedObjects;
@synthesize lock=mLock;
@synthesize showedLock=mShowedLock;
@synthesize idListCount;
@synthesize nameListType;
@synthesize fileName;
@synthesize dataTableName=mDataTableName;
@synthesize loadedList=mLoadedList;
@synthesize nameLock=mNameLock;
@synthesize orderLock=mOrderLock;
@synthesize listInfo=mListInfo;
@synthesize dataBaseLock=mDataBaseLock;
@synthesize showableOrderArray=mShowableOrderArray;
@synthesize totalOrderArray=mTotalOrderArray;
@synthesize countPerPage;
@synthesize reloadedIDArray,reloadedLock;

+(NSArray*)convertStringToNumber:(NSArray*)array createNewArray:(BOOL)created
{
    NSMutableArray* rtval = nil;
    for (int i=0; i<[array count]; i++) {
        id obj = [array objectAtIndex:i];
        NSNumber* oneObject;
        if ([obj isKindOfClass:[NSString class]]) {
            oneObject = [NSNumber numberWithInt:[((NSString*)obj) intValue]];
        }
        else if(i==0)
        {
            oneObject = (NSNumber*)obj;
            break;
        }
        if (!rtval) {
            rtval = [NSMutableArray arrayWithCapacity:0];
        }
        [rtval addObject:oneObject];
    }
    if (!rtval) {
        if (created) {
            rtval = [NSMutableArray arrayWithArray:array];
            return rtval;
        }
        else
            return array;
    }
    else
    {
        return rtval;
    }
}

+(NSArray*)convertNumberToString:(NSArray*)array createNewArray:(BOOL)created
{
    NSMutableArray* rtval = nil;
    for (int i=0; i<[array count]; i++)
    {
        id obj = [array objectAtIndex:i];
        NSString* oneObject = nil;
        if ([obj isKindOfClass:[NSNumber class]]) 
        {
            oneObject = [(NSNumber*)obj stringValue];
        }
        else if(i==0)
        {
            oneObject = (NSString*)obj;
            break;
        }
        if (!rtval) {
            rtval = [NSMutableArray arrayWithCapacity:0];
        }
        [rtval addObject:oneObject];
    }
    if (!rtval) {
        if (created) {
            rtval = [NSMutableArray arrayWithArray:array];
            return rtval;
        }
        else
            return array;
    }
    else
    {
        return rtval;
    }
}

+(BOOL)checkNumberArrayEqualWithFirstArray:(NSArray*)first secondArray:(NSArray*)second
{
    BOOL rtval = YES;
    if (first&&second&&[first count]==[second count]) {
        first = [self convertNumberToString:first createNewArray:NO];
        second = [self convertNumberToString:second createNewArray:NO];
        for (int i=0; i<[first count]; i++) {
            NSString* oneOfFirst = [first objectAtIndex:i];
            NSString* oneOfSecond = [second objectAtIndex:i];
            if (![oneOfFirst isEqualToString:oneOfSecond]) {
                rtval = NO;
                break;
            }
        }
    }
    else
    {
        rtval = NO;
    }
    
    return rtval;
}

-(id)init
{
    self = [super init];
    if (self) {
        mLock = [[NSLock alloc] init];
        mShowedLock = [[NSLock alloc] init];
        mDataBaseLock = [[NSLock alloc] init];
        mNameLock = [[NSLock alloc] init];
        mOrderLock = [[NSLock alloc] init];
        countPerPage = 20;
    }
    return self;
}

-(id)initWithFileName:(NSString*)aFileName
{
    self = [super init];
    if (self) {
        mLock = [[NSLock alloc] init];
        mShowedLock = [[NSLock alloc] init];
        //mNameLock = [[NSLock alloc] init];
        mOrderLock = [[NSLock alloc] init];
        fileName = aFileName;
        [fileName retain];
        [self initNameList];
        mDataTableName = [(NSArray*)[aFileName componentsSeparatedByString:@"."] objectAtIndex:0];
        [mDataTableName retain];
        [self initOrderArray];
        countPerPage = 20;
    }
    return self;
}

-(id)initWithJsonString:(NSString*)jsonString
{
    self = [super init];
    if (self) {
        mLock = [[NSLock alloc] init];
        mShowedLock = [[NSLock alloc] init];
        //mNameLock = [[NSLock alloc] init];
        mOrderLock = [[NSLock alloc] init];
        NSArray* commentArray = [jsonString JSONValue];
        self.nameList = commentArray;
        [self checkNameListType];
        [self initOrderArray];
        countPerPage = 20;
    }
    return self;
}

-(id)initWithJsonArray:(NSArray*)jsonArray
{
    self = [super init];
    if (self) {
        mLock = [[NSLock alloc] init];
        mShowedLock = [[NSLock alloc] init];
        //mNameLock = [[NSLock alloc] init];
        mOrderLock = [[NSLock alloc] init];
        self.nameList = jsonArray;
        [self checkNameListType];
        [self initOrderArray];
        countPerPage = 20;
    }
    return self;
}

-(void)dealloc
{
    [mCellObjects release];
    [mLock release];
    [mShowedObjects release];
    [mShowedLock release];
    [mNameList release];
    [mDataBaseLock release];
    [fileName release];
    [mDataTableName release];
    [mLoadedList release];
    [mNameLock release];
    [mListInfo release];
    [mShowableOrderArray release];
    [mTotalOrderArray release];
    [mOrderLock release];
    [reloadedIDArray release];
    [reloadedLock release];
    
    [super dealloc];
}

-(void)initNameList
{
    NSArray* documentPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentPath = [documentPathArray objectAtIndex:0];
    NSString* commentPath = [documentPath stringByAppendingPathComponent:self.fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:commentPath]) {
		NSString* path = [[NSBundle mainBundle] bundlePath];
        commentPath = [path stringByAppendingPathComponent:self.fileName];
	}
    
    NSError* error;
    NSString* commentStr = [NSString stringWithContentsOfFile:commentPath encoding:NSUTF8StringEncoding error:&error];
    if (!commentStr) {
        commentStr = [NSString stringWithContentsOfFile:commentPath encoding:NSUnicodeStringEncoding error:&error];
    }
    NSArray* commentArray = [commentStr JSONValue];
    
    /*
    NSData* data = [commentStr dataUsingEncoding:NSUTF8StringEncoding];
    [MyTool writeToDocument:data folder:@"test" fileName:@"comment.json"];
    */
     
    self.nameList = commentArray;
    [self checkNameListType];
}

-(void)checkNameListType
{
    [self.nameLock lock];
    self.nameListType = NameListType_unKnown;
    hasFirstIndex = NO;
    orderLayer = 0;
    if ([self.nameList isKindOfClass:[NSArray class]]&&[self.nameList count]>0) {
        if ([self.nameList count]>1) {
            hasFirstIndex = YES;
        }
        NSDictionary* dict = [self.nameList lastObject];
        NSArray* contentArray = [dict objectForKey:CommentDataList_DataKey];
        if (contentArray&&[contentArray isKindOfClass:[NSArray class]]&&[contentArray count]>0) {
            NSArray* firstDict = [contentArray objectAtIndex:0];
            if([firstDict isKindOfClass:[NSArray class]])
            {
                self.nameListType = NameListType_queue;
            }
            else if([firstDict isKindOfClass:[NSDictionary class]])
            {
                self.nameListType = NameListType_nest;
            }
            if (self.nameListType==NameListType_nest)
            {
                while ([contentArray count]==1) {
                    orderLayer++;
                    NSDictionary* tempDict = [contentArray objectAtIndex:0];
                    contentArray = [tempDict objectForKey:CommentDataList_DataKey];
                }
                if (!contentArray) {
                    orderLayer = 0;
                }
            }
            else if(self.nameListType==NameListType_queue)
            {
                for (int i=0; i<[contentArray count]; i++) {
                    NSArray* layerArray = [contentArray objectAtIndex:i];
                    if ([layerArray count]>1) {
                        break;
                    }
                    else if (!layerArray||[layerArray count]==0) {
                        orderLayer--;
                        break;
                    }
                    else
                    {
                        if (i<[contentArray count]-1) {
                            orderLayer++;
                        }
                    }
                }
            }
            
        }
    }
    [self.nameLock unlock];
}

-(void)initOrderArray
{
    if (!mTotalOrderArray) {
        mTotalOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
        int nameListCount = [self.nameList count];
        for (int i=0;i<nameListCount;i++) {
            NSMutableArray* oneArray = [[NSMutableArray alloc] initWithCapacity:0];
            [mTotalOrderArray addObject:oneArray];
            [oneArray release];
            NSDictionary* dict = [self.nameList objectAtIndex:i];
            NSArray* contentArray = [dict objectForKey:CommentDataList_DataKey];
            if (self.nameListType==NameListType_queue) {
                NSArray* firstArray = [contentArray objectAtIndex:orderLayer];
                
                for (int j=0; j<[firstArray count]; j++) {
                    AdjustOrderData* orderData = [[AdjustOrderData alloc] init];
                    orderData.key = [(NSDictionary*)[firstArray objectAtIndex:j] valueForKey:@"datavalue"];
                    orderData.value = [(NSDictionary*)[firstArray objectAtIndex:j] valueForKey:@"dataname"];
                    [oneArray addObject:orderData];
                    [orderData release];
                }
            }
            else if(self.nameListType==NameListType_nest)
            {
                NSArray* firstArray = contentArray;
                int tempOrderLayer = orderLayer;
                while (tempOrderLayer!=0) {
                    NSDictionary* tempDict = [firstArray objectAtIndex:0];
                    firstArray = [tempDict objectForKey:CommentDataList_DataKey];
                    tempOrderLayer--;
                }
                for (int j=0; j<[firstArray count]; j++) {
                    AdjustOrderData* orderData = [[AdjustOrderData alloc] init];
                    orderData.key = [(NSDictionary*)[firstArray objectAtIndex:j] valueForKey:@"datavalue"];
                    orderData.value = [(NSDictionary*)[firstArray objectAtIndex:j] valueForKey:@"dataname"];
                    [oneArray addObject:orderData];
                    [orderData release];
                }
            }
        }
    }
    [self.orderLock lock];
    if (!mShowableOrderArray) {
        mShowableOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i=0; i<[self.nameList count]; i++) {
            NSArray* oldTotalOrderArray = [self.totalOrderArray objectAtIndex:i];
            NSDictionary* typeDict = [self.nameList objectAtIndex:i];
            NSString* typeString = [typeDict objectForKey:@"type"];
            NSData* orderData = [[RegValueSaver getInstance] readSystemInfoForKey:[NSString stringWithFormat:@"order_%@_%@",self.dataTableName,typeString]];
            NSArray* orderArrayList = nil;
            if (orderData) {
                orderArrayList = [NSKeyedUnarchiver unarchiveObjectWithData:orderData];
            }
            if (orderArrayList) {
                NSMutableArray* newOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableArray* dealedArray = [[NSMutableArray alloc] initWithCapacity:0];
                NSArray* contentArray = orderArrayList;
                for (int k=0; k<[contentArray count]; k++) {
                    AdjustOrderData* adjustData = [contentArray objectAtIndex:k];
                    for (int m=0; m<[oldTotalOrderArray count]; m++) {
                        AdjustOrderData* adjustData_Total = [oldTotalOrderArray objectAtIndex:m];
                        if([adjustData_Total.key isEqualToString:adjustData.key])
                        {
                            if (adjustData.type==AdjustOrderType_abled) 
                            {
                                [newOrderArray addObject:[NSNumber numberWithInt:m]]; 
                            }
                            [dealedArray addObject:[NSNumber numberWithInt:m]];
                            break;
                        }
                    }
                }
                for (int k=0; k<[oldTotalOrderArray count]; k++) {
                    BOOL hasFound = NO;
                    for (int m=0; m<[dealedArray count]; m++) {
                        NSNumber* dealedNumber= [dealedArray objectAtIndex:m];
                        if ([dealedNumber intValue]==k) {
                            hasFound = YES;
                            break;
                        }
                    }
                    if (!hasFound) {
                        [newOrderArray addObject:[NSNumber numberWithInt:k]]; 
                    }
                }
                
                [mShowableOrderArray addObject:newOrderArray];
                [newOrderArray release];
                [dealedArray release];
            }
            else
            {
                NSMutableArray* newOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
                NSArray* contentArray = oldTotalOrderArray;
                for (int k=0; k<[contentArray count]; k++) {
                    [newOrderArray addObject:[NSNumber numberWithInt:k]];
                }
                [mShowableOrderArray addObject:newOrderArray];
                [newOrderArray release];
            }
        }
    }
    [self.orderLock unlock];
}

-(void)checkoutOneOrderWithOrderArray:(NSArray*)orderArray inList:(NSArray*)dataList
{
    
}

-(void)replaceNameListWithTypeIndex:(NSInteger)index DataArray:(NSArray*)dataArray
{
    [self.nameLock lock];
    if ([self.nameList isKindOfClass:[NSArray class]]&&[self.nameList count]>index) {
        if (dataArray) {
            NSDictionary* dict = [self.nameList objectAtIndex:index];
            [dict setValue:dataArray forKey:CommentDataList_DataKey];
        }
    }
    [self.nameLock unlock];
}

-(NSArray*)subCommentNamelistAtRowColumns:(NSArray*)columns
{
    NSArray* rtval = nil;
    columns = [self sourceListWithOrderedList:columns];
    [self.nameLock lock];
    if (self.nameListType==NameListType_queue) {
        rtval = [self subCommentNamelistWithQueueTypeAtRowColumns:columns];
    }
    else if(self.nameListType==NameListType_nest)
    {
        rtval = [self subNewsNameListWithNestTypeAtRowColumns:columns];
    }
    [self.nameLock unlock];
    return rtval;
}

-(NSArray*)curCommentAPICodeAtRowColumns:(NSArray*)columns
{
    NSArray* rtval = nil;
    columns = [self sourceListWithOrderedList:columns];
    [self.nameLock lock];
    if (self.nameListType==NameListType_queue) {
        rtval = [self curCommentAPICodeWithQueueTypeAtRowColumns:columns];
    }
    else if(self.nameListType==NameListType_nest)
    {
        rtval = [self curCommentAPICodeWithNestTypeAtRowColumns:columns];
    }
    [self.nameLock unlock];
    return rtval;
}

-(NSArray*)subCommentNamelistWithQueueTypeAtRowColumns:(NSArray*)rowColumns
{
    NSMutableArray* columns = (NSMutableArray*)[CommentDataList convertStringToNumber:rowColumns createNewArray:YES];
    NSMutableArray* rtval = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary* curDict = nil;
    NSArray* destOrderArray = nil;
    if ([self.nameList count]==1) {
        curDict = [self.nameList lastObject];
        destOrderArray = [self.showableOrderArray objectAtIndex:0];
    }
    else if([self.nameList count]>1)
    {
        if (columns&&[columns count]>0) {
            NSNumber* index = [columns objectAtIndex:0];
            curDict = [self.nameList objectAtIndex:[index intValue]];
            [columns removeObjectAtIndex:0];
            destOrderArray = [self.showableOrderArray objectAtIndex:[index intValue]];
        }
    }
    
    NSArray* channelArray = [curDict objectForKey:CommentDataList_DataKey];
    BOOL orderThisLayer = NO;
    if (!columns||[columns count]==0) {
        if (orderLayer==0) {
            orderThisLayer = YES;
        }
    }
    else if([columns count]==orderLayer)
    {
        orderThisLayer = YES;
    }
    NSArray* destArray = nil;
    if (columns) {
        if ([columns count]<[channelArray count]) {
            destArray = [channelArray objectAtIndex:[columns count]];
        }
    }
    else
    {
        if ([channelArray count]>0) {
            destArray = [channelArray objectAtIndex:0];
        }
    }
    
    if (orderThisLayer) {
        for (NSNumber* orderNumber in destOrderArray) {
            NSDictionary* oneChannel = [destArray objectAtIndex:[orderNumber intValue]];
            NSString* dataName = [oneChannel objectForKey:@"dataname"];
            dataName = dataName ? dataName : @"";
            [rtval addObject:dataName];
        }
    }
    else
    {
        for (NSDictionary* oneChannel in destArray) {
            NSString* dataName = [oneChannel objectForKey:@"dataname"];
            dataName = dataName ? dataName : @"";
            [rtval addObject:dataName];
        }
    }
    
    
    return rtval;
}

-(NSArray*)subNewsNameListWithNestTypeAtRowColumns:(NSArray*)rowColumns
{
    NSMutableArray* columns = (NSMutableArray*)[CommentDataList convertStringToNumber:rowColumns createNewArray:YES];
    NSMutableArray* rtval = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary* curDict = nil;
    NSArray* destOrderArray = nil;
    if ([self.nameList count]==1) {
        curDict = [self.nameList lastObject];
        destOrderArray = [self.showableOrderArray objectAtIndex:0];
    }
    else if([self.nameList count]>1)
    {
        if (columns&&[columns count]>0) {
            NSNumber* index = [columns objectAtIndex:0];
            curDict = [self.nameList objectAtIndex:[index intValue]];
            [columns removeObjectAtIndex:0];
            destOrderArray = [self.showableOrderArray objectAtIndex:[index intValue]];
        }
    }
    
    NSArray* channelArray = [curDict objectForKey:CommentDataList_DataKey];
    
    BOOL orderThisLayer = NO;
    NSArray* destArray = channelArray;
    if (!columns||[columns count]==0) {
        if (orderLayer==0) {
            orderThisLayer = YES;
        }
    }
    else if([columns count]==orderLayer)
    {
        orderThisLayer = YES;
    }
    if (columns) {
        for (int i=0;i<[columns count];i++) {
            NSNumber* columnNumber = [columns objectAtIndex:i];
            int column = [columnNumber intValue];
            if (destArray&&column<[destArray count]) {
                NSDictionary* oneValue = [destArray objectAtIndex:column];
                destArray = [oneValue objectForKey:CommentDataList_DataKey];
            }
            else
            {
                destArray = nil;
                break;
            }
        }
    }
    
    if (orderThisLayer) {
        for (NSNumber* orderNumber in destOrderArray) {
            NSDictionary* oneChannel = [destArray objectAtIndex:[orderNumber intValue]];
            NSString* dataName = [oneChannel objectForKey:@"dataname"];
            dataName = dataName ? dataName : @"";
            [rtval addObject:dataName];
        }
    }
    else
    {
        for (int i=0;i<[destArray count];i++) {
            
            NSDictionary* oneChannel = [destArray objectAtIndex:i];
            NSString* dataName = [oneChannel objectForKey:@"dataname"];
            dataName = dataName ? dataName : @"";
            [rtval addObject:dataName];
        }
    }
    
    
    return rtval;
}

-(NSString*)otherParamFromDict:(NSDictionary*)paramDict sourceParam:(NSString*)sourceParam
{
    NSString* otherParam = sourceParam;
    if (!otherParam) {
        otherParam = @"";
    }
    if (paramDict) {
        NSArray* paramKeys = [paramDict allKeys];
        for (NSString* oneKey in paramKeys) {
            NSString* oneValue = [paramDict objectForKey:oneKey];
            if (oneKey&&oneValue) {
                oneValue = [oneValue rawUrlEncode];
                if (![oneKey isEqualToString:@""]&&![oneValue isEqualToString:@""]) {
                    if (![otherParam isEqualToString:@""]) {
                        otherParam = [otherParam stringByAppendingFormat:@"&%@=%@",oneKey,oneValue];
                    }
                    else
                    {
                        otherParam = [otherParam stringByAppendingFormat:@"%@=%@",oneKey,oneValue];
                    }
                    
                }
                else if(![oneKey isEqualToString:@""])
                {
                    if (![otherParam isEqualToString:@""])
                    {
                        otherParam = [otherParam stringByAppendingFormat:@"&%@",oneKey];
                    }
                    else
                    {
                        otherParam = [otherParam stringByAppendingFormat:@"%@",oneKey];
                    }
                    
                }
            }
        }
    }
    return otherParam;
}
-(NSArray*)curCommentAPICodeAtRowColumnsForMv:(NSArray*)IDList
{
    [self.nameLock lock];
    
    NSMutableArray* rtval = [NSMutableArray arrayWithCapacity:0];
    NSString* otherParam = @"";
    NSString* totalAPI = @"";
    
    NSDictionary* typeDict = [self.nameList lastObject];
    NSArray* channelArray = nil;
    if (typeDict) 
    {
        totalAPI = [totalAPI stringByAppendingString:[typeDict objectForKey:@"api"]];
        NSDictionary* paramDict = [typeDict objectForKey:@"otherparam"];
        otherParam = [self otherParamFromDict:paramDict sourceParam:otherParam];
        channelArray = [typeDict objectForKey:CommentDataList_DataKey];
    }
    
    NSInteger areaindex = [[IDList objectAtIndex:1] intValue];
    NSInteger styleindex = [[IDList objectAtIndex:2] intValue];
    
    if(areaindex < 100 || styleindex < 100)
    {
        NSDictionary* dict = [channelArray objectAtIndex:0];
        if(dict)
        {
            if(areaindex < 100)
            {
                /*
                NSArray* keys = [dict allKeys];
                NSString* columName = [keys objectAtIndex:areaindex];
            
                NSString* ereaselected = [dict objectForKey:columName];
                 */
                NSString* ereaselected = nil;
                switch (areaindex) {
                    case 0:
                        ereaselected = [NSString stringWithFormat:@"ar_cn/"];
                        break;
                        
                    case 1:
                        ereaselected = [NSString stringWithFormat:@"ar_eu/"];
                        break;
                        
                    case 2:
                        ereaselected = [NSString stringWithFormat:@"ar_jk/"];
                        break;
                        
                    default:
                        ereaselected = [NSString stringWithFormat:@"ar_other/"];
                        break;
                }
                totalAPI = [totalAPI stringByAppendingString:ereaselected];
            }
        }
        dict = nil;
        dict = [channelArray objectAtIndex:1];
        if(dict)
        {
            if(styleindex < 100)
            {
                /*
                NSArray* keys = [dict allKeys];
                NSString* columName = [keys objectAtIndex:styleindex];
            
                NSString* styleselected = [dict objectForKey:columName];
                 */
                NSString* styleselected = nil;
                switch (styleindex) {
                    case 0:
                        styleselected = [NSString stringWithFormat:@"ty_M/"];
                        break;
                        
                    case 1:
                        styleselected = [NSString stringWithFormat:@"ty_F/"];
                        break;
                        
                    case 2:
                        styleselected = [NSString stringWithFormat:@"ty_G/"];
                        break;
                        
                    default:
                        break;
                }
                totalAPI = [totalAPI stringByAppendingString:styleselected];
            }
        }

    }
    if (![otherParam isEqualToString:@""]) 
    {
        totalAPI = [totalAPI stringByAppendingFormat:@"?%@",otherParam];
    }
    [rtval addObject:totalAPI];
    [self.nameLock unlock];
    return rtval;
}

-(NSArray*)curCommentAPICodeWithQueueTypeAtRowColumns:(NSArray*)rowColumns
{
    NSMutableArray* columns = (NSMutableArray*)[CommentDataList convertStringToNumber:rowColumns createNewArray:YES];
    NSMutableArray* rtval = [NSMutableArray arrayWithCapacity:0];
    NSString* otherParam = @"";
    NSString* totalAPI = @"";
    
    NSDictionary* typeDict = nil;
    if ([self.nameList count]==1) {
        typeDict = [self.nameList lastObject];
    }
    else if([self.nameList count]>1)
    {
        if (columns&&[columns count]>0) {
            NSNumber* index = [columns objectAtIndex:0];
            typeDict = [self.nameList objectAtIndex:[index intValue]];
            [columns removeObjectAtIndex:0];
        }
    }
    
    NSArray* channelArray = nil;
    if (typeDict) {
        NSString* type = [typeDict objectForKey:@"type"];
        [rtval addObject:type];
        [rtval addObject:[typeDict objectForKey:@"api"]];
        totalAPI = [totalAPI stringByAppendingString:[typeDict objectForKey:@"api"]];
        NSDictionary* paramDict = [typeDict objectForKey:@"otherparam"];
        otherParam = [self otherParamFromDict:paramDict sourceParam:otherParam];
        channelArray = [typeDict objectForKey:CommentDataList_DataKey];
        [rtval addObject:otherParam];
    }
    BOOL bFirstArg = YES;
    NSArray* destArray = nil;
    
    if (columns) {
        if ([columns count]==[channelArray count]) {
            for (int i=0; i<[columns count]; i++) {
                NSNumber* columnNumber = [columns objectAtIndex:i];
                destArray = [channelArray objectAtIndex:i];
                int column = [columnNumber intValue];
                if (destArray&&column<[destArray count]) {
                    NSDictionary* oneValue = [destArray objectAtIndex:column];
                    NSDictionary* paramDict = [oneValue objectForKey:@"otherparam"];
                    otherParam = [self otherParamFromDict:paramDict sourceParam:otherParam];
                    
                    NSString* dataKey = [oneValue objectForKey:@"datakey"];
                    NSString* dataValue = [oneValue objectForKey:@"datavalue"];
                    if (dataKey&&dataValue&&![dataValue isEqualToString:@""]) {
                        if (bFirstArg) {
                            bFirstArg = NO;
                            totalAPI = [totalAPI stringByAppendingFormat:@"?%@=%@",dataKey,dataValue];
                            [rtval addObject:dataValue];
                        }
                        else
                        {
                            totalAPI = [totalAPI stringByAppendingFormat:@"&%@=%@",dataKey,dataValue];
                            [rtval addObject:dataValue];
                        }
                    }
                }
            }
            
        }
    }
    if (bFirstArg) {
        bFirstArg = NO;
        if (![otherParam isEqualToString:@""]) {
            totalAPI = [totalAPI stringByAppendingFormat:@"?%@",otherParam];
        }
        
    }
    else
    {
        if (![otherParam isEqualToString:@""]) {
            totalAPI = [totalAPI stringByAppendingFormat:@"&%@",otherParam];
        }
    }
    if ([rtval count]>0) {
        [rtval insertObject:totalAPI atIndex:0];
    }
    else
    {
        [rtval addObject:totalAPI];
    }
    
    return rtval;
}

-(NSArray*)curCommentAPICodeWithNestTypeAtRowColumns:(NSArray*)rowColumns
{
    NSMutableArray* columns = (NSMutableArray*)[CommentDataList convertStringToNumber:rowColumns createNewArray:YES];
    NSMutableArray* rtval = [NSMutableArray arrayWithCapacity:0];
    NSString* otherParam = @"";
    NSString* totalAPI = @"";
    
    NSDictionary* typeDict = nil;
    if ([self.nameList count]==1) {
        typeDict = [self.nameList lastObject];
    }
    else if([self.nameList count]>1)
    {
        if (columns&&[columns count]>0) {
            NSNumber* index = [columns objectAtIndex:0];
            typeDict = [self.nameList objectAtIndex:[index intValue]];
            [columns removeObjectAtIndex:0];
        }
    }
    
    NSArray* channelArray = nil;
    if (typeDict) {
        NSString* type = [typeDict objectForKey:@"type"];
        [rtval addObject:type];
        [rtval addObject:[typeDict objectForKey:@"api"]];
        totalAPI = [totalAPI stringByAppendingString:[typeDict objectForKey:@"api"]];
        NSDictionary* paramDict = [typeDict objectForKey:@"otherparam"];
        otherParam = [self otherParamFromDict:paramDict sourceParam:otherParam];
        channelArray = [typeDict objectForKey:CommentDataList_DataKey];
    }
    
    BOOL bFirstArg = YES;
    NSArray* destArray = channelArray;
    if (columns) {
        for (int i=0;i<[columns count];i++) {
            NSNumber* columnNumber = [columns objectAtIndex:i];
            int column = [columnNumber intValue];
            if (destArray&&column<[destArray count]) {
                NSDictionary* oneValue = [destArray objectAtIndex:column];
                NSDictionary* paramDict = [oneValue objectForKey:@"otherparam"];
                otherParam = [self otherParamFromDict:paramDict sourceParam:otherParam];
                
                NSString* dataKey = [oneValue objectForKey:@"datakey"];
                NSString* dataValue = [oneValue objectForKey:@"datavalue"];
                if (dataKey&&dataValue&&![dataValue isEqualToString:@""]) {
                    if (bFirstArg) {
                        bFirstArg = NO;
                        totalAPI = [totalAPI stringByAppendingFormat:@"?%@=%@",dataKey,dataValue];
                        [rtval addObject:dataValue];
                    }
                    else
                    {
                        totalAPI = [totalAPI stringByAppendingFormat:@"&%@=%@",dataKey,dataValue];
                        [rtval addObject:dataValue];
                    }
                }
                
                destArray = [oneValue objectForKey:CommentDataList_DataKey];
            }
            else
            {
                destArray = nil;
                break;
            }
        }
    }
    
    if (bFirstArg) {
        bFirstArg = NO;
        if (![otherParam isEqualToString:@""]) {
            totalAPI = [totalAPI stringByAppendingFormat:@"?%@",otherParam];
        }
    }
    else
    {
        if (![otherParam isEqualToString:@""]) {
            totalAPI = [totalAPI stringByAppendingFormat:@"&%@",otherParam];
        }
    }
    if ([rtval count]>0) {
        [rtval insertObject:totalAPI atIndex:0];
    }
    else
    {
        [rtval addObject:totalAPI];
    }
    if ([rtval count]>3) {
        [rtval insertObject:otherParam atIndex:3];
    }
    else
    {
        [rtval addObject:otherParam];
    }
    return rtval;
}

-(NSArray*)nameKeysWithIDList:(NSArray*)IDList
{
    IDList = [self sourceListWithOrderedList:IDList];
    NSArray* rtvalArray = nil;
    [self.nameLock lock];
    if (self.nameList&&[self.nameList count]>0) {
        NSMutableArray* rtval = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSDictionary* dict = nil;
        if ([self.nameList count]==1) {
            dict = [self.nameList lastObject];
        }
        else if([self.nameList count]>1)
        {
            if (IDList&&[IDList count]>0) {
                NSMutableArray* array = [NSMutableArray arrayWithArray:IDList];
                NSNumber* index = [array objectAtIndex:0];
                dict = [self.nameList objectAtIndex:[index intValue]];
                NSString* type = [dict objectForKey:@"type"];
                if (!type||[type isEqualToString:@""]) {
                    type = [NSString stringWithFormat:@"%@%@",CommentDataList_ReplaceString,index];
                }
                [rtval addObject:type];
                [array removeObjectAtIndex:0];
                IDList = array;
            }
        }
        
        NSArray* contentArray = [dict objectForKey:CommentDataList_DataKey];
        if (contentArray&&[contentArray isKindOfClass:[NSArray class]]&&[contentArray count]>0) 
        {
            if (self.nameListType==NameListType_queue) {
                for (int i=0;i<[IDList count];i++) {
                    if ([contentArray count]<=i) {
                        break;
                    }
                    NSString* idString = [IDList objectAtIndex:i];
                    NSArray* dataArray = [contentArray objectAtIndex:i];
                    NSDictionary* dataDict = [dataArray objectAtIndex:[idString intValue]];
                    NSString* dataValue = [dataDict objectForKey:@"datavalue"];
                    if ([dataValue isEqualToString:@""]) {
                        dataValue = [NSString stringWithFormat:@"%@%@",CommentDataList_ReplaceString,idString];
                    }
                    [rtval addObject:dataValue];
                }
            }
            else if(self.nameListType==NameListType_nest)
            {
                for (int i=0;i<[IDList count];i++) {
                    NSString* idString = [IDList objectAtIndex:i];
                    NSDictionary* dataDict = [contentArray objectAtIndex:[idString intValue]];
                    NSString* dataValue = [dataDict objectForKey:@"datavalue"];
                    if ([dataValue isEqualToString:@""]) {
                        dataValue = [NSString stringWithFormat:@"%@%@",CommentDataList_ReplaceString,idString];
                    }
                    [rtval addObject:dataValue];
                    if (i<[IDList count]-1) {
                        contentArray = [dataDict objectForKey:CommentDataList_DataKey];
                        if (!contentArray) {
                            break;
                        }
                    }
                }
            }
        }
        rtvalArray = rtval;
    }
    else
    {
        rtvalArray = IDList;
    }
    [self.nameLock unlock];
    return rtvalArray;
}

-(NSArray*)IDListWithNameKeys:(NSArray*)nameKeys
{
    NSArray* rtvalArray = nil;
    NSArray* oldnameKeys = nameKeys;
    [self.nameLock lock];
    if (self.nameList&&[self.nameList count]>0) {
        NSMutableArray* rtval = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSDictionary* dict = nil;
        if ([self.nameList count]==1) {
            dict = [self.nameList lastObject];
        }
        else if([self.nameList count]>1)
        {
            BOOL useIndexFromName = NO;
            NSMutableArray* newNameKeys = [NSMutableArray arrayWithArray:nameKeys];
            NSString* name_Type = [newNameKeys objectAtIndex:0];
            if ([name_Type hasPrefix:CommentDataList_ReplaceString]) {
                name_Type = [name_Type stringByReplacingOccurrencesOfString:CommentDataList_ReplaceString withString:@""];
                useIndexFromName = YES;
            }
            if (!useIndexFromName) {
                for (int i=0;i<[self.nameList count];i++) {
                    NSDictionary* dataTypeDict = [self.nameList objectAtIndex:i];
                    NSString* typeString =  [dataTypeDict objectForKey:@"type"];
                    
                    if ([name_Type isEqualToString:typeString]) {
                        dict = dataTypeDict;
                        [rtval addObject:[NSString stringWithFormat:@"%d",i]];
                        break;
                    }
                }
            }
            else
            {
                if ([name_Type intValue]<[self.nameList count]) {
                    NSDictionary* dataTypeDict = [self.nameList objectAtIndex:[name_Type intValue]];
                    NSString* typeString =  [dataTypeDict objectForKey:@"type"];
                    if (typeString==nil||[typeString isEqualToString:@""]) {
                        [rtval addObject:name_Type];
                        dict = dataTypeDict;
                    }
                }
            }
            [newNameKeys removeObjectAtIndex:0];
            nameKeys = newNameKeys;
        }
        
        NSArray* contentArray = [dict objectForKey:CommentDataList_DataKey];
        if (contentArray&&[contentArray isKindOfClass:[NSArray class]]&&[contentArray count]>0) 
        {
            if (self.nameListType==NameListType_queue) {
                for (int i=0;i<[nameKeys count];i++) {
                    if ([contentArray count]<=i) {
                        break;
                    }
                    BOOL useIndexFromName = NO;
                    NSString* idString = [nameKeys objectAtIndex:i];
                    if ([idString hasPrefix:CommentDataList_ReplaceString]) {
                        idString = [idString stringByReplacingOccurrencesOfString:CommentDataList_ReplaceString withString:@""];
                        useIndexFromName = YES;
                    }
                    
                    NSArray* dataArray = [contentArray objectAtIndex:i];
                    if (!useIndexFromName) {
                        for (int j=0;j<[dataArray count];j++) {
                            NSDictionary* dataDict = [dataArray objectAtIndex:j];
                            NSString* dataValue = [dataDict objectForKey:@"datavalue"];
                            if ([idString isEqualToString:dataValue]) {
                                [rtval addObject:[NSString stringWithFormat:@"%d",j]];
                                break;
                            }
                        }
                    }
                    else
                    {
                        if ([idString intValue]<[dataArray count])
                        {
                            NSDictionary* dataDict = [dataArray objectAtIndex:[idString intValue]];
                            NSString* dataValue = [dataDict objectForKey:@"datavalue"];
                            if (dataValue==nil||[dataValue isEqualToString:@""]) {
                                [rtval addObject:idString];
                            }
                        }
                    }
                }
            }
            else if(self.nameListType==NameListType_nest)
            {
                for (int i=0;i<[nameKeys count];i++) {
                    NSString* idString = [nameKeys objectAtIndex:i];
                    BOOL useIndexFromName = NO;
                    if ([idString hasPrefix:CommentDataList_ReplaceString]) {
                        idString = [idString stringByReplacingOccurrencesOfString:CommentDataList_ReplaceString withString:@""];
                        useIndexFromName = YES;
                    }
                    if (!useIndexFromName) {
                        for (int j=0;j<[contentArray count];j++) {
                            NSDictionary* dataDict = [contentArray objectAtIndex:j];
                            NSString* dataValue = [dataDict objectForKey:@"datavalue"];
                            if ([idString isEqualToString:dataValue]) {
                                [rtval addObject:[NSString stringWithFormat:@"%d",j]];
                                contentArray = [dataDict objectForKey:CommentDataList_DataKey];
                                break;
                            }
                        }
                    }
                    else
                    {
                        if ([idString intValue]<[contentArray count]) 
                        {
                            NSDictionary* dataDict = [contentArray objectAtIndex:[idString intValue]];
                            NSString* dataValue = [dataDict objectForKey:@"datavalue"];
                            if (dataValue==nil||[dataValue isEqualToString:@""]) {
                                [rtval addObject:[NSString stringWithFormat:@"%d",[idString intValue]]];
                                contentArray = [dataDict objectForKey:CommentDataList_DataKey];
                            }
                        }
                    }
                    
                    if (!contentArray) {
                        break;
                    }
                }
            }
        }
        
        if (oldnameKeys&&rtval&&[rtval count]!=[oldnameKeys count])
        {
            rtval = nil;
        }
        rtvalArray = rtval;
    }
    else
    {
        rtvalArray = nameKeys;
    }
    [self.nameLock unlock];
    rtvalArray = [self orderedListWithSourceList:rtvalArray];
    return rtvalArray;
}

-(void)setOrderArray:(NSArray*)orderArray atIndex:(NSInteger)index
{
    [self.orderLock lock];
    if (index<[self.showableOrderArray count]) {
        NSMutableArray* oldOrderArray = [self.showableOrderArray objectAtIndex:index];
        NSArray* oldTotalOrderArray = [self.totalOrderArray objectAtIndex:index];
        [oldOrderArray removeAllObjects];
        
        for (int i=0;i<[orderArray count];i++) {
            AdjustOrderData* newData = [orderArray objectAtIndex:i];
            if (newData.type==AdjustOrderType_abled) {
                for (int j=0;j<[oldTotalOrderArray count];j++) {
                    AdjustOrderData* oldData = [oldTotalOrderArray objectAtIndex:j];
                    if ([oldData.key isEqualToString:newData.key]) {
                        [oldOrderArray addObject:[NSNumber numberWithInt:j]];
                        break;
                    }
                }
            }
        }
    }
    [self.orderLock unlock];
    
    NSData* orderData = [NSKeyedArchiver archivedDataWithRootObject:orderArray];
    NSDictionary* typeDict = [self.nameList objectAtIndex:index];
    [[RegValueSaver getInstance] saveSystemInfoValue:orderData forKey:[NSString stringWithFormat:@"order_%@_%@",self.dataTableName,[typeDict objectForKey:@"type"]] encryptString:NO];
}

-(NSMutableArray*)orderArrayOfIndex:(NSInteger)index
{
    NSMutableArray* rtval = [NSMutableArray arrayWithCapacity:0];
    [self.orderLock lock];
    if (index<[self.showableOrderArray count]) {
        NSArray* orderArray = [self.showableOrderArray objectAtIndex:index];
        NSArray* oldTotalOrderArray = [self.totalOrderArray objectAtIndex:index];
        for (NSNumber* orderNum in orderArray) {
            AdjustOrderData* oldData = [oldTotalOrderArray objectAtIndex:[orderNum intValue]];
            AdjustOrderData* newData = [[AdjustOrderData alloc] init];
            newData.type = AdjustOrderType_abled;
            newData.key = oldData.key;
            newData.value = oldData.value;
            newData.movable = oldData.movable;
            newData.subArray = oldData.subArray;
            [rtval addObject:newData];
            [newData release];
        }
        for (int i=0; i<[oldTotalOrderArray count]; i++) {
            BOOL hasFound = NO;
            for (int j=0; j<[orderArray count]; j++) {
                NSNumber* orderNumber = [orderArray objectAtIndex:j];
                if ([orderNumber intValue]==i) {
                    hasFound = YES;
                    break;
                }
            }
            if (!hasFound) {
                AdjustOrderData* oldData = [oldTotalOrderArray objectAtIndex:i];
                AdjustOrderData* newData = [[AdjustOrderData alloc] init];
                newData.type = AdjustOrderType_disabled;
                newData.key = oldData.key;
                newData.value = oldData.value;
                newData.movable = oldData.movable;
                newData.subArray = oldData.subArray;
                [rtval addObject:newData];
                [newData release];
            }
        }
    }
    [self.orderLock unlock];
    return rtval;
}

-(NSArray*)sourceListWithOrderedList:(NSArray*)orderedArray
{
    NSArray* rtval = orderedArray;
    [self.orderLock lock];
    if (self.showableOrderArray) {
        NSMutableArray* newArray = [NSMutableArray arrayWithArray:orderedArray];
        id indexObject = nil;
        NSArray* firstArray = nil;
        if (hasFirstIndex) {
            if ([newArray count]>1+orderLayer) {
                indexObject = [newArray objectAtIndex:1+orderLayer];
                int typeIndex = [(NSNumber*)[newArray objectAtIndex:0] intValue];
                firstArray = [self.showableOrderArray objectAtIndex:typeIndex];
            }
        }
        else
        {
            if ([newArray count]>0+orderLayer) {
                indexObject = [newArray objectAtIndex:0+orderLayer];
                firstArray = [self.showableOrderArray objectAtIndex:0];
            }
        }
        if (indexObject) {
            id destValue = nil;
            if ([indexObject isKindOfClass:[NSString class]]) {
                NSString* indexString = (NSString*)indexObject;
                NSNumber* destNumber = [firstArray objectAtIndex:[indexString intValue]];
                destValue = [destNumber stringValue];
            }
            else
            {
                NSNumber* indexNumber = (NSNumber*)indexObject;
                NSNumber* destNumber = [firstArray objectAtIndex:[indexNumber intValue]];
                destValue = destNumber;
            }
            
            if (hasFirstIndex) {
                [newArray replaceObjectAtIndex:1+orderLayer withObject:destValue];
            }
            else
            {
                [newArray replaceObjectAtIndex:0+orderLayer withObject:destValue];
            }
        }
        
        rtval = newArray;
    }
    
    [self.orderLock unlock];
    return rtval;
}

-(NSArray*)orderedListWithSourceList:(NSArray*)sourceArray
{
    NSArray* rtval = sourceArray;
    [self.orderLock lock];
    if (self.showableOrderArray) {
        NSMutableArray* newArray = [NSMutableArray arrayWithArray:sourceArray];
        id indexObject = nil;
        NSArray* firstArray = nil;
        if (hasFirstIndex) {
            if ([newArray count]>1+orderLayer) {
                indexObject = [newArray objectAtIndex:1+orderLayer];
                int typeIndex = [(NSNumber*)[newArray objectAtIndex:0] intValue];
                firstArray = [self.showableOrderArray objectAtIndex:typeIndex];
            }
        }
        else
        {
            if ([newArray count]>0+orderLayer) {
                indexObject = [newArray objectAtIndex:0+orderLayer];
                firstArray = [self.showableOrderArray objectAtIndex:0];
            }
        }
        if (indexObject) {
            id destValue = nil;
            if ([indexObject isKindOfClass:[NSString class]]) {
                NSString* indexString = (NSString*)indexObject;
                for (int i=0;i<[firstArray count];i++) {
                    NSNumber* orderNumber = [firstArray objectAtIndex:i];
                    if ([orderNumber intValue]==[indexString intValue]) {
                        destValue = [[NSNumber numberWithInt:i] stringValue];
                        break;
                    }
                }
            }
            else
            {
                NSNumber* indexNumber = (NSNumber*)indexObject;
                for (int i=0;i<[firstArray count];i++) {
                    NSNumber* orderNumber = [firstArray objectAtIndex:i];
                    if ([orderNumber intValue]==[indexNumber intValue]) {
                        destValue = [[NSNumber numberWithInt:i] stringValue];
                        break;
                    }
                }
            }
            
            if (hasFirstIndex) {
                [newArray replaceObjectAtIndex:1+orderLayer withObject:destValue];
            }
            else
            {
                [newArray replaceObjectAtIndex:0+orderLayer withObject:destValue];
            }
        }
        
        rtval = newArray;
    }
    
    [self.orderLock unlock];
    return rtval;
}

-(void)initAllObjects
{
    if (!mCellObjects) {
        mCellObjects = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!mShowedObjects) {
        mShowedObjects = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!mLock) {
        mLock = [[NSLock alloc] init];
    }
    if (!mShowedLock) {
        mShowedLock = [[NSLock alloc] init];
    }
}

-(NSMutableDictionary*)findContentsDataDictWithObjects:(NSMutableArray*)objects IDList:(NSArray*)IDList
{
    NSMutableDictionary* rtval = nil;
    if (objects&&[IDList count]>0)
    {
        BOOL error = NO;
        for (NSString* oneID in IDList) {
            if ([oneID isEqualToString:@""]) {
                error = YES;
                break;
            }
        }
        if (!error) {
            NSMutableDictionary* dict = nil;
            NSEnumerator* enumerator = [objects objectEnumerator];
            while (dict = [enumerator nextObject])
            {
                BOOL founded = YES;
                for (int i = 0; i < [IDList count]; i++) {
                    NSString* keyName = [NSString stringWithFormat:@"%d",i];
                    NSString* keyValue = [dict objectForKey:keyName];
                    NSString* sourceValue = [IDList objectAtIndex:i];
                    if (![keyValue isEqualToString:sourceValue]) {
                        founded = NO;
                        break;
                    }
                }
                if (founded) {
                    rtval = dict;
                    break;
                }
            }
        }
    }
    
    return rtval;
}

-(DataModel*)oneObjectWithIndex:(NSInteger)index IDList:(NSArray*)IDList
{
    DataModel* rtval = nil;
    if (YES) 
    {
        NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
        [self.showedLock lock];
        NSDictionary* foundDict = [self findContentsDataDictWithObjects:mShowedObjects IDList:dataIDArray];
        NSArray* contentsArray = [foundDict objectForKey:CommentDataList_DataKey];
        if ([contentsArray count]>index) {
            rtval = [contentsArray objectAtIndex:index];
        }
        [self.showedLock unlock];
    }
    return rtval;
}

-(DataModel*)lastObjectWithIDList:(NSArray*)IDList
{
    DataModel* rtval = nil;
    if (YES) 
    {
        NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
        [self.showedLock lock];
        NSDictionary* foundDict = [self findContentsDataDictWithObjects:mShowedObjects IDList:dataIDArray];
        NSArray* contentsArray = [foundDict objectForKey:CommentDataList_DataKey];
        rtval = [contentsArray lastObject];
        [self.showedLock unlock];
    }
    
    return rtval;
}

-(void)addCommnetContents:(NSArray*)objects IDList:(NSArray*)IDList refresh:(BOOL)bRefresh
{
    [self initAllObjects];
    NSMutableDictionary* readedObjects = [self findContentsDataDictWithObjects:mCellObjects IDList:IDList];
    if (!readedObjects) {
        readedObjects = [NSMutableDictionary dictionaryWithCapacity:0];
        for (int i=0; i<[IDList count]; i++) {
            NSString* keyName = [NSString stringWithFormat:@"%d",i];
            NSString* keyValue = [IDList objectAtIndex:i];
            [readedObjects setObject:keyValue forKey:keyName];
        }
        [mCellObjects addObject:readedObjects];
    }
    NSMutableArray* contentsArray = [readedObjects objectForKey:CommentDataList_DataKey];
    if (!contentsArray) {
        contentsArray = [NSMutableArray arrayWithCapacity:0];
        [readedObjects setObject:contentsArray forKey:CommentDataList_DataKey];
    }
    if (bRefresh) {
        [contentsArray removeAllObjects];
    }
    [contentsArray addObjectsFromArray:objects];
    if (self.idListCount==0) {
        self.idListCount = [IDList count];
    }
}

-(void)refreshCommnetContents:(NSArray*)objects IDList:(NSArray*)IDList
{
    NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
    [self.lock lock];
    [self reloadDataFromDataBaseWithDataIDList:dataIDArray sourceID:dataIDArray];
    [self addCommnetContents:objects IDList:dataIDArray refresh:YES];
    
    [self.lock unlock];
    if (self.dataTableName) {
        [[DataBaseSaver getInstance] refreshDataWithTable:self.dataTableName idList:dataIDArray data:objects];
    }
    [self.dataBaseLock lock];
    NSMutableDictionary* info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSDate date], @"date", nil];
    [info setValue:[NSNumber numberWithInt:1] forKey:@"page"];
    if (self.dataTableName)
    {
        [[DataBaseSaver getInstance] updateInfoTableWithTableName:self.dataTableName idList:dataIDArray info:info];
    }
    NSString* idString = [dataIDArray componentsJoinedByString:@"{_}"];
    NSMutableDictionary* mutableInfo = nil;
    if (!mListInfo) {
        mListInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    else
    {
        mutableInfo = [self.listInfo objectForKey:idString];
        if (!mutableInfo) {
            mutableInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
            [self.listInfo setValue:mutableInfo forKey:idString];
            [mutableInfo release];
        }
    }
    [mutableInfo addEntriesFromDictionary:info];
    [info release];
    
    [self.dataBaseLock unlock];
    
    [self removeReloadedIDList:dataIDArray];
}

-(void)addCommnetContents:(NSArray*)objects IDList:(NSArray*)IDList
{
    NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
    [self.lock lock];
    [self reloadDataFromDataBaseWithDataIDList:dataIDArray sourceID:dataIDArray];
    [self addCommnetContents:objects IDList:dataIDArray refresh:NO];
    [self.lock unlock];
    if (self.dataTableName) {
        [[DataBaseSaver getInstance] addDataWithTable:self.dataTableName idList:dataIDArray data:objects];
    }
    
    [self.dataBaseLock lock];
    NSString* idString = [dataIDArray componentsJoinedByString:@"{_}"];
    NSMutableDictionary* mutableInfo = nil;
    if (!mListInfo) {
        mListInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    else
    {
        mutableInfo = [self.listInfo objectForKey:idString];
        if (!mutableInfo) {
            mutableInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
            [self.listInfo setValue:mutableInfo forKey:idString];
            [mutableInfo release];
        }
    }
    NSMutableDictionary* info = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSNumber* pageNumber = [mutableInfo valueForKey:@"page"];
    if (pageNumber) {
        [info setValue:[NSNumber numberWithInt:[pageNumber intValue]+1] forKey:@"page"];
    }
    else
    {
        [info setValue:[NSNumber numberWithInt:1] forKey:@"page"];
    }
    
    if (self.dataTableName)
    {
        [[DataBaseSaver getInstance] addInfoTableWithTableName:self.dataTableName idList:dataIDArray info:info];
    }
    
    [mutableInfo addEntriesFromDictionary:info];
    [info release];
    
    [self.dataBaseLock unlock];
    [self removeReloadedIDList:dataIDArray];
}

-(void)refreshDataBaseWithOneCommnetContent:(DataModel*)oneObject dataIDList:(NSArray*)dataIDArray row:(NSInteger)row
{
    if (self.dataTableName) {
        NSArray* newIDArray = [CommentDataList convertNumberToString:dataIDArray createNewArray:YES];
        [self.lock lock];
        NSDictionary* foundDict = [self findContentsDataDictWithObjects:self.cellObjects IDList:newIDArray];
        NSArray* contentsArray = [foundDict objectForKey:CommentDataList_DataKey];
        if ([contentsArray count]>row) {
            DataModel* oldObject = [contentsArray objectAtIndex:row];
            if (oldObject==oneObject) {
                [[DataBaseSaver getInstance] updateDataWithTable:self.dataTableName oneData:oneObject idList:dataIDArray row:row];
            }
        }
        [self.lock unlock];
    }
}

-(void)removeOfIndex:(NSInteger)index IDList:(NSArray*)IDList
{
    NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
    [self.lock lock];
    [self reloadDataFromDataBaseWithDataIDList:dataIDArray sourceID:dataIDArray];
    
    [self initAllObjects];
    NSMutableDictionary* readedObjects = [self findContentsDataDictWithObjects:mCellObjects IDList:IDList];
    if (readedObjects) {
        NSMutableArray* contentsArray = [readedObjects objectForKey:CommentDataList_DataKey];
        if (contentsArray) {
            [contentsArray removeObjectAtIndex:index];
            if (self.idListCount==0) {
                self.idListCount = [IDList count];
            }
        }
        if (self.dataTableName) {
            [[DataBaseSaver getInstance] removeDataOfIndex:index table:self.dataTableName idList:dataIDArray];
        }
    }
    
    [self.lock unlock];
    [self removeReloadedIDList:dataIDArray];
}

-(void)removeAllWithIDList:(NSArray*)IDList
{
    NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
    [self.lock lock];
    [self reloadDataFromDataBaseWithDataIDList:dataIDArray sourceID:dataIDArray];
    
    [self initAllObjects];
    NSMutableDictionary* readedObjects = [self findContentsDataDictWithObjects:mCellObjects IDList:IDList];
    if (readedObjects) {
        NSMutableArray* contentsArray = [readedObjects objectForKey:CommentDataList_DataKey];
        if (contentsArray) {
            [contentsArray removeAllObjects];
        }
        if (self.idListCount==0) {
            self.idListCount = [IDList count];
        }
        if (self.dataTableName) {
            [[DataBaseSaver getInstance] removeAllDataWithTable:self.dataTableName idList:dataIDArray];
        }
    }
    
    [self.lock unlock];
    [self removeReloadedIDList:dataIDArray];
}

-(NSInteger)contentsCountWithIDList:(NSArray*)IDList
{
    NSInteger rtval = 0;
    if (YES) 
    {
        NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
        [self.showedLock lock];
        NSDictionary* foundDict = [self findContentsDataDictWithObjects:mShowedObjects IDList:dataIDArray];
        NSArray* contentsArray = [foundDict objectForKey:CommentDataList_DataKey];
        if (contentsArray) {
            rtval = [contentsArray count];
        }
        [self.showedLock unlock];
    }
    
    return rtval;
}

-(BOOL)hasLoadedWithIDList:(NSArray*)IDList
{
    BOOL rtval = NO;
    if (IDList) {
        for (NSArray* oldIDList in self.loadedList) 
        {
            BOOL bEaqual = NO;
            if([IDList count]==[oldIDList count])
            {
                bEaqual = YES;
                for (int i=0; i<[IDList count]; i++) {
                    NSString* oneIDStr = [IDList objectAtIndex:i];
                    NSString* oneOldIDStr = [oldIDList objectAtIndex:i];
                    if (![oneIDStr isEqualToString:oneOldIDStr]) {
                        bEaqual = NO;
                        break;
                    }
                }
            }
            if (bEaqual) {
                rtval = YES;
                break;
            }
        }
    }
    return rtval;
}

-(void)reloadDataFromDataBaseWithDataIDList:(NSArray*)dataIDList sourceID:(NSArray*)sourceIDList
{
    if (self.dataTableName) {
        BOOL bLoaded = [self hasLoadedWithIDList:dataIDList];
        if (!bLoaded) {
            [self.dataBaseLock lock];
            NSDictionary* info = [[DataBaseSaver getInstance] loadInfoTableWithTableName:self.dataTableName idList:dataIDList];
            if (!mListInfo) {
                mListInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            if (info) {
                NSMutableDictionary* mutableInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
                NSString* oneKey = [sourceIDList componentsJoinedByString:@"{_}"];
                [self.listInfo setObject:mutableInfo forKey:oneKey];
                [mutableInfo release];
            }
            NSArray* dataArray = [[DataBaseSaver getInstance] loadDataWithTable:self.dataTableName idList:dataIDList];
            if (dataArray&&[dataArray count]>0) {
                [self addCommnetContents:dataArray IDList:dataIDList refresh:YES];
            }
            if (!self.loadedList) {
                mLoadedList = [[NSMutableArray alloc] initWithCapacity:0];
            }
            [self.loadedList addObject:dataIDList];
            [self.dataBaseLock unlock];
        } 
    }
}

-(void)addReloadedIDList:(NSArray*)IDList
{
    if (!reloadedIDArray) {
        reloadedIDArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!reloadedLock) {
        reloadedLock = [[NSLock alloc] init];
    }
    [reloadedLock lock];
    int foundedIndex = -1;
    for (int i = 0;i<[reloadedIDArray count];i++) {
        NSArray* oldIDList = [reloadedIDArray objectAtIndex:i];
        BOOL bEqualed = [CommentDataList checkNumberArrayEqualWithFirstArray:oldIDList secondArray:IDList];
        if (bEqualed) {
            foundedIndex = i;
            break;
        }
    }
    if (foundedIndex<0) {
        [reloadedIDArray addObject:IDList];
    }
    [reloadedLock unlock];
}

-(void)removeReloadedIDList:(NSArray*)IDList
{
    if (reloadedIDArray&&reloadedLock) {
        [reloadedLock lock];
        int foundedIndex = -1;
        for (int i = 0;i<[reloadedIDArray count];i++) {
            NSArray* oldIDList = [reloadedIDArray objectAtIndex:i];
            BOOL bEqualed = [CommentDataList checkNumberArrayEqualWithFirstArray:oldIDList secondArray:IDList];
            if (bEqualed) {
                foundedIndex = i;
                break;
            }
        }
        if (foundedIndex>=0) {
            [reloadedIDArray removeObjectAtIndex:foundedIndex];
        }
        [reloadedLock unlock];
    }
}

-(BOOL)needReloadShowedDataWithIDList:(NSArray*)IDList
{
    BOOL needReload = YES;
    if (reloadedIDArray&&reloadedLock) {
        [reloadedLock lock];
        int foundedIndex = -1;
        for (int i = 0;i<[reloadedIDArray count];i++) {
            NSArray* oldIDList = [reloadedIDArray objectAtIndex:i];
            BOOL bEqualed = [CommentDataList checkNumberArrayEqualWithFirstArray:oldIDList secondArray:IDList];
            if (bEqualed) {
                foundedIndex = i;
                break;
            }
        }
        [reloadedLock unlock];
        if (foundedIndex>=0) {
            needReload = NO;
        }
    }
    return needReload;
}

-(void)reloadShowedDataWithIDList:(NSArray*)IDList
{
    NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
    BOOL needReolad = [self needReloadShowedDataWithIDList:dataIDArray];
    if (needReolad) 
    {
        [self.lock lock];
        [self reloadDataFromDataBaseWithDataIDList:dataIDArray sourceID:dataIDArray];
        NSMutableDictionary* savedObjects = [self findContentsDataDictWithObjects:mCellObjects IDList:dataIDArray];
        NSMutableArray* savedContentsArray = [savedObjects objectForKey:CommentDataList_DataKey];
        if (savedContentsArray) {
            [self.showedLock lock];
            NSMutableDictionary* readedObjects = [self findContentsDataDictWithObjects:mShowedObjects IDList:dataIDArray];
            if (!readedObjects) {
                readedObjects = [NSMutableDictionary dictionaryWithCapacity:0];
                for (int i=0; i<[dataIDArray count]; i++) {
                    NSString* keyName = [NSString stringWithFormat:@"%d",i];
                    NSString* keyValue = [dataIDArray objectAtIndex:i];
                    [readedObjects setObject:keyValue forKey:keyName];
                }
                [mShowedObjects addObject:readedObjects];
            }
            NSMutableArray* contentsArray = [readedObjects objectForKey:CommentDataList_DataKey];
            if (!contentsArray) {
                contentsArray = [NSMutableArray arrayWithCapacity:0];
                [readedObjects setObject:contentsArray forKey:CommentDataList_DataKey];
            }
            else
            {
                [contentsArray removeAllObjects];
            }
            [contentsArray addObjectsFromArray:savedContentsArray];
            for (int i=0;i<[contentsArray count];i++) {
                DataModel* oneObject = [contentsArray objectAtIndex:i];
                oneObject.parentList = self;
                oneObject.IDListInParentList = dataIDArray;
                oneObject.rowInParentList = i;
            }
            [self.showedLock unlock];
        }
        [self.lock unlock];
        [self addReloadedIDList:dataIDArray];
    }
}

-(NSArray*)contentsWithIDList:(NSArray*)IDList
{
    NSMutableArray* rtval = nil;
    if (YES) 
    {
        NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
        [self.showedLock lock];
        NSDictionary* foundDict = [self findContentsDataDictWithObjects:mShowedObjects IDList:dataIDArray];
        NSArray* contentsArray = [foundDict objectForKey:CommentDataList_DataKey];
        rtval = (NSMutableArray*)contentsArray;
        [self.showedLock unlock];
    }
    return rtval;
}

-(void)setInfoWithIDList:(NSArray*)IDList value:(id)value forKey:(NSString*)key
{
    NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
    [self.dataBaseLock lock];
    if (!mListInfo) {
        mListInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    NSString* idString = [dataIDArray componentsJoinedByString:@"{_}"];
    NSMutableDictionary* oldInfo = [self.listInfo objectForKey:idString];
    NSMutableDictionary* infoDict = oldInfo;
    if (!oldInfo) {
        infoDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [self.listInfo setValue:infoDict forKey:idString];
        if (self.dataTableName) {
            [[DataBaseSaver getInstance] updateInfoTableWithTableName:self.dataTableName idList:dataIDArray info:infoDict];
        }
        [infoDict release];
    }
    else
    {
        infoDict = oldInfo;
        [self.listInfo setValue:infoDict forKey:idString];
        if (self.dataTableName) {
            [[DataBaseSaver getInstance] updateInfoTableWithTableName:self.dataTableName idList:dataIDArray info:infoDict];
        }
    }
    
    
    
    [self.dataBaseLock unlock];
}

-(id)infoValueWithIDList:(NSArray*)IDList ForKey:(NSString *)key
{
    id rtval = nil;
    [self reloadShowedDataWithIDList:IDList];
    NSArray* dataIDArray = [CommentDataList convertNumberToString:IDList createNewArray:YES];
    [self.dataBaseLock lock];
    NSString* idString = [dataIDArray componentsJoinedByString:@"{_}"];
    NSDictionary* info = [self.listInfo valueForKey:idString];
    rtval = [info valueForKey:key];
    [self.dataBaseLock unlock];
    return rtval;
}

-(NSDate*)dateInfoWithIDList:(NSArray*)IDList
{
    NSDate* rtval = (NSDate*)[self infoValueWithIDList:IDList ForKey:@"date"];
    return rtval;
}

@end

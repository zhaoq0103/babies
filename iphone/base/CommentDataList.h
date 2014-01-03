//
//  CommentDataList.h
//  SinaNews
//
//  Created by shieh exbice on 11-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModel.h"

enum AdjustOrderType
{
    AdjustOrderType_abled,
    AdjustOrderType_disabled
};

@interface AdjustOrderData : NSObject
{
    NSInteger type;
    NSString* key;
    NSString* value;
    BOOL movable;
    NSMutableArray* subArray;
}
@property(nonatomic,assign)NSInteger type;
@property(nonatomic,retain)NSString* key;
@property(nonatomic,retain)NSString* value;
@property(nonatomic,assign)BOOL movable;
@property(nonatomic,retain)NSMutableArray* subArray;

+(AdjustOrderData*)dataWithData:(NSData*)savableData;
-(NSData*)savableData;

@end

@interface CommentDataList : NSObject
{
    NSMutableArray* mCellObjects;  //此数组中第一级dictionary存导航选择的索引和data共3值
    NSLock* mLock;
    NSMutableArray* mShowedObjects;
    NSLock* mShowedLock;
    NSLock* mNameLock;
    NSLock* mDataBaseLock;
    NSLock* mOrderLock;
    BOOL hasFirstIndex;
    
    NSArray* mNameList;
    NSString* mDataTableName;
    NSMutableArray* mLoadedList;
    NSMutableDictionary* mListInfo;
    NSMutableArray* mShowableOrderArray;
    NSMutableArray* mTotalOrderArray;
    NSInteger orderLayer;
    
    NSMutableArray* reloadedIDArray;
    NSLock* reloadedLock;
}
@property(retain)NSString* dataTableName;
@property(assign)NSInteger countPerPage;

+(NSArray*)convertStringToNumber:(NSArray*)array createNewArray:(BOOL)created;
+(NSArray*)convertNumberToString:(NSArray*)array createNewArray:(BOOL)created;
+(BOOL)checkNumberArrayEqualWithFirstArray:(NSArray*)first secondArray:(NSArray*)second;

-(id)initWithFileName:(NSString*)aFileName;
-(id)initWithJsonString:(NSString*)jsonString;
-(id)initWithJsonArray:(NSArray*)jsonArray;
-(void)replaceNameListWithTypeIndex:(NSInteger)index DataArray:(NSArray*)dataArray;
-(NSArray*)subCommentNamelistAtRowColumns:(NSArray*)columns;
-(NSArray*)curCommentAPICodeAtRowColumns:(NSArray*)columns;
-(NSArray*)nameKeysWithIDList:(NSArray*)IDList;
-(NSArray*)IDListWithNameKeys:(NSArray*)nameKeys;
-(void)setOrderArray:(NSArray*)orderArray atIndex:(NSInteger)index;
-(NSMutableArray*)orderArrayOfIndex:(NSInteger)index;

-(BOOL)needReloadShowedDataWithIDList:(NSArray*)IDList;
-(void)reloadShowedDataWithIDList:(NSArray*)IDList;
-(NSInteger)contentsCountWithIDList:(NSArray*)IDList;
-(void)addCommnetContents:(NSArray*)objects IDList:(NSArray*)IDList;
-(void)refreshCommnetContents:(NSArray*)objects IDList:(NSArray*)IDList;
-(void)refreshDataBaseWithOneCommnetContent:(DataModel*)oneObject dataIDList:(NSArray*)dataIDArray row:(NSInteger)row;
-(void)removeOfIndex:(NSInteger)index IDList:(NSArray*)IDList;
-(void)removeAllWithIDList:(NSArray*)IDList;
-(DataModel*)oneObjectWithIndex:(NSInteger)index IDList:(NSArray*)IDList;
-(NSArray*)contentsWithIDList:(NSArray*)IDList;
-(DataModel*)lastObjectWithIDList:(NSArray*)IDList;
-(void)setInfoWithIDList:(NSArray*)IDList value:(id)value forKey:(NSString*)key;
-(id)infoValueWithIDList:(NSArray*)IDList ForKey:(NSString *)key;
-(NSDate*)dateInfoWithIDList:(NSArray*)IDList;

-(NSArray*)curCommentAPICodeAtRowColumnsForMv:(NSArray*)IDList;
@end

//
//  DataBaseSaver.h
//  SinaNews
//
//  Created by shieh exbice on 11-7-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class DataModel;

@interface DataBaseSaver : NSObject
{
}

@property(retain)FMDatabase*    database;
@property(retain)FMDatabase*    offlineDB;
@property(retain)NSLock*        dbLock;

+ (id)getInstance;

-(void)addDataWithTable:(NSString*)tableName idList:(NSArray*)idList data:(NSArray*)dataArray;
-(void)refreshDataWithTable:(NSString*)tableName idList:(NSArray*)idList data:(NSArray*)dataArray;
-(void)removeAllDataWithTable:(NSString*)tableName idList:(NSArray*)idList;
-(void)removeDataOfIndex:(NSInteger)index table:(NSString*)tableName idList:(NSArray*)idList;
-(void)updateDataWithTable:(NSString*)tableName oneData:(DataModel*)oneObject idList:(NSArray*)idList row:(NSInteger)row;
-(NSArray*)loadDataWithTable:(NSString*)tableName idList:(NSArray*)idList;
-(void)updateInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList info:(NSDictionary*)info;
-(void)addInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList info:(NSDictionary*)info;
-(NSDictionary*)loadInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList;
//for offline
-(NSArray*) getOfflineDataFromDBByKeyword:(NSString*)keyword andPangeIndex:(int)index andPageCount:(int)pageCount;
-(NSArray*) getOfflineDataStartFromPage:(int)pageIndex andPageCount:(int)pageCount;
@end

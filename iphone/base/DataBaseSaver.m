//
//  DataBaseSaver.m
//  SinaNews
//
//  Created by shieh exbice on 11-7-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DataBaseSaver.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DataModel.h"
#import "defines.h"

NSString* DataBaseIndex = @"DataBaseIndex";

static DataBaseSaver* s_databaseSaver = nil;


@interface DataBaseSaver ()
-(NSArray*)initTableWithTableName:(NSString*)tableName idList:(NSArray*)idList;

-(void)startLoadFromDisk;
-(void)realAddDataWithTable:(NSString*)tableName idList:(NSArray*)idList data:(NSArray*)dataArray;
-(NSArray*)initInfoTable;
-(NSDictionary*)loadInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList threadLock:(BOOL)locked;
-(void)updateInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList info:(NSDictionary*)info threadLock:(BOOL)locked;
-(void)updateInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList info:(NSDictionary*)info threadLock:(BOOL)locked added:(BOOL)bAdded;
-(void)addInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList info:(NSDictionary*)info threadLock:(BOOL)locked;
-(void)realRemoveAllDataWithTable:(NSString*)tableName idList:(NSArray*)idList;
-(void)realRemoveDataOfIndex:(NSInteger)index table:(NSString*)tableName idList:(NSArray*)idList;
@end

@implementation DataBaseSaver


+ (id)getInstance
{
	if (s_databaseSaver == nil)
	{
		//没有创建则创建
		s_databaseSaver = [[DataBaseSaver alloc] init];
	}
	return s_databaseSaver;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _dbLock = [[NSLock alloc] init];
        [self startLoadFromDisk];
    }
    
    return self;
}

-(void)dealloc
{
    [_dbLock release];
    [_database release];
    
    [super dealloc];
}

-(void)startLoadFromDisk
{
    NSArray* documentPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentPath = [documentPathArray objectAtIndex:0];
    documentPath = [documentPath stringByAppendingPathComponent:ContentDatabase];
    [self.dbLock lock];
    self.database = [FMDatabase databaseWithPath:documentPath];
    
    if ([_database open]) {
        // kind of experimentalish.
        [_database setShouldCacheStatements:YES];
    }
    [self.dbLock unlock];
    
    //offline db, copy from bundle to Document
    NSString* documentPath2 = [documentPathArray objectAtIndex:0];
    documentPath = [documentPath2 stringByAppendingPathComponent:OfflineDatabase];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:documentPath])
    {
        NSString *bundleDb = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:OfflineDatabase];
        //db file not exists
        
        NSError *error = nil;
        [fileManager copyItemAtPath:bundleDb toPath:documentPath error:&error];
        if(error)
        {
            NSLog(@"db copyItemAtPath error: %@", error.localizedFailureReason);
        }
    }
    
    [self.dbLock lock];
    self.offlineDB = [FMDatabase databaseWithPath:documentPath];
    
    if ([_offlineDB open]) {
        // kind of experimentalish.
        [_offlineDB setShouldCacheStatements:YES];
    }
    [self.dbLock unlock];
}

#pragma mark - Offline Data
-(NSArray*) getOfflineDataFromDBByKeyword:(NSString*)keyword andPangeIndex:(int)index andPageCount:(int)pageCount
{
    NSMutableArray* rtval = nil;
    if (index < 1 || pageCount < 1) {
        return rtval;
    }
    
    [self.dbLock lock];
    
    index--;
//    if()
    
        NSString* prefix = [NSString stringWithFormat:@"select * from %@ where %@ like '%%", OfflineDatabaseNM, OfflineDBFeedKind];
        NSString* subfix = [NSString stringWithFormat:@"%%'  Limit %d,%d", index * pageCount, pageCount];
        NSString* selectSql = [NSString stringWithFormat:@"%@%@%@", prefix, keyword, subfix];
        FMResultSet *rs = [_offlineDB executeQuery:selectSql];
        while ([rs next])
        {
            if (!rtval)
            {
                rtval = [NSMutableArray arrayWithCapacity:0];
            }
            NSDictionary* resultDic = [rs resultDict];
            if (resultDic) {
                DataModel* offlineQA  = [DataModel objectWithJsonDict:resultDic];
                [rtval addObject:offlineQA];
            }
        }
        [rs close];
    if (rtval.count > 0) {
        [self.dbLock unlock];
        return rtval;
    }
    else
    {
        NSString* prefix = [NSString stringWithFormat:@"select * from %@ where %@ like '%%", OfflineDatabaseNM, OfflineDBFeedTitle];
        NSString* subfix = [NSString stringWithFormat:@"%%'  Limit %d,%d", index * pageCount, pageCount];
        NSString* selectSql = [NSString stringWithFormat:@"%@%@%@", prefix, keyword, subfix];
        FMResultSet *rs = [_offlineDB executeQuery:selectSql];
        while ([rs next])
        {
            if (!rtval)
            {
                rtval = [NSMutableArray arrayWithCapacity:0];
            }
            NSDictionary* resultDic = [rs resultDict];
            if (resultDic) {
                DataModel* offlineQA  = [DataModel objectWithJsonDict:resultDic];
                [rtval addObject:offlineQA];
            }
        }
        [rs close];
        if (rtval.count > 0) {
            [self.dbLock unlock];
            return rtval;
        }
        else
        {
            NSString* prefix = [NSString stringWithFormat:@"select * from %@ where %@ like '%%", OfflineDatabaseNM, OfflineDBFeedResult];
            NSString* subfix = [NSString stringWithFormat:@"%%'  Limit %d,%d", index * pageCount, pageCount];
            NSString* selectSql = [NSString stringWithFormat:@"%@%@%@", prefix, keyword, subfix];
            FMResultSet *rs = [_offlineDB executeQuery:selectSql];
            while ([rs next])
            {
                if (!rtval)
                {
                    rtval = [NSMutableArray arrayWithCapacity:0];
                }
                NSDictionary* resultDic = [rs resultDict];
                if (resultDic) {
                    DataModel* offlineQA  = [DataModel objectWithJsonDict:resultDic];
                    [rtval addObject:offlineQA];
                }
            }
            [rs close];
            
            [self.dbLock unlock];
            return rtval;
        }
    }
    
}

-(NSArray*) getOfflineDataStartFromPage:(int)pageIndex andPageCount:(int)pageCount
{
    NSMutableArray* rtval = nil;
    [self.dbLock lock];
    
    pageIndex--;
    //    if()
    {
        NSString* prefix = [NSString stringWithFormat:@"select * from %@ ", OfflineDatabaseNM];
        NSString* subfix = [NSString stringWithFormat:@" Limit %d,%d", pageIndex * pageCount, pageCount];
        NSString* selectSql = [NSString stringWithFormat:@"%@%@", prefix, subfix];
        FMResultSet *rs = [_offlineDB executeQuery:selectSql];
        while ([rs next])
        {
            if (!rtval)
            {
                rtval = [NSMutableArray arrayWithCapacity:0];
            }
            NSDictionary* resultDic = [rs resultDict];
            if (resultDic) {
                DataModel* offlineQA  = [DataModel objectWithJsonDict:resultDic];
                [rtval addObject:offlineQA];
            }
        }
        [rs close];
    }
    
    [self.dbLock unlock];
    return rtval;
}

-(NSArray*)initTableWithTableName:(NSString*)tableName idList:(NSArray*)idList
{
    NSMutableArray* rtval = nil;
    if (idList&&[idList count]>0) {
        rtval = [[[NSMutableArray alloc] initWithCapacity:[idList count]] autorelease];
        
        NSString* idString = @"";
        for (int i =0; i< [idList count]; i++) {
            NSString* idname = [NSString stringWithFormat:@"%@%d",DataBaseIndex,i];
            [rtval addObject:idname];
            idString = [idString stringByAppendingFormat:@"%@ text,",idname];
        }
        
        NSString* updateSql = [NSString stringWithFormat:@"create table if not exists %@ (%@ rowid text, data blob)",tableName,idString];
        BOOL ret = [_database executeUpdate:updateSql,nil];
        if (!ret) {
            NSLog(@"create database table(%@)error!",tableName);
            NSLog(@"lastErrorMessage=%@",_database.lastErrorMessage);
        }
    }
    return rtval;
}

-(NSString*)searchKeyStringWithIDList:(NSArray*)idList nameList:(NSArray*)nameList
{
    NSString* dataBaseSearchKey = nil;
    if ([nameList count]==[idList count]) {
        for (int i=0; i<[idList count]; i++) {
            NSString* nameString = [nameList objectAtIndex:i];
//            NSString* idString = [idList objectAtIndex:i];
            if (!dataBaseSearchKey) {
                dataBaseSearchKey = @"";
                dataBaseSearchKey = [dataBaseSearchKey stringByAppendingFormat:@"%@=%@",nameString,@"?"];
            }
            else
            {
                dataBaseSearchKey = [dataBaseSearchKey stringByAppendingFormat:@" and %@=%@",nameString,@"?"];
            }
        }

    }
    return dataBaseSearchKey;
}

-(void)removeDataWithTable:(NSString*)tableName idList:(NSArray*)idList
{
    NSArray* dataBaseNameList = [self initTableWithTableName:tableName idList:idList];
    NSString* keyWord = [self searchKeyStringWithIDList:idList nameList:dataBaseNameList];
    if (tableName&&idList&&[idList count]>0) {
        NSString* updateSql = [NSString stringWithFormat:@"Delete from %@ where %@",tableName,keyWord];
        BOOL ret = [_database executeUpdate:updateSql withArgumentsInArray:idList];
        if (!ret) {
            NSLog(@"delete table error!sqlword=%@",updateSql);
            NSLog(@"lastErrorMessage=%@",_database.lastErrorMessage);
        }
    }
}

-(void)realRemoveAllDataWithTable:(NSString*)tableName idList:(NSArray*)idList
{
    NSArray* dataBaseNameList = [self initTableWithTableName:tableName idList:idList];
    NSString* idStirng = @"";
    for (int i=0; i<[dataBaseNameList count]; i++) {
        if (i==0) {
            NSString* key = (NSString*)[dataBaseNameList objectAtIndex:i];
            idStirng = [idStirng stringByAppendingFormat:@"%@ = ?",key];
        }
        else
        {
            NSString* key = (NSString*)[dataBaseNameList objectAtIndex:i];
            idStirng = [idStirng stringByAppendingFormat:@"and %@ = ?",key];
        }
    }
    
    NSString* updateSql = [NSString stringWithFormat:@"delete from %@ where %@",tableName,idStirng];
    NSMutableArray* updateArray = [[NSMutableArray alloc] initWithArray:idList];
    BOOL ret = [_database executeUpdate:updateSql withArgumentsInArray:updateArray];
    if (!ret) {
        NSLog(@"executeUpdate removeall database table error!sql=%@",updateSql);
        NSLog(@"lastErrorMessage=%@",_database.lastErrorMessage);
    }
    [updateArray release];
}

-(void)realRemoveDataOfIndex:(NSInteger)index table:(NSString*)tableName idList:(NSArray*)idList
{
    NSArray* dataBaseNameList = [self initTableWithTableName:tableName idList:idList];
    NSString* idStirng = @"";
    for (int i=0; i<[dataBaseNameList count]; i++) {
        if (i==0) {
            NSString* key = (NSString*)[dataBaseNameList objectAtIndex:i];
            idStirng = [idStirng stringByAppendingFormat:@"%@ = ?",key];
        }
        else
        {
            NSString* key = (NSString*)[dataBaseNameList objectAtIndex:i];
            idStirng = [idStirng stringByAppendingFormat:@"and %@ = ?",key];
        }
    }
    
    idStirng = [idStirng stringByAppendingString:@"and rowid = ?"];
    
    NSString* updateSql = [NSString stringWithFormat:@"delete from %@ where %@",tableName,idStirng];
    NSMutableArray* updateArray = [[NSMutableArray alloc] initWithArray:idList];
    [updateArray addObject:[NSString stringWithFormat:@"%d",index]];
    BOOL ret = [_database executeUpdate:updateSql withArgumentsInArray:updateArray];
    if (!ret) {
        NSLog(@"executeUpdate removeindex database table error!sql=%@",updateSql);
        NSLog(@"lastErrorMessage=%@",_database.lastErrorMessage);
    }
    [updateArray release];
}

-(void)realAddDataWithTable:(NSString*)tableName idList:(NSArray*)idList data:(NSArray*)dataArray
{
    NSArray* dataBaseNameList = [self initTableWithTableName:tableName idList:idList];
    NSString* nameStirng = [dataBaseNameList componentsJoinedByString:@","];
    NSString* idStirng = @"";
    for (int i=0; i<[idList count]; i++) {
        if (i==0) {
            idStirng = [idStirng stringByAppendingString:@"?"];
        }
        else
            idStirng = [idStirng stringByAppendingString:@",?"];
    }
    
    for (int i=0; i<[dataArray count]; i++) {
        NSString* updateSql = [NSString stringWithFormat:@"insert into %@ (%@, rowid, data) values (%@,?,?)",tableName,nameStirng,idStirng];
        NSMutableArray* updateArray = [[NSMutableArray alloc] initWithArray:idList];
        [updateArray addObject:[NSString stringWithFormat:@"%d",i]];
        DataModel* oneObject = [dataArray objectAtIndex:i];
        NSData* oneData = [NSKeyedArchiver archivedDataWithRootObject:oneObject];
        //NSData* oneData = oneObject.data;
        [updateArray addObject:oneData];
        BOOL ret = [_database executeUpdate:updateSql withArgumentsInArray:updateArray];
        if (!ret) {
            NSLog(@"executeUpdate insert database table error!sql=%@",updateSql);
            NSLog(@"lastErrorMessage=%@",_database.lastErrorMessage);
        }
        [updateArray release];
    }
}

-(void)removeAllDataWithTable:(NSString*)tableName idList:(NSArray*)idList
{
    [self.dbLock lock];
    [self realRemoveAllDataWithTable:tableName idList:idList];
    [self.dbLock unlock];
}

-(void)removeDataOfIndex:(NSInteger)index table:(NSString*)tableName idList:(NSArray*)idList
{
    [self.dbLock lock];
    [self realRemoveDataOfIndex:index table:tableName idList:idList];
    [self.dbLock unlock];
}

-(void)addDataWithTable:(NSString*)tableName idList:(NSArray*)idList data:(NSArray*)dataArray
{
    [self.dbLock lock];
    [self realAddDataWithTable:tableName idList:idList data:dataArray];
    [self.dbLock unlock];
}

-(void)refreshDataWithTable:(NSString*)tableName idList:(NSArray*)idList data:(NSArray*)dataArray
{
    [self.dbLock lock];
    [self removeDataWithTable:tableName idList:idList];
    [self realAddDataWithTable:tableName idList:idList data:dataArray];
    [self.dbLock unlock];
}

-(void)realUpdateDataWithTable:(NSString*)tableName idList:(NSArray*)idList data:(DataModel*)oneObject row:(NSInteger)row
{
    NSArray* dataBaseNameList = [self initTableWithTableName:tableName idList:idList];
    NSString* keyWord = [self searchKeyStringWithIDList:idList nameList:dataBaseNameList];
    if (keyWord&&![keyWord isEqualToString:@""]) {
        NSString* updateSql = [NSString stringWithFormat:@"update %@ set data = ? where %@ and rowid = ?",tableName,keyWord];
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:oneObject];
        NSMutableArray* updateArray = [[NSMutableArray alloc] initWithCapacity:0];
        [updateArray addObject:data];
        [updateArray addObjectsFromArray:idList];
        [updateArray addObject:[NSNumber numberWithInt:row]];
        
        BOOL ret = [_database executeUpdate:updateSql withArgumentsInArray:updateArray];
        if (!ret) {
            NSLog(@"executeUpdate update database table error!sql=%@",updateSql);
            NSLog(@"lastErrorMessage=%@",_database.lastErrorMessage);
        }
        [updateArray release];
    }
}

-(void)updateDataWithTable:(NSString*)tableName oneData:(DataModel*)oneObject idList:(NSArray*)idList row:(NSInteger)row
{
    [self.dbLock lock];
    [self realUpdateDataWithTable:tableName idList:idList data:oneObject row:row];
    [self.dbLock unlock];
}

-(NSArray*)loadDataWithTable:(NSString*)tableName idList:(NSArray*)idList
{
    NSMutableArray* rtval = nil;
    [self.dbLock lock];
    NSArray* dataBaseNameList = [self initTableWithTableName:tableName idList:idList];
    NSString* keyWord = [self searchKeyStringWithIDList:idList nameList:dataBaseNameList];
    if (keyWord&&![keyWord isEqualToString:@""]) {
        NSString* updateSql = [NSString stringWithFormat:@"select data from %@ where %@",tableName,keyWord];
        FMResultSet *rs = [_database executeQuery:updateSql withArgumentsInArray:idList];
        while ([rs next]) {
            if (!rtval) {
                rtval = [NSMutableArray arrayWithCapacity:0];
            }
            NSData* data = [rs dataForColumnIndex:0];
            if (data) {
                DataModel* oneObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                //DataModel* oneObject = [[DataModel alloc] initWithNewsData:data];
                [rtval addObject:oneObject];
                //[oneObject release];
            }
            
        }
        [rs close];
    }
    [self.dbLock unlock];
    return rtval;
}

-(NSArray*)initInfoTable
{
    NSMutableArray* rtval = nil;
    
    NSString* infotable = @"_infotable";
    NSString* tableID1 = @"tablename";
    NSString* tableID2 = @"idstring";
    NSString* tableID3 = @"info";
    
    NSString* updateSql = [NSString stringWithFormat:@"create table if not exists %@ (%@ text, %@ text, %@ blob)",infotable,tableID1,tableID2,tableID3];
    BOOL ret = [_database executeUpdate:updateSql,nil];
    if (!ret) {
        NSLog(@"create infotable error!");
        NSLog(@"lastErrorMessage=%@",_database.lastErrorMessage);
    }
    else
    {
        rtval = [NSMutableArray arrayWithCapacity:0];
        [rtval addObject:infotable];
        [rtval addObject:tableID1];
        [rtval addObject:tableID2];
        [rtval addObject:tableID3];
    }
    return rtval;
}

-(void)updateInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList info:(NSDictionary*)info
{
    [self updateInfoTableWithTableName:tableName idList:idList info:info threadLock:YES];
}

-(void)addInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList info:(NSDictionary*)info
{
    [self addInfoTableWithTableName:tableName idList:idList info:info threadLock:YES];
}

-(NSDictionary*)loadInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList
{
    return [self loadInfoTableWithTableName:tableName idList:idList threadLock:YES];
}

-(void)updateInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList info:(NSDictionary*)info threadLock:(BOOL)locked
{
    [self updateInfoTableWithTableName:tableName idList:idList info:info threadLock:YES added:NO];
}

-(void)addInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList info:(NSDictionary*)info threadLock:(BOOL)locked
{
    [self updateInfoTableWithTableName:tableName idList:idList info:info threadLock:YES added:YES];
}

-(void)updateInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList info:(NSDictionary*)info threadLock:(BOOL)locked added:(BOOL)bAdded
{    
    if (locked) {
        [self.dbLock lock];
    }
    NSDictionary* oldInfo = [self loadInfoTableWithTableName:tableName idList:idList threadLock:NO];
    NSArray* tableKeys = [self initInfoTable];
    if (tableKeys&&[tableKeys count]>0) {
        if (oldInfo) {
            NSString* updateSql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ? and %@ = ?",[tableKeys objectAtIndex:0],[tableKeys objectAtIndex:3],[tableKeys objectAtIndex:1],[tableKeys objectAtIndex:2]];
            NSData* data = nil;
            if (bAdded) {
                NSMutableDictionary* newDict = [[NSMutableDictionary alloc] initWithDictionary:oldInfo];
                [newDict addEntriesFromDictionary:info];
                data = [NSKeyedArchiver archivedDataWithRootObject:newDict];
                [newDict release];
            }
            else
            {
                data = [NSKeyedArchiver archivedDataWithRootObject:info];
            }
            NSString* idString = [idList componentsJoinedByString:@"{_}"];
            NSMutableArray* updateArray = [[NSMutableArray alloc] initWithCapacity:3];
            [updateArray addObject:data];
            [updateArray addObject:tableName];
            [updateArray addObject:idString];
            
            BOOL ret = [_database executeUpdate:updateSql withArgumentsInArray:updateArray];
            if (!ret) {
                NSLog(@"executeUpdate update database _infotable error!sql=%@",updateSql);
                NSLog(@"lastErrorMessage=%@",_database.lastErrorMessage);
            }
            [updateArray release];
        }
        else
        {
            NSString* updateSql = [NSString stringWithFormat:@"insert into %@ (%@, %@,%@) values (?,?,?)",[tableKeys objectAtIndex:0],[tableKeys objectAtIndex:1],[tableKeys objectAtIndex:2],[tableKeys objectAtIndex:3]];
            NSMutableArray* updateArray = [[NSMutableArray alloc] initWithCapacity:3];
            NSData* data = [NSKeyedArchiver archivedDataWithRootObject:info];
            NSString* idString = [idList componentsJoinedByString:@"{_}"];
            [updateArray addObject:tableName];
            [updateArray addObject:idString];
            [updateArray addObject:data];
            
            BOOL ret = [_database executeUpdate:updateSql withArgumentsInArray:updateArray];
            if (!ret) {
                NSLog(@"executeUpdate insert _infotable error!sql=%@",updateSql);
                NSLog(@"lastErrorMessage=%@",_database.lastErrorMessage);
            }
            [updateArray release];
        }
    }
    if (locked) {
        [self.dbLock unlock];
    }
}

-(NSDictionary*)loadInfoTableWithTableName:(NSString*)tableName idList:(NSArray*)idList threadLock:(BOOL)locked
{
    NSDictionary* rtval = nil;
    if (locked) {
        [self.dbLock lock];
    }
    NSArray* tableKeys = [self initInfoTable];
    if (tableKeys&&[tableKeys count]>0) {
        NSString* updateSql = [NSString stringWithFormat:@"select %@ from %@ where %@ = ? and %@ = ?",[tableKeys objectAtIndex:3],[tableKeys objectAtIndex:0],[tableKeys objectAtIndex:1],[tableKeys objectAtIndex:2]];
        NSMutableArray* updateArray = [[NSMutableArray alloc] initWithCapacity:2];
        [updateArray addObject:tableName];
        NSString* idString = [idList componentsJoinedByString:@"{_}"];
        [updateArray addObject:idString];
        
        FMResultSet *rs = [_database executeQuery:updateSql withArgumentsInArray:updateArray];
        while ([rs next]) {
            NSData* data = [rs dataForColumnIndex:0];
            if (data) {
                rtval = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if ([rtval isKindOfClass:[NSString class]]) {
                    ;
                }
            }
            break;
        }
        [rs close];
        [updateArray release];
    }
    if (locked) {
        [self.dbLock unlock];
    }
    return rtval;
}

@end

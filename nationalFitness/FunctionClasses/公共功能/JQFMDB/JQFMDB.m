//
//  JQFMDB.m
//
//  Created by Joker on 17/3/7.
//  GitHub: https://github.com/gaojunquan/JQFMDB
//

#import "JQFMDB.h"
#import "FMDB.h"
#import <objc/runtime.h>

// 数据库中常见的几种类型
#define SQL_TEXT     @"TEXT" //文本
#define SQL_INTEGER  @"INTEGER" //int long integer ...
#define SQL_REAL     @"REAL" //浮点
#define SQL_BLOB     @"BLOB" //data

@interface JQFMDB ()

@property (nonatomic, strong)NSString *dbPath;
@property (nonatomic, strong)FMDatabaseQueue *dbQueue;
@property (nonatomic, strong)FMDatabase *db;

//@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation JQFMDB

- (FMDatabaseQueue *)dbQueue
{
    if (!_dbQueue) {
        FMDatabaseQueue *fmdb = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
        self.dbQueue = fmdb;
        [_db close];
        self.db = [fmdb valueForKey:@"_db"];
    }
    return _dbQueue;
}

static JQFMDB *jqdb = nil;
+ (instancetype)shareDatabase
{
    return [JQFMDB shareDatabase:nil];
}

+ (instancetype)shareDatabase:(NSString *)dbName
{
    if ([NFUserEntity shareInstance].userName.length == 0) {
        return nil;
    }
    NSString *dbNameString = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].userName,dbName];
    return [JQFMDB shareDatabase:dbNameString path:nil];
}

// 懒加载数据库队列
- (FMDatabaseQueue *)queue {
    if (_dbQueue == nil) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // 文件路径
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"model.sqlite"];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    }
    return _dbQueue;
}

+ (instancetype)shareDatabase:(NSString *)dbName path:(NSString *)dbPath
{
    
    if (jqdb) {
        if (![jqdb.dbPath containsString:dbName]) {
            //如果已经打开的数据库 不是需要打开的数据则 则关闭
            [jqdb close];
            jqdb = nil;
        }
    }
    if (!jqdb) {
        NSString *path;
        if (!dbName) {
            dbName = @"JQFMDB.sqlite";
        }
        if (!dbPath) {
            path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:dbName];
        } else {
            path = [dbPath stringByAppendingPathComponent:dbName];
        }
        
        FMDatabase *fmdb = [FMDatabase databaseWithPath:path];
        if ([fmdb open]) {
            jqdb = [JQFMDB new];
            jqdb.db = fmdb;
            jqdb.dbPath = path;
        }
    }
    if (![jqdb.db open]) {
        NSLog(@"database can not open !");
        return nil;
    };
    return jqdb;
}

- (instancetype)initWithDBName:(NSString *)dbName
{
    return [self initWithDBName:dbName path:nil];
}

- (instancetype)initWithDBName:(NSString *)dbName path:(NSString *)dbPath
{
    if (!dbName) {
        dbName = @"JQFMDB.sqlite";
    }
    NSString *path;
    if (!dbPath) {
        path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:dbName];
    } else {
        path = [dbPath stringByAppendingPathComponent:dbName];
    }
    
    FMDatabase *fmdb = [FMDatabase databaseWithPath:path];
    
    if ([fmdb open]) {
        self = [self init];
        if (self) {
            self.db = fmdb;
            self.dbPath = path;
            return self;
        }
    }
    return nil;
}

- (BOOL)jq_createTable:(NSString *)tableName dicOrModel:(id)parameters
{
    tableName = [ClearManager NumToString:tableName];
    return [self jq_createTable:tableName dicOrModel:parameters excludeName:nil];
}

- (BOOL)jq_createTable:(NSString *)tableName dicOrModel:(id)parameters excludeName:(NSArray *)nameArr
{
    tableName = [ClearManager NumToString:tableName];
    NSDictionary *dic;
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    } else {
        Class CLS;
        if ([parameters isKindOfClass:[NSString class]]) {
            if (!NSClassFromString(parameters)) {
                CLS = nil;
            } else {
                CLS = NSClassFromString(parameters);
            }
        } else if ([parameters isKindOfClass:[NSObject class]]) {
            CLS = [parameters class];
        } else {
            CLS = parameters;
        }
        dic = [self modelToDictionary:CLS excludePropertyName:nameArr];
    }
    
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE %@ (pkid  INTEGER PRIMARY KEY,", tableName];
    
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        if ((nameArr && [nameArr containsObject:key]) || [key isEqualToString:@"pkid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    BOOL creatFlag;
    creatFlag = [_db executeUpdate:fieldStr];
    
    return creatFlag;
}

- (NSString *)createTable:(NSString *)tableName dictionary:(NSDictionary *)dic excludeName:(NSArray *)nameArr
{
    tableName = [ClearManager NumToString:tableName];
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE %@ (pkid  INTEGER PRIMARY KEY,", tableName];
    
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        if ((nameArr && [nameArr containsObject:key]) || [key isEqualToString:@"pkid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    return fieldStr;
}

- (NSString *)createTable:(NSString *)tableName model:(Class)cls excludeName:(NSArray *)nameArr
{
    tableName = [ClearManager NumToString:tableName];
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE %@ (pkid INTEGER PRIMARY KEY,", tableName];
    
    NSDictionary *dic = [self modelToDictionary:cls excludePropertyName:nameArr];
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        
        if ([key isEqualToString:@"pkid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    return fieldStr;
}

#pragma mark - *************** runtime
- (NSDictionary *)modelToDictionary:(Class)cls excludePropertyName:(NSArray *)nameArr
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (int i = 0; i < outCount; i++) {
        
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if ([nameArr containsObject:name]) continue;
        
        NSString *type = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
        
        id value = [self propertTypeConvert:type];
        if (value) {
            [mDic setObject:value forKey:name];
        }
        
    }
    free(properties);
    
    return mDic;
}

// 获取model的key和value
- (NSDictionary *)getModelPropertyKeyValue:(id)model tableName:(NSString *)tableName clomnArr:(NSArray *)clomnArr
{
//    if (tableName.length < 3) {
//        tableName = @"g";
//    }else{
        tableName = [ClearManager NumToString:tableName];
//    }
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if (![clomnArr containsObject:name]) {
            continue;
        }
        
        id value = [model valueForKey:name];
        if (value) {
            [mDic setObject:value forKey:name];
        }
    }
    free(properties);
    
    return mDic;
}

- (NSString *)propertTypeConvert:(NSString *)typeStr
{
    NSString *resultStr = nil;
    if ([typeStr hasPrefix:@"T@\"NSString\""]) {
        resultStr = SQL_TEXT;
    } else if ([typeStr hasPrefix:@"T@\"NSData\""]) {
        resultStr = SQL_BLOB;
    } else if ([typeStr hasPrefix:@"Ti"]||[typeStr hasPrefix:@"TI"]||[typeStr hasPrefix:@"Ts"]||[typeStr hasPrefix:@"TS"]||[typeStr hasPrefix:@"T@\"NSNumber\""]||[typeStr hasPrefix:@"TB"]||[typeStr hasPrefix:@"Tq"]||[typeStr hasPrefix:@"TQ"]) {
        resultStr = SQL_INTEGER;
    } else if ([typeStr hasPrefix:@"Tf"] || [typeStr hasPrefix:@"Td"]){
        resultStr= SQL_REAL;
    }
    
    return resultStr;
}

// 得到表里的字段名称
- (NSArray *)getColumnArr:(NSString *)tableName db:(FMDatabase *)db
{
//    if (tableName.length < 3) {
//        tableName = @"g";
//    }else{
        tableName = [ClearManager NumToString:tableName];
//    }
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    
    FMResultSet *resultSet = [db getTableSchema:tableName];
    
    while ([resultSet next]) {
        [mArr addObject:[resultSet stringForColumn:@"name"]];
    }
    [resultSet close];
    return mArr;
}

#pragma mark - *************** 增删改查
- (BOOL)jq_insertTable:(NSString *)tableName dicOrModel:(id)parameters
{
//    if (tableName.length < 3) {
//        tableName = @"g";
//    }else{
        tableName = [ClearManager NumToString:tableName];
//    }
    NSArray *columnArr = [self getColumnArr:tableName db:_db];
    return [self insertTable:tableName dicOrModel:parameters columnArr:columnArr];
}

- (BOOL)insertTable:(NSString *)tableName dicOrModel:(id)parameters columnArr:(NSArray *)columnArr
{
//    if (tableName.length < 3) {
//        tableName = @"g";
//    }else{
        tableName = [ClearManager NumToString:tableName];
//    }
    BOOL flag;
    NSDictionary *dic;
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    }else {
        dic = [self getModelPropertyKeyValue:parameters tableName:tableName clomnArr:columnArr];
    }
    
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@ (", tableName];
    NSMutableString *tempStr = [NSMutableString stringWithCapacity:0];
    NSMutableArray *argumentsArr = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *key in dic) {
        
        if (![columnArr containsObject:key] || [key isEqualToString:@"pkid"]) {
            continue;
        }
        [finalStr appendFormat:@"%@,", key];
        [tempStr appendString:@"?,"];
        
        [argumentsArr addObject:dic[key]];
    }
    
    [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length-1, 1)];
    if (tempStr.length)
        [tempStr deleteCharactersInRange:NSMakeRange(tempStr.length-1, 1)];
    
    [finalStr appendFormat:@") values (%@)", tempStr];
    
    flag = [_db executeUpdate:finalStr withArgumentsInArray:argumentsArr];
    return flag;
}

- (BOOL)jq_deleteTable:(NSString *)tableName whereFormat:(NSString *)format, ...
{
    tableName = [ClearManager NumToString:tableName];
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    BOOL flag;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"delete from %@  %@", tableName,where];
    flag = [_db executeUpdate:finalStr];
    
    return flag;
}

#pragma mark - 删除数据库
-(void)dropDatabase{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString  *cachPath = [ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask ,  YES )  objectAtIndex : 0 ];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:cachPath error:NULL];
    for (NSString *path in contents) {
        NSString *tongxunhuihua = [NSString stringWithFormat:@"%@tongxun.sqlite",[NFUserEntity shareInstance].userName];
        NSString *tongxun = [NSString stringWithFormat:@"%@tongxun.sqlite",[NFUserEntity shareInstance].userName];
        NSString *qunliaotongxun = [NSString stringWithFormat:@"%@qunzutongxun.sqlite",[NFUserEntity shareInstance].userName];
        if ([path isEqualToString:tongxunhuihua] || [path isEqualToString:tongxun]  || [path isEqualToString:qunliaotongxun]) {
            NSString *reallyPath = [NSString stringWithFormat:@"%@/%@",cachPath,path];
            if([fileManager fileExistsAtPath:reallyPath]){
                [self close];
                long long size=[fileManager attributesOfItemAtPath:reallyPath error:nil].fileSize;
                BOOL success = [fileManager removeItemAtPath:reallyPath error:&error];
                //                BOOL create = [fileManager createDirectoryAtPath:reallyPath withIntermediateDirectories:NO attributes:nil error:&error];
                long long sizee=[fileManager attributesOfItemAtPath:reallyPath error:nil].fileSize;
                [self open];
                NSLog(@"");
            }
        }
    }
}

- (BOOL)jq_updateTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...
{
    tableName = [ClearManager NumToString:tableName];
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    BOOL flag;
    NSDictionary *dic;
    NSArray *clomnArr = [self getColumnArr:tableName db:_db];
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    }else {
        dic = [self getModelPropertyKeyValue:parameters tableName:tableName clomnArr:clomnArr];
    }
    
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"update %@ set ", tableName];
    NSMutableArray *argumentsArr = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *key in dic) {
        
        if (![clomnArr containsObject:key] || [key isEqualToString:@"pkid"]) {
            continue;
        }
        [finalStr appendFormat:@"%@ = %@,", key, @"?"];
        [argumentsArr addObject:dic[key]];
    }
    
    [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length-1, 1)];
    if (where.length) [finalStr appendFormat:@" %@", where];
    
    
    flag =  [_db executeUpdate:finalStr withArgumentsInArray:argumentsArr];
    return flag;
}

- (NSArray *)jq_lookupTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...
{
    tableName = [ClearManager NumToString:tableName];
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    
    va_end(args);
    NSMutableArray *resultMArr = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *dic;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"select * from %@ %@", tableName, where?where:@""];
    NSArray *clomnArr = [self getColumnArr:tableName db:_db];
    
    FMResultSet *set = [_db executeQuery:finalStr];
    
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
        
        while ([set next]) {
            
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:0];
            for (NSString *key in dic) {
                
                if ([dic[key] isEqualToString:SQL_TEXT]) {
                    id value = [set stringForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                } else if ([dic[key] isEqualToString:SQL_INTEGER]) {
                    [resultDic setObject:@([set longLongIntForColumn:key]) forKey:key];
                } else if ([dic[key] isEqualToString:SQL_REAL]) {
                    [resultDic setObject:[NSNumber numberWithDouble:[set doubleForColumn:key]] forKey:key];
                } else if ([dic[key] isEqualToString:SQL_BLOB]) {
                    id value = [set dataForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                }
                
            }
            
            if (resultDic) [resultMArr addObject:resultDic];
        }
    }else {
        Class CLS;
        if ([parameters isKindOfClass:[NSString class]]) {
            if (!NSClassFromString(parameters)) {
                CLS = nil;
            } else {
                CLS = NSClassFromString(parameters);
            }
        } else if ([parameters isKindOfClass:[NSObject class]]) {
            CLS = [parameters class];
        } else {
            CLS = parameters;
        }
        
        if (CLS) {
            NSDictionary *propertyType = [self modelToDictionary:CLS excludePropertyName:nil];
            
            while ([set next]) {
                id model = [CLS new];
                for (NSString *name in clomnArr) {
                    if ([propertyType[name] isEqualToString:SQL_TEXT]) {
                        id value = [set stringForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_INTEGER]) {
                        [model setValue:@([set longLongIntForColumn:name]) forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_REAL]) {
                        [model setValue:[NSNumber numberWithDouble:[set doubleForColumn:name]] forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_BLOB]) {
                        id value = [set dataForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    }
                }
                [resultMArr addObject:model];
            }
            [set close];
        }
        
    }
    
    return resultMArr;
    
}

- (NSArray *)jq_lookupLastItemTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...
{
    tableName = [ClearManager NumToString:tableName];
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    
    va_end(args);
    NSMutableArray *resultMArr = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *dic;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"select * from %@ %@", tableName, where?where:@""];
    NSArray *clomnArr = [self getColumnArr:tableName db:_db];
    
    FMResultSet *set = [_db executeQuery:finalStr];
    
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
        
        while ([set next]) {
            
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:0];
            for (NSString *key in dic) {
                
                if ([dic[key] isEqualToString:SQL_TEXT]) {
                    id value = [set stringForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                } else if ([dic[key] isEqualToString:SQL_INTEGER]) {
                    [resultDic setObject:@([set longLongIntForColumn:key]) forKey:key];
                } else if ([dic[key] isEqualToString:SQL_REAL]) {
                    [resultDic setObject:[NSNumber numberWithDouble:[set doubleForColumn:key]] forKey:key];
                } else if ([dic[key] isEqualToString:SQL_BLOB]) {
                    id value = [set dataForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                }
                
            }
            
            if (resultDic) [resultMArr addObject:resultDic];
        }
    }else {
        Class CLS;
        if ([parameters isKindOfClass:[NSString class]]) {
            if (!NSClassFromString(parameters)) {
                CLS = nil;
            } else {
                CLS = NSClassFromString(parameters);
            }
        } else if ([parameters isKindOfClass:[NSObject class]]) {
            CLS = [parameters class];
        } else {
            CLS = parameters;
        }
        
        if (CLS) {
            NSDictionary *propertyType = [self modelToDictionary:CLS excludePropertyName:nil];
            
            while ([set next]) {
                id model = [CLS new];
                for (NSString *name in clomnArr) {
                    if ([propertyType[name] isEqualToString:SQL_TEXT]) {
                        id value = [set stringForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_INTEGER]) {
                        [model setValue:@([set longLongIntForColumn:name]) forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_REAL]) {
                        [model setValue:[NSNumber numberWithDouble:[set doubleForColumn:name]] forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_BLOB]) {
                        id value = [set dataForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    }
                }
                [resultMArr addObject:model];
            }
            [set close];
        }
        
    }
    
    return resultMArr;
    
}

// 直接传一个array插入
- (NSArray *)jq_insertTable:(NSString *)tableName dicOrModelArray:(NSArray *)dicOrModelArray
{
    if (dicOrModelArray.count == 0) {
        NSLog(@"\n\n\n空数组\n\n\n");
        return @[];
    }
    tableName = [ClearManager NumToString:tableName];
    int errorIndex = 0;
    NSMutableArray *resultMArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *columnArr = [self getColumnArr:tableName db:_db];
    for (id parameters in dicOrModelArray) {
        
        BOOL flag = [self insertTable:tableName dicOrModel:parameters columnArr:columnArr];
        if (!flag) {
            [resultMArr addObject:@(errorIndex)];
        }
        errorIndex++;
    }
    
    return resultMArr;
}

- (BOOL)jq_deleteTable:(NSString *)tableName
{
    tableName = [ClearManager NumToString:tableName];
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
    return YES;
}


- (BOOL)jq_deleteAllDataFromTable:(NSString *)tableName
{
    tableName = [ClearManager NumToString:tableName];
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - 查本数据库所有表名字
-(NSArray *)jq_selectedAllTableName{
    FMResultSet *set = [_db executeQuery:@"SELECT * FROM sqlite_master where type='table';"];
    set = [_db executeQuery:@"SELECT * FROM sqlite_master where type='table';"];
    NSMutableDictionary *dict = set.columnNameToIndexMap;
    NSMutableArray *arr = [NSMutableArray new];
    while ([set next]){
        
        [arr addObject:[set stringForColumnIndex:1]];
    }
    return [NSArray arrayWithArray:arr];
}

//- (BOOL)jq_deleteAllDataBase:(NSString *)dataBaseName
//{
//    
////    [self close];
//    //删除数据库
//    NSString *sqlstr = [NSString stringWithFormat:@"DROP  %@", dataBaseName];
//    if (![_db executeUpdate:sqlstr])
//    {
//        return NO;
//    }
////    [self open];
//    //删除完新建数据库
//    [JQFMDB shareDatabase:dataBaseName];
//    return YES;
//}

- (BOOL)jq_isExistTable:(NSString *)tableName
{
    tableName = [ClearManager NumToString:tableName];
    FMResultSet *set = [_db executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", tableName];
    while ([set next])
    {
        NSInteger count = [set intForColumn:@"count"];
        if (count == 0) {
            [set close];
            return NO;
        } else {
            [set close];
            return YES;
        }
    }
    [set close];
    return NO;
}

- (NSArray *)jq_columnNameArray:(NSString *)tableName
{
    tableName = [ClearManager NumToString:tableName];
    return [self getColumnArr:tableName db:_db];
}

- (int)jq_tableItemCount:(NSString *)tableName
{
    tableName = [ClearManager NumToString:tableName];
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *set = [_db executeQuery:sqlstr];
    while ([set next])
    {
        int count = [set intForColumn:@"count"];
        [set close];//关闭查询
        return count;
    }
    [set close];
    return 0;
}



//搜索某表中条数据后面数据的条数
- (int)jq_tableItemVagueSearchCount:(NSString *)tableName fkid:(NSString *)fkid
{
    tableName = [ClearManager NumToString:tableName];
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@ where pkid >= %@", tableName,fkid];
    FMResultSet *set = [_db executeQuery:sqlstr];
    while ([set next])
    {
        int count = [set intForColumn:@"count"];
        [set close];//关闭查询
        return count;
    }
    [set close];
    return 0;
}


- (void)close
{
    [_db close];
}

- (void)open
{
    [_db open];
}

- (NSInteger)lastInsertPrimaryKeyId:(NSString *)tableName
{
    tableName = [ClearManager NumToString:tableName];
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM %@ where pkid = (SELECT max(pkid) FROM %@)", tableName, tableName];
    FMResultSet *set = [_db executeQuery:sqlstr];
    while ([set next])
    {
        return [set longLongIntForColumn:@"pkid"];
    }
    [set close];
    return 0;
}

- (BOOL)jq_alterTable:(NSString *)tableName dicOrModel:(id)parameters
{
    tableName = [ClearManager NumToString:tableName];
    return [self jq_alterTable:tableName dicOrModel:parameters excludeName:nil];
}

- (BOOL)jq_alterTable:(NSString *)tableName dicOrModel:(id)parameters excludeName:(NSArray *)nameArr
{
    tableName = [ClearManager NumToString:tableName];
    __block BOOL flag;
    [self jq_inTransaction:^(BOOL *rollback) {
        if ([parameters isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in parameters) {
                if ([nameArr containsObject:key]) {
                    continue;
                }
                flag = [_db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, key, parameters[key]]];
                if (!flag) {
                    *rollback = YES;
                    return;
                }
            }
            
        } else {
            Class CLS;
            if ([parameters isKindOfClass:[NSString class]]) {
                if (!NSClassFromString(parameters)) {
                    CLS = nil;
                } else {
                    CLS = NSClassFromString(parameters);
                }
            } else if ([parameters isKindOfClass:[NSObject class]]) {
                CLS = [parameters class];
            } else {
                CLS = parameters;
            }
            NSDictionary *modelDic = [self modelToDictionary:CLS excludePropertyName:nameArr];
            NSArray *columnArr = [self getColumnArr:tableName db:_db];
            for (NSString *key in modelDic) {
                if (![columnArr containsObject:key] && ![nameArr containsObject:key]) {
                    flag = [_db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, key, modelDic[key]]];
                    if (!flag) {
                        *rollback = YES;
                        return;
                    }
                }
            }
        }
    }];
    
    return flag;
}

#pragma mark - 模糊搜索
-(NSArray *)jq_SearchTable:(NSString *)tableName dicOrModel:(id)parameters Key:(NSString *)key Value:(NSString *)value{
    NSMutableArray *backArr = [NSMutableArray new];
    tableName = [ClearManager NumToString:tableName];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIKE '%%%@%%'",tableName,key,value];//模糊查询，查找alpha中 以 item.dream_keyword开头的内容
//    sql =[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ like BINARY '%@%%'",tableName,key,value];
//    sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE locate('%@','%@')>0",tableName,key,value];
    NSArray *clomnArr = [self getColumnArr:tableName db:_db];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    FMResultSet *set = [_db executeQuery:sql];
    Class CLS;
    CLS = [parameters class];
    if (CLS) {
        NSDictionary *propertyType = [self modelToDictionary:CLS excludePropertyName:nil];
        while ([set next])
        {
            id model = [CLS new];
            for (NSString *name in clomnArr) {
                if ([propertyType[name] isEqualToString:SQL_TEXT]) {
                    id value = [set stringForColumn:name];
                    if (value)
                        [model setValue:value forKey:name];
                } else if ([propertyType[name] isEqualToString:SQL_INTEGER]) {
                    [model setValue:@([set longLongIntForColumn:name]) forKey:name];
                } else if ([propertyType[name] isEqualToString:SQL_REAL]) {
                    [model setValue:[NSNumber numberWithDouble:[set doubleForColumn:name]] forKey:name];
                } else if ([propertyType[name] isEqualToString:SQL_BLOB]) {
                    id value = [set dataForColumn:name];
                    if (value)
                        [model setValue:value forKey:name];
                }
            }
            [backArr addObject:model];
        }
        [set close];
    }
    return backArr;
}

#pragma mark - 表中条件为xxx的数据个数是多少
- (int)jq_tableItemCount:(NSString *)tableName whereFormat:(NSString *)format, ...
{
    tableName = [ClearManager NumToString:tableName];
//    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"select * from %@ %@", tableName, where?where:@""];
    FMResultSet *set = [_db executeQuery:finalStr];
    while ([set next])
    {
        int count = [set intForColumn:@"count"];
        [set close];//关闭查询
        return count;
    }
    [set close];
    return 0;
}



// =============================   线程安全操作    ===============================

- (void)jq_inDatabase:(void(^)(void))block
{
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        block();
    }];
}

- (void)jq_inTransaction:(void(^)(BOOL *rollback))block
{
    
    [[self dbQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        block(rollback);
    }];
    
}

-(ClearManager *)myManage{
    if (!_myManage) {
        _myManage = [[ClearManager alloc] init];
    }
    return _myManage;
}



@end


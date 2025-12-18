//
//  DatabaseQueue.m
//  SummaryHoperun
//
//  Created by 程long on 14-7-30.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "DatabaseQueue.h"
#import "PublicDefine.h"

static NSString *databasePath = nil;
static FMDatabaseQueue *queue = nil;

@implementation DatabaseQueue

+ (FMDatabaseQueue *)shareInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                        stringByAppendingPathComponent: kFMDBFilename];
        
        queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        
        /*
        //数据库加密
        FMDatabase *db = [queue valueForKey:@"_db"];
        //对打开的数据库进行加密（新的数据库）或者解密（已经加密的数据库），在数据库关闭之前，这个方法只能使用一次
        if ([db setKey:databaseKey])
        {
            NSLog(@"encrypt success");
        }
        */
        
    });
    
    return queue;
}

@end

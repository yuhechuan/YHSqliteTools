//
//  SqliteManager.m
//  YHCSqliteTools
//
//  Created by apple on 9/8/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "SqliteManager.h"
#import "JSONKit.h"


@interface SqliteManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue; // 线程安全的数据库操作类;
@property (nonatomic, copy) NSString *dbFile;           //数据库文件路径

@end

@implementation SqliteManager

/**
 * 初始化数据对象
 * @param defineFileName :  数据库定义文件
 * @param  filePath : 数据库文件路径
 */
- (instancetype)initWithDBDefine:(NSString * )bundleName filePath:(NSString *)filePath {
    if (self =[super init]) {
        self.dbFile = filePath;
        [self loadTableDefinition:bundleName];
    }
    return self;
}

//根据bundleName创建所有表
- (void)loadTableDefinition:(NSString *)bundleName {
    NSArray *definitionArray = [self readTableDefinition:bundleName];
    __weak SqliteManager *weakSelf = self;
    for (NSDictionary *tableDef in definitionArray) {
        [weakSelf.dbQueue inDatabase:^(FMDatabase *db) {
            [weakSelf createTableWithConfig:tableDef withDb:db];
        }];
    }
}

/**
 * 根据定义创建数据库表
 *
 */
- (BOOL)createTableWithConfig:(NSDictionary *)tableDefine withDb:(FMDatabase *)db{
    //表名
    NSString *tableName = [tableDefine objectForKey:@"table"];
    //主键
    NSString *pkStr = [tableDefine objectForKey:@"key"];
    //字段数组
    NSArray *columns = [tableDefine objectForKey:@"cols"];
    //表定义组装字符串
    NSMutableString *table_pars =[NSMutableString string];
    for (int i = 0; i < columns.count; i++) {
        if (i > 0) {
            [table_pars appendString:@","];
        }
        NSDictionary * columnDefine = [columns objectAtIndex:i];
        NSString *columnName = columnDefine[@"name"];
        NSString *columnType = columnDefine[@"type"];
        [table_pars appendFormat:@"%@ %@",columnName,columnType];
        if ([columnName isEqualToString:pkStr]) {
            //构造主键
            [table_pars appendString:@" primary key not null"];
        }
    }
    //创建表
    NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)",tableName,table_pars];
    BOOL isCreate = [db executeStatements:createTableSQL];
    
    return isCreate;
}

//获取表定义
- (NSArray *)readTableDefinition:(NSString *)bundleName {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSBundle *tableBundle = [NSBundle bundleWithPath:bundlePath];
    NSArray *tableFiles =[tableBundle pathsForResourcesOfType:@"strings" inDirectory:nil];
    __block NSMutableArray *pathArray = [NSMutableArray array];
    [tableFiles enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *jsonData = [NSData dataWithContentsOfFile:path];
        NSDictionary *tableDef = [jsonData objectFromJSONData];
        [pathArray addObject:tableDef];
    }];
    return pathArray;
}

/**
 *  关闭数据库
 */
- (void)closeDataBase {
    NSLog(@"关闭数据库连接");
    if (self.dbQueue) {
        [self.dbQueue close];
        _dbQueue = nil;
    }
}

- (FMDatabaseQueue *)dbQueue {
    if (!_dbQueue) {
        _dbQueue =[[FMDatabaseQueue alloc]initWithPath:self.dbFile];
    }
    return _dbQueue;
}


@end

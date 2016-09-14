//
//  SQBaseDAO.m
//  SqliteTools
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "SQBaseDAO.h"
#import "SqliteManager.h"
#import "FMDB.h"
#import "SQliteUser.h"

@implementation SQBaseDAO

-(NSString *)getPK {
    return @"需要子类实现";
}

- (NSString *)getTable {
    return @"需要子类实现";
}

- (SqliteManager *)getDataSource {
    return [[SQliteUser sharedInstance] manager];
}

/**
 *  保存数据
 *
 *  @param data 数据
 */

- (BOOL)save:(NSDictionary *)data {
    //save
    BOOL successFlag = false;
    if ([self isContainPK:data] && [self isExistPkData:data]) {
        //更新
        successFlag = [self modify:data];
    } else {
        //保存
        successFlag = [self insert:data];
    }
    return successFlag;
}

/**
 *  根据主键获取数据对象
 *
 *  @param pk 转
 *
 *  @return 数据对象字典
 */
- (NSDictionary *)fetchObjectWithPK:(NSString *)pk {
    if (pk.length == 0) {
        return nil;
    }
    NSString * pkCode = [self getPK];
    SQConditionBean * condition = [[SQConditionBean alloc] init];
    [condition set:pk forKey:pkCode];
    NSArray * result = [self query:condition];
    if (result.count > 0) {
        return [result objectAtIndex:0];
    } else {
        return  nil;
    }
}

/**
 *  使用主键删除数据
 *
 *  @param pk 主键
 */
- (BOOL)deleteWithPK:(NSString *)pk {
    //delete pk
    NSString * pkCode = [self getPK];
    SQConditionBean *condition = [[SQConditionBean alloc] init];
    [condition set:pk forKey:pkCode];
    return [self remove:condition];
}

/**
 *  查询数据
 *
 *  @param condition 查询条件
 */
- (NSArray *)fetchList:(SQConditionBean *)condition {
    return [self query:condition];
}


- (BOOL)isExistPkData:(NSDictionary *)dict {
    NSString * pkCode = [self getPK];
    NSDictionary * result =[self fetchObjectWithPK:[dict objectForKey:pkCode]];
    if (!result ||  result.allKeys.count == 0) {
        return NO;
    } else {
        return YES;
    }
}

//是否包含主键
- (BOOL)isContainPK:(NSDictionary *)dict {
    NSString * pkCode = [self getPK];
    if ([[dict allKeys] containsObject: pkCode]) {
        return YES;
    }
    return NO;
}


//增
- (BOOL)insert:(NSDictionary *)data {
    //安全线程
    FMDatabaseQueue *dbQueue = [[self getDataSource] dbQueue];
    __block BOOL execute = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSMutableDictionary *mData = [NSMutableDictionary dictionaryWithDictionary:data];
        NSString *pk = [self getPK];//主键
        NSString * table = [self getTable];//表名
        //如果主键没值,主动生成主键
        if (![mData objectForKey:pk]) {
            [mData setObject:[[NSUUID UUID] UUIDString] forKey:pk];
        }
        NSMutableString *insertKey = [NSMutableString stringWithCapacity:0];
        NSMutableString *insertValuesString = [[NSMutableString alloc] init];
        NSMutableArray *insertValues = [[NSMutableArray alloc] init];
        NSArray *columnArray = [mData allKeys];
        for (int i = 0; i < columnArray.count; i++) {
            NSString *columnName = columnArray[i];
            id value = [mData objectForKey:columnName];
            if (!value) {
                continue;
            }
            if (insertKey.length > 0) {
                [insertKey appendString:@","];
                [insertValuesString appendString:@","];
            }
            
            [insertKey appendString:columnName];
            [insertValuesString appendString:@"?"];
            
            [insertValues addObject:value];
        }
        // 拼接insertSQL 语句  采用 replace 插入
        NSString *insertSQL = [NSString stringWithFormat:@"replace into %@(%@) values(%@)", table, insertKey, insertValuesString];
        execute = [db executeUpdate:insertSQL withArgumentsInArray:insertValues];
        
    }];
    return execute;
}
//删
- (BOOL)remove:(SQConditionBean *)condition {
    FMDatabaseQueue *dbQueue = [[self getDataSource] dbQueue];
    __block BOOL execute = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *table = [self getTable];
        NSMutableString *deleteSQL = [NSMutableString stringWithFormat:@"delete from %@  ", table];
        // 添加where 语句
        NSMutableArray *valuearray = [NSMutableArray array];
        //获取条件字符串
        NSDictionary *dict = [condition conditionDict];
        NSString *sqlwhere = [self dictionaryToSqlWhere:dict andValues:valuearray];
        if (sqlwhere.length > 0) {
            [deleteSQL appendString:@" where "];
            [deleteSQL appendString:sqlwhere];
        }
        execute = [db executeUpdate:deleteSQL withArgumentsInArray:valuearray];

    }];
    return execute;
}
//改
- (BOOL)modify:(NSDictionary *)data {
    FMDatabaseQueue *dbQueue = [[self getDataSource ] dbQueue];
    __block BOOL execute = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *pk = [self getPK];//主键
        NSString * table = [self getTable];//表名
        NSMutableString *updateKey = [NSMutableString string];//更新key集合
        NSMutableArray *updateValues = [[NSMutableArray alloc] init];//更新的value集合
        NSArray *columnArray = data.allKeys;
        for (NSString *key in columnArray) {
            //不是主键字段
            if (![key isEqualToString:pk]) {
                if (updateKey.length > 0) {
                    [updateKey appendString:@","];
                }
                [updateKey appendFormat:@"%@=?", key];
            }
            id value = [data objectForKey:key];
            [updateValues addObject:value];
        }
        NSMutableString *updateSQL = [NSMutableString stringWithFormat:@"update %@ set %@ where %@=?", table, updateKey,[updateValues lastObject]];
        execute = [db executeUpdate:updateSQL withArgumentsInArray:updateValues];
    }];
    return execute;
}
//查
- (NSMutableArray *)query:(SQConditionBean *)condition{
    FMDatabaseQueue *dbQueue = [[self getDataSource ] dbQueue];
    __block NSMutableArray *results = [[NSMutableArray alloc] init];
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString * table = [self getTable];
        NSString *columnsString = @"*";
        
        //build query
        NSMutableString *query = [NSMutableString stringWithFormat:@"select %@ from %@", columnsString, table];
        NSMutableArray *whereValues = [NSMutableArray array];
        
        //build where
        NSString *wherekey = [self dictionaryToSqlWhere:[condition conditionDict] andValues:whereValues];
        if ( wherekey.length > 0) {
            [query appendFormat:@" where %@", wherekey];
        }
        
        //execute
        FMResultSet *set = nil;
        if (whereValues.count == 0) {
            set = [db executeQuery:query];
        } else {
            set = [db executeQuery:query withArgumentsInArray:whereValues];
        }
        
        while ([set next]) {
            NSDictionary *rowData = [self resultToDic:set];
            [results addObject:rowData];
        }
        [set close];

    }];
    return results;
}

//判断拼接where语句
- (NSString *)dictionaryToSqlWhere:(NSDictionary *)dict andValues:(NSMutableArray *)values {
    NSMutableString *wherekey = [NSMutableString stringWithCapacity:0];
    if (dict && dict.count > 0) {
        NSArray *keys = dict.allKeys;
        for (NSString *key in keys) {
            id va = [dict objectForKey:key];
            //拼接 AND链接符
            if (wherekey.length > 0) {
                [wherekey appendString:@" and"];
            }
            //判断是否包含操作符 !
            if ([self hasOperator:key]) {
                [wherekey appendFormat:@" %@ ?", key];
                [values addObject:va];
            } else {
                [wherekey appendFormat:@" %@=?", key];
                [values addObject:va];
            }
        }
    }
    return wherekey;
}

/**
 * 是否包含操作符
 *
 */
- (BOOL)hasOperator:(NSString *)str {
    str = [self trim: str];
    NSRegularExpression * regExp = [NSRegularExpression regularExpressionWithPattern: @"(\\s|<|>|!|=|is null|is not null|like)" options: NSRegularExpressionCaseInsensitive error: nil];
    NSRange range = [regExp rangeOfFirstMatchInString: str options:0 range: NSMakeRange(0, str.length)];
    if (NSNotFound == range.location) {
        return NO;
    }
    
    return YES;
}

//去掉特殊符号 空格
- (NSString *)trim:(NSString *)str {
    return [[NSString stringWithFormat:@"%@", str] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

//根据条件拼接sql语句
- (void)sqlString:(NSMutableString *)sql groupBy:(NSString *)groupBy orderBy:(NSString *)orderby offset:(NSInteger)offset count:(NSInteger)count
{
    if (nil != groupBy && groupBy.length > 0) {
        [sql appendFormat:@" group by %@", groupBy];
    }
    if (nil != orderby && orderby.length > 0) {
        [sql appendFormat:@" order by %@", orderby];
    }
    if (count > 0) {
        [sql appendFormat:@" limit %ld offset %ld", (long)count, (long)offset];
    } else if (offset > 0) {
        [sql appendFormat:@" limit %d offset %ld", INT_MAX, (long)offset];
    }
}

//FMResultSet对象转字典
- (NSDictionary *)resultToDic:(FMResultSet *)result {
    NSUInteger num_cols = (NSUInteger)sqlite3_data_count([result.statement statement]);
    if (num_cols > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:num_cols];
        int columnCount = sqlite3_column_count([result.statement statement]);
        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name([result.statement statement], columnIdx)];
            id objectValue =[ result objectForColumnIndex:columnIdx];
            if (![objectValue isKindOfClass:[NSNull class]]) {
                [dict setObject:objectValue forKey:columnName];
            }
        }
        return dict;
    } else {
        NSLog(@"Warning: There seem to be no columns in this set.");
    }
    return nil;
}

@end

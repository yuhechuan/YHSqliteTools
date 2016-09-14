//
//  ISQDAO.h
//  SqliteTools
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 apple. All rights reserved.
//
#import <Foundation/Foundation.h>

@class SqliteManager;

@protocol IRHDAO <NSObject>

@required

/**
 *  获取表名，子类必须覆盖
 *
 *  @return 表名
 */
- (NSString *)getTable;

/**
 *  获取主键，子类必须覆盖
 *
 *  @return 主键
 */
- (NSString *)getPK;

/**
 *
 * 获取数据源
 */
- (SqliteManager *)getDataSource;

@end

//
//  SQBaseDAO.h
//  SqliteTools
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISQDAO.h"

@interface SQBaseDAO : NSObject<IRHDAO>

/**
 *  保存数据
 *
 *  @param data 数据
 */
- (BOOL)save:(NSDictionary *)data;

/**
 *  根据主键获取数据对象
 *
 *  @param pk 转
 *
 *  @return 数据对象字典
 */
- (NSDictionary *)fetchObjectWithPK:(NSString *)pk;


/**
 *  查询数据
 *
 *  @param condition 查询条件
 */
- (NSArray *)fetchList:(SQConditionBean *)condition;

/**
 *  使用主键删除数据
 *
 *  @param pk 主键
 */
- (BOOL)deleteWithPK:(NSString *)pk;


@end

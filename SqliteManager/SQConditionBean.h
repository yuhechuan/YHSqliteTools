//
//  SQConditionBean.h
//  SqliteTools
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQConditionBean : NSObject

@property (nonatomic, strong) NSMutableDictionary *conditionDict;


/**
 *  添加条件(操作符是AND)
 *
 *  @param value 值
 *  @param key   字段
 */
-(void) set:(id)value forKey:(NSString *)key;

/**
 *  添加  != 条件 (操作符是AND)
 *
 *  @param value 值
 *  @param key   字段
 */
-(void) andNE:(id)value forKey:(NSString *)key;

@end

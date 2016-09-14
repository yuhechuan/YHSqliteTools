//
//  SQConditionBean.m
//  SqliteTools
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "SQConditionBean.h"

@implementation SQConditionBean

@synthesize conditionDict;

- (instancetype)init {
    self = [super init];
    if (self) {
        conditionDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

/**
 *  添加条件(操作符是AND)
 *
 *  @param value 值
 *  @param key   字段
 */
-(void) set:(id)value forKey:(NSString *)key {
    if (value) {
        [conditionDict setValue:value forKey:key];
    }
}


/**
 *  添加  != 条件 (操作符是AND)
 *
 *  @param value 值
 *  @param key   字段
 */
-(void) andNE:(id)value forKey:(NSString *)key {
    NSString * query =  [NSString stringWithFormat:@"%@ != ", key];
    [conditionDict setValue:value forKey:query];
}

@end

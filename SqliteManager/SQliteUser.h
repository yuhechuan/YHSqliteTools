//
//  SQliteUser.h
//  SqliteTools
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqliteManager.h"

@interface SQliteUser : NSObject
//单例宏模块
SINGLETON_FOR_HEADER(SQliteUser);

//保证数据库只创建一次
- (SqliteManager *)manager;

@end

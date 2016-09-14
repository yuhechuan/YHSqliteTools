//
//  SQliteUser.m
//  SqliteTools
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "SQliteUser.h"

@interface SQliteUser ()

@property (nonatomic, strong) SqliteManager *manager;

@end

@implementation SQliteUser

SINGLETON_FOR_CLASS(SQliteUser);

- (SqliteManager *)manager {
    if (_manager) {
        return _manager;
    }
    @synchronized(self) {
        if (!_manager) {
             NSString *dbPath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/yuhechuan.db"];
            _manager = [[SqliteManager alloc] initWithDBDefine:@"user" filePath:dbPath];
        }
    }
    return _manager;
}

@end

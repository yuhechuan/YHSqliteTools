//
//  SQFriendsDAO.m
//  SqliteTools
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "SQFriendsDAO.h"

@implementation SQFriendsDAO

-(NSString *)getPK {
    return @"USER_CODE";
}

- (NSString *)getTable {
    return @"user_friends";
}

@end

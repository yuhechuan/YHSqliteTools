//
//  SQSingleton.h
//  SqliteTools
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 apple. All rights reserved.
//

#ifndef SQSingleton_h
#define SQSingleton_h

/**
 *  单例模式宏模板
 */
#define SINGLETON_FOR_HEADER(className) \
\
+ (className *)sharedInstance;

#define SINGLETON_FOR_CLASS(className) \
\
+ (className *)sharedInstance { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}

#endif /* SQSingleton_h */

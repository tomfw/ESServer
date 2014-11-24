//
// Created by Thomas Williams on 11/9/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "DBCoder.h"


@interface User : NSObject <DBCoding, NSCoding>

@property (readonly, nonatomic) NSInteger userID;
@property (readonly, nonatomic) NSString *userName;

+ (User *)userWithName:(NSString *)name;
+ (User *)userWithID:(NSInteger)userID;
- (instancetype)initWithName:(NSString *)name;
@end
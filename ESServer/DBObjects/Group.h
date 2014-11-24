//
// Created by Thomas Williams on 11/10/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "DBCoder.h"


@interface Group : NSObject <NSCoding, DBCoding>

@property(readonly, nonatomic) NSInteger grpID;
@property(readonly, nonatomic) NSString *grpName;
@property(readonly, nonatomic) NSString *grpDescription;
@property (strong, nonatomic) NSMapTable *users;

- (instancetype)initWithGroup:(Group *)group;
+(Group *)groupWithName:(NSString *)name description:(NSString *)description;
+(Group *)groupWithID:(NSInteger)id;
@end
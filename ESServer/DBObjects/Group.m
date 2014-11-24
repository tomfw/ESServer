//
// Created by Thomas Williams on 11/10/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import "Group.h"
#import "DatabaseManager.h"
#import "User_Group.h"
#import "User.h"

@interface Group ()
@property (nonatomic) NSInteger grpID;
@property (strong, nonatomic) NSString *grpName;
@property (strong, nonatomic) NSString *grpDescription;
@end

@implementation Group

- (NSString *)tableName {
    return @"GROUPS";
}

- (NSArray *)primaryKeyColumns {
    return @[@"grpID"];
}

- (void)encodeWithDBCoder:(DBCoder *)coder {
    [coder encodeInt:self.grpID forColumn:@"grpID"];
    [coder encodeString:self.grpName forColumn:@"grpName"];
    [coder encodeString:self.grpDescription forColumn:@"grpDescription"];
}

- (id)initWithDBCoder:(DBCoder *)coder {
    if (self = [super init]) {
        _grpID = [coder intForColumn:@"grpID"];
        _grpName = [coder stringForColumn:@"grpName"];
        _grpDescription = [coder stringForColumn:@"grpDescription"];
        [self loadUsers];
    }
    return self;
}

- (void)loadUsers {
    self.users = [NSMapTable strongToStrongObjectsMapTable];
    DatabaseManager *manager = [DatabaseManager manager];
    NSArray *user_groups = [manager loadObjectsWithTemplate:[User_Group userGroupWithUser:0 inGroup:self.grpID]];
    for (User_Group *user_group in user_groups) {
        [self.users setObject:[manager loadObjectWithTemplate:[User userWithID:user_group.userID]] forKey:@(user_group.userID)];
    }
}


- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.grpID forKey:@"grpID"];
    [coder encodeObject:self.grpName forKey:@"grpName"];
    [coder encodeObject:self.grpDescription forKey:@"grpDescription"];
    [coder encodeObject:self.users forKey:@"users"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _grpID = [coder decodeIntegerForKey:@"grpID"];
        _grpName = [coder decodeObjectForKey:@"grpName"];
        _grpDescription = [coder decodeObjectForKey:@"grpDescription"];
        _users = [coder decodeObjectForKey:@"users"];
    }
    return self;
}

-(instancetype)initWithGroup:(Group *)group {
    if (self = [super init]) {
        _grpID = [[DatabaseManager manager] nextValueForID:@"grpID"];
        _grpName = group.grpName;
        _grpDescription = group.grpDescription;
    }
    return self;
}


+ (Group *)groupWithName:(NSString *)name description:(NSString *)description {
    Group *new = [self groupWithID:-1];
    new.grpName = name;
    new.grpDescription = description;
    return new;
}

+ (Group *)groupWithID:(NSInteger)id {
    Group *new = [[Group alloc] init];
    new.grpID = id;
    return new;
}

@end
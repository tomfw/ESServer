//
// Created by Thomas Williams on 11/10/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import "Expense.h"

@interface Expense ()
@end

@implementation Expense

- (NSString *)tableName {
    return @"EXPENSES";
}

- (NSArray *)primaryKeyColumns {
    return @[@"expenseID"];
}

- (void)encodeWithDBCoder:(DBCoder *)coder {
    [coder encodeInt:self.expenseID forColumn:@"expenseID"];
    [coder encodeInt:self.grpID forColumn:@"grpID"];
    [coder encodeInt:self.userID forColumn:@"userID"];
    [coder encodeString:self.item forColumn:@"item"];
    [coder encodeDouble:self.amount forColumn:@"amount"];
    [coder encodeString:self.memo forColumn:@"memo"];
    [coder encodeInt:self.month forColumn:@"month"];
    [coder encodeInt:self.year forColumn:@"year"];
}

- (id)initWithDBCoder:(DBCoder *)coder {
    if (self = [super init]) {
        _expenseID = [coder intForColumn:@"expenseID"];
        _grpID = [coder intForColumn:@"grpID"];
        _userID = [coder intForColumn:@"userID"];
        _item = [coder stringForColumn:@"item"];
        _amount = [coder doubleForColumn:@"amount"];
        _memo = [coder stringForColumn:@"memo"];
        _month = [coder intForColumn:@"month"];
        _year = [coder intForColumn:@"year"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.expenseID forKey:@"expenseID"];
    [coder encodeInteger:self.grpID forKey:@"grpID"];
    [coder encodeInteger:self.userID forKey:@"userID"];
    [coder encodeObject:self.item forKey:@"item"];
    [coder encodeDouble:self.amount forKey:@"amount"];
    [coder encodeObject:self.memo forKey:@"memo"];
    [coder encodeInteger:self.month forKey:@"month"];
    [coder encodeInteger:self.year forKey:@"year"];
    //encode receipt
}

- (id)initWithCoder:(NSCoder *)coder {
    if(self = [super init]) {
        _expenseID = [coder decodeIntegerForKey:@"expenseID"];
        _grpID = [coder decodeIntegerForKey:@"grpID"];
        _userID = [coder decodeIntegerForKey:@"userID"];
        _item = [coder decodeObjectForKey:@"item"];
        _amount = [coder decodeDoubleForKey:@"amount"];
        _memo = [coder decodeObjectForKey:@"memo"];
        _month = [coder decodeIntegerForKey:@"month"];
        _year = [coder decodeIntegerForKey:@"year"];
        //decode receipt
    }
    return self;
}

+ (Expense *)expenseInGroup:(NSInteger)grpID byUser:(NSInteger)userID {
    Expense *new = [Expense expenseWithID:0];
    new.grpID = grpID;
    new.userID = userID;
    return new;
}

+ (Expense *)expenseWithID:(NSInteger)expenseID {
    Expense *new = [[Expense alloc] init];
    new.expenseID = expenseID;
    return new;
}


@end
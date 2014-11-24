//
// Created by Thomas Williams on 11/10/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "DBCoder.h"


@interface Expense : NSObject <NSCoding, DBCoding>

@property(nonatomic) NSInteger expenseID;
@property(nonatomic) NSInteger grpID;
@property(nonatomic) NSInteger userID;
@property(strong, nonatomic) NSString *item;
@property(nonatomic) double amount;
@property(strong, nonatomic) NSString *memo;
@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger year;

+(Expense *)expenseInGroup:(NSInteger)grpID byUser:(NSInteger)userID;
+(Expense *)expenseWithID:(NSInteger)expenseID;
@end
//
// Created by Thomas Williams on 11/10/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "DBCoder.h"


@interface Reimbursement : NSObject <NSCoding, DBCoding>


@property(nonatomic) NSInteger reimbursementID;
@property(readonly, nonatomic) NSInteger payerID;
@property(readonly, nonatomic) NSInteger payeeID;
@property(readonly, nonatomic) NSInteger grpID;
@property (nonatomic) double amount;
@property (strong, nonatomic) NSString *memo;
@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger year;


+(Reimbursement *)reimbursementFrom:(NSInteger)payerID to:(NSInteger)payeeID inGroup:(NSInteger)grpID;
+(Reimbursement *)reimbursementWithID:(NSInteger)id;

@end
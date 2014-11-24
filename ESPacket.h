//
// Created by Thomas Williams on 11/6/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class GCDAsyncSocket;

//requests for data
#define ESPACKET_REQUEST_GROUPS 100
#define ESPACKET_REQUEST_MEMBERS 101
#define ESPACKET_REQUEST_UPDATE 102
#define ESPACKET_REQUEST_EXPENSES 103
#define ESPACKET_REQUEST_REIMBURSEMENTS 104
#define ESPACKET_REQUEST_TRANSACTIONS 105

//requests to edit database
#define ESPACKET_REGISTER 200
#define ESPACKET_ADD_GROUP 201
#define ESPACKET_ADD_EXPENSE 202
#define ESPACKET_ADD_REIMBURSMENT 203

//responses
#define ESPACKET_GROUPS 300
#define ESPACKET_ASSIGN_USERID 301
#define ESPACKET_OK 302
#define ESPACKET_UPDATE_HASH 303
#define ESPACKET_EXPENSES 304
#define ESPACKET_REIMBURSEMENTS 305


//tags
#define TAG_READ_USER_ID 1000
#define TAG_READ_PACKET 1001
#define TAG_WRITE_PACKET 1002


@interface ESPacket : NSObject <NSCoding>

@property (nonatomic) NSInteger code;
@property (strong, nonatomic) id<NSCoding> object;


+ (NSData *)terminator;
- (void)sendOnSocket:(GCDAsyncSocket *)sock withTimeOut:(NSTimeInterval)timeout;
+ (void)readOnSocket:(GCDAsyncSocket *)sock withTimeOut:(NSTimeInterval)timeout;
+ (ESPacket *)packetWithCode:(NSInteger)code object:(id <NSCoding>)obj;
- (instancetype)initWithCode:(NSInteger)code object:(id <NSCoding>)obj;
@end
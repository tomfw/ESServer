//
// Created by Thomas Williams on 11/5/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@class ESClient;

@protocol ESClientDelegate
    -(void)client:(ESClient *)client disconnectedWithID:(NSInteger)id;
@end

@interface ESClient : NSObject

@property(readonly, nonatomic) NSInteger userID;

- (instancetype)initWithConnectionID:(NSInteger)connID socket:(GCDAsyncSocket *)sock delegate:(id <ESClientDelegate>)delegate;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToClient:(ESClient *)client;
- (NSUInteger)hash;
@end
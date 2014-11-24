//
// Created by Thomas Williams on 11/6/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import "ESPacket.h"
#import "GCDAsyncSocket.h"


@implementation ESPacket

+ (NSData *)terminator {
    return [NSData dataWithBytes:"\x0D\x0A\x0B\x0A" length:4];
}

-(void)sendOnSocket:(GCDAsyncSocket *)sock withTimeOut: (NSTimeInterval)timeout {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSMutableData *message = [[NSMutableData alloc] initWithData:data];
    [message appendData:[ESPacket terminator]];
    [sock writeData:message withTimeout:timeout tag:TAG_WRITE_PACKET];
}

+(void)readOnSocket:(GCDAsyncSocket *)sock withTimeOut: (NSTimeInterval)timeout {
    [sock readDataToData:[ESPacket terminator] withTimeout:60 tag:TAG_READ_PACKET];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.code forKey:@"code"];
    [coder encodeObject:self.object forKey:@"object"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _code = [coder decodeIntegerForKey:@"code"];
        _object = [coder decodeObjectForKey:@"object"];
    }
    return self;
}

+(ESPacket *)packetWithCode:(NSInteger)code object:(id<NSCoding>)obj {
    ESPacket *new = [[ESPacket alloc] initWithCode:code object:obj];
    return new;
}

-(instancetype)initWithCode:(NSInteger)code object:(id<NSCoding>)obj {
    if(self = [super init]) {
        _code = code;
        _object = obj;
    }
    return self;
}
@end
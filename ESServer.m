//
//  ESServer.m
//  ESServer
//
//  Created by Thomas Williams on 11/5/14.
//  Copyright (c) 2014 Thomas Williams. All rights reserved.
//

#import "ESServer.h"
#import "ESClient.h"

@interface ESServer () <ESClientDelegate>
@property (nonatomic) NSInteger connectionID;
@property (strong, nonatomic) NSMapTable *clients;
@end

@implementation ESServer
- (void)client:(ESClient *)client disconnectedWithID:(NSInteger)id {
    NSLog(@"Connection ID: %li has closed.",id);
    @synchronized (self.clients) {
        [self.clients removeObjectForKey:@(id)];
    }
}

- (IBAction)startPressed:(NSButton *)sender {
    dispatch_queue_t delegateQueue = dispatch_queue_create("delegateQueue", NULL);
    NSInteger port = self.portField.integerValue;

    if(!self.socket) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:delegateQueue];
        NSError *err = nil;
        if ([self.socket acceptOnPort:(uint16_t) port error:&err]) {
            sender.title = @"Stop";
            self.clients = [NSMapTable strongToStrongObjectsMapTable];
            self.connectionID = 0;
        } else {
            self.socket = nil;
            NSLog(@"Error accepting connections: %@",err);
        }
    } else {
        [self.socket disconnectAfterReadingAndWriting];
        sender.title = @"Start";
    }
}

-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSInteger newID = self.connectionID++;
    ESClient *new = [[ESClient alloc] initWithConnectionID:newID socket:newSocket delegate:self];
    @synchronized (self.clients) {
        [self.clients setObject:new forKey:@(newID)];
    }
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err) {
        NSLog(@"Error: %@",err);
    } else {
        NSLog(@"Disconnected successfully");
    }
    self.socket = nil;
}
@end

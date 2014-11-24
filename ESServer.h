//
//  ESServer.h
//  ESServer
//
//  Created by Thomas Williams on 11/5/14.
//  Copyright (c) 2014 Thomas Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


@interface ESServer : NSObject <GCDAsyncSocketDelegate>

@property (weak) IBOutlet NSTextField *portField;
@property (weak) IBOutlet NSTextField *numClientsLabel;

@property (strong, nonatomic) GCDAsyncSocket *socket;

@end

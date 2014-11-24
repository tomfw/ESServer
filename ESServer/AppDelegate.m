//
//  AppDelegate.m
//  ESServer
//
//  Created by Thomas Williams on 11/5/14.
//  Copyright (c) 2014 Thomas Williams. All rights reserved.
//

#import "AppDelegate.h"
#import "DatabaseManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[DatabaseManager manager] setTestDatabase:@"/Users/tomfw/Desktop/ExpenseShare.db"];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end

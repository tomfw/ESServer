//
// Created by Thomas Williams on 11/5/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import "ESClient.h"
#import "GCDAsyncSocket.h"
#import "ESPacket.h"
#import "User.h"
#import "DatabaseManager.h"
#import "Group.h"
#import "User_Group.h"
#import "Expense.h"
#import "Reimbursement.h"


@interface ESClient () <GCDAsyncSocketDelegate>

@property(nonatomic) NSInteger userID;
@property (nonatomic) NSInteger connectionID;

@property (nonatomic) NSInteger grpID; //group id of group we are currently updating
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSMutableArray *expenses;
@property (strong, nonatomic) NSMutableArray *reimbursements;


@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (weak, nonatomic) id<ESClientDelegate> delegate;

- (void)handlePacket:(ESPacket *)packet;
- (NSInteger)updateHash;
- (void)loadTransactions;
- (void)addGroup:(Group *)group;
- (NSArray *)groups;
@end

@implementation ESClient

- (void)handlePacket:(ESPacket *)packet {
    DatabaseManager *manager = [DatabaseManager manager];

    if(packet.code == ESPACKET_REQUEST_GROUPS) {
        NSLog(@"Client requested list of groups...");
        ESPacket *response = [ESPacket packetWithCode:ESPACKET_GROUPS object:[self groups]];
        [response sendOnSocket:self.socket withTimeOut:30];
        [ESPacket readOnSocket:self.socket withTimeOut:60];
    } else if(packet.code == ESPACKET_ADD_GROUP) {
        NSLog(@"Client requested to add a group...");
        [self addGroup:packet.object];
        ESPacket *response = [ESPacket packetWithCode:ESPACKET_OK object:nil];
        [response sendOnSocket:self.socket withTimeOut:30];
        [ESPacket readOnSocket:self.socket withTimeOut:60];
    } else if(packet.code == ESPACKET_ADD_EXPENSE) {
        Expense *new = packet.object;
        new.expenseID = [manager nextValueForID:@"expenseID"];
        [manager insertObject:new];
        [[ESPacket packetWithCode:ESPACKET_OK object:nil] sendOnSocket:self.socket withTimeOut:30];
        [ESPacket readOnSocket:self.socket withTimeOut:60];
    } else if (packet.code == ESPACKET_ADD_REIMBURSMENT) {
        Reimbursement *new = packet.object;
        new.reimbursementID = [manager nextValueForID:@"reimbursementID"];
        [manager insertObject:new];
        [[ESPacket packetWithCode:ESPACKET_OK object:nil] sendOnSocket:self.socket withTimeOut:30];
        [ESPacket readOnSocket:self.socket withTimeOut:60];
    } else if (packet.code == ESPACKET_REQUEST_UPDATE) {
        //request for update 'hash' of current period for a group
        NSNumber *g = (NSNumber *) packet.object;
        self.grpID = g.integerValue;
        [self loadTransactions];

        [[ESPacket packetWithCode:ESPACKET_UPDATE_HASH object:@([self updateHash])] sendOnSocket:self.socket withTimeOut:30];
        [ESPacket readOnSocket:self.socket withTimeOut:60];
    } else if (packet.code == ESPACKET_REQUEST_TRANSACTIONS) {
        if (packet.object == nil) {
            [[ESPacket packetWithCode:ESPACKET_EXPENSES object:self.expenses] sendOnSocket:self.socket withTimeOut:30];
            [[ESPacket packetWithCode:ESPACKET_REIMBURSEMENTS object:self.reimbursements] sendOnSocket:self.socket withTimeOut:30];
            [ESPacket readOnSocket:self.socket withTimeOut:60];
        } else {
            NSLog(@"Transactions from another period have been requested");
        }
    } else if(packet.code == ESPACKET_REQUEST_USERS) {
        NSLog(@"Client requested some users");
        NSArray *users = [manager loadObjectsWithTemplate:[User userWithID:0]];
        if(users)
            NSLog(@"Found %ld users", users.count);
        [[ESPacket packetWithCode:ESPACKET_ALL_USERS object:users] sendOnSocket:self.socket withTimeOut:30];
        [ESPacket readOnSocket:self.socket withTimeOut:60];
    } else if(packet.code == ESPACKET_ADD_GROUP_MEMBER) {
        User_Group *ug = packet.object;
        [manager insertObject:ug];
        [[ESPacket packetWithCode:ESPACKET_OK object:nil] sendOnSocket:self.socket withTimeOut:30];
        [ESPacket readOnSocket:self.socket withTimeOut:60];
    } else if(packet.code == ESPACKET_DELETE_OBJECT) {
        id<DBCoding> obj = (id <DBCoding>) packet.object;
        NSLog(@"User requested to delete an object!");
        [manager deleteObject:obj];
        [ESPacket readOnSocket:self.socket withTimeOut:60];
    } else if (packet.code == ESPACKET_UPDATE_OBJECT) {
        [manager updateObject:(id <DBCoding>) packet.object];
        [ESPacket readOnSocket:self.socket withTimeOut:60];
    } else if (packet.code == ESPACKET_OK) {
        NSLog(@"We're alive!");
        [ESPacket readOnSocket:self.socket withTimeOut:60];
    }

}
-(NSInteger)updateHash {
    NSInteger result = 0;
    //really terrible hash function to indicate a user if any change has occurred.
    for (Expense *expense in self.expenses) {
        result += (NSInteger) expense.amount;
    }
    for (Reimbursement *reimbursement in self.reimbursements) {
        result += (NSInteger) reimbursement.amount;
    }
    result += self.group.users.count * 10;
    return result;
}

- (void)loadTransactions {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    DatabaseManager *manager = [DatabaseManager manager];

    Expense *expenseTemplate = [Expense expenseInGroup:self.grpID byUser:0];
    expenseTemplate.month = components.month;
    expenseTemplate.year = components.year;

    Reimbursement *reimbursementTemplate = [Reimbursement reimbursementFrom:0 to:0 inGroup:self.grpID];
    reimbursementTemplate.month = components.month;
    reimbursementTemplate.year = components.year;

    self.expenses = [[manager loadObjectsWithTemplate:expenseTemplate] mutableCopy];
    self.reimbursements = [[manager loadObjectsWithTemplate:reimbursementTemplate] mutableCopy];
    self.group = [manager loadObjectWithTemplate:[Group groupWithID:self.grpID]];
    NSLog(@"Found %lu expenses %lu reimbursements and %lu users",self.expenses.count, self.reimbursements.count,self.group.users.count);
}

- (void)addGroup:(Group *)group {
    Group *new = [[Group alloc] initWithGroup:group];
    User_Group *newEntry = [User_Group userGroupWithUser:self.userID inGroup:new.grpID];
    [[DatabaseManager manager] insertObject:new];
    [[DatabaseManager manager] insertObject:newEntry];
}

-(NSArray *)groups {
    DatabaseManager *manager = [DatabaseManager manager];
    NSArray *user_groups = [manager loadObjectsWithTemplate:[User_Group userGroupWithUser:self.userID]];
    NSMutableArray *groups = [NSMutableArray array];
    for (User_Group *user_group in user_groups) {
        [groups addObject:[manager loadObjectWithTemplate:[Group groupWithID:user_group.grpID]]];
    }
    return groups;
}

#pragma mark - Intializers

- (instancetype)initWithConnectionID:(NSInteger)connID socket:(GCDAsyncSocket *)sock delegate:(id <ESClientDelegate>)delegate {

    if(self = [super init]) {
        _connectionID = connID;
        _socket = sock;
        _delegate = delegate;
        dispatch_queue_t clientQueue = dispatch_queue_create("aClientQueue", NULL);
        [_socket setDelegate:self delegateQueue:clientQueue];
    }
    NSLog(@"New connection accepted!");
    [_socket readDataToData:[ESPacket terminator] withTimeout:30 tag:TAG_READ_USER_ID];
    return self;
}

#pragma mark - isEqual & Hash

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToClient:other];
}

- (BOOL)isEqualToClient:(ESClient *)client {
    if (self == client)
        return YES;
    if (client == nil)
        return NO;
    return self.connectionID == client.connectionID;
}

- (NSUInteger)hash {
    return (NSUInteger) self.connectionID;
}

#pragma mark - Delegate Functions

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {

    NSMutableData *newData = [data mutableCopy];
    NSRange range = NSMakeRange([data length] - 4, 4);
    [newData replaceBytesInRange:range withBytes:NULL length: 0];

    if(tag == TAG_READ_USER_ID) {
        NSNumber *userID;
        @try {
            userID = [NSKeyedUnarchiver unarchiveObjectWithData:newData];
        } @catch (NSException *exception) {
            NSLog(@"Unarchiving error: %@",exception);
            [sock disconnect];
            userID = @(-1);
            return;
        }
        self.userID = userID.integerValue;
        if(userID.integerValue != -1) {
            User *user = [[DatabaseManager manager] loadObjectWithTemplate:[User userWithID:userID.integerValue]];
            NSLog(@"%@ just logged in.", user.userName);
        } else {
            NSLog(@"An unknown user has logged on...");
        }
        [ESPacket readOnSocket:sock withTimeOut:-1];
    }

    if(tag == TAG_READ_PACKET) { //the client has made a request of some kind....
        ESPacket *packet = [NSKeyedUnarchiver unarchiveObjectWithData:newData];
        if(packet.code == ESPACKET_REGISTER) {
            NSLog(@"A client is requesting to register their device with username: %@",(NSString *)packet.object);
            User *new = [[User alloc] initWithName:packet.object];
            self.userID = new.userID;
            [[DatabaseManager manager] insertObject:new];
            packet = [ESPacket packetWithCode:ESPACKET_ASSIGN_USERID object:@(new.userID)];
            [packet sendOnSocket:sock withTimeOut:30];
            [ESPacket readOnSocket:sock withTimeOut:60];
        } else {
            [self handlePacket:packet];
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if(tag == TAG_WRITE_PACKET) {
        NSLog(@"Wrote a packet...");
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if(err) {
        NSLog(@"Error: %@",err);
    } else {
        NSLog(@"Client disconnected!");
    }
    [self.delegate client:self disconnectedWithID:self.connectionID];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    return 0;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    return 0;
}


@end
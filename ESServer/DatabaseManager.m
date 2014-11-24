//
//  DatabaseManager.m
//  TipTally
//
//  Created by Thomas Williams on 1/7/14.
//  Copyright (c) 2014 Thomas Williams. All rights reserved.
//

#import "DatabaseManager.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "DBCoder.h"
#import <dispatch/dispatch.h>

@interface DatabaseManager ()
@property (nonatomic) dispatch_queue_t databaseQueue;
@property (strong, nonatomic) FMDatabase *database;
@property (strong, nonatomic) NSString *path;
@end

@implementation DatabaseManager
static DatabaseManager *_manager = nil;
#pragma mark CODING
-(NSArray *)loadObjectsWithTemplate:(id<DBCoding>)template {
    DBCoder *coder = [DBCoder coderWithObject:template];
    [template encodeWithDBCoder:coder];
    return [coder loadObjects];
}
-(id)loadObjectWithTemplate:(id<DBCoding>)object {
    DBCoder *coder = [DBCoder coderWithObject:object];
    [object encodeWithDBCoder:coder];
    [coder loadObject];
    return coder.object;
}

- (NSArray *)loadObjectsOfType:(Class)dbObject fromTable:(NSString *)table whereColumns:(NSArray *)columns haveValues:(NSArray *)values {
    DBCoder *coder = [DBCoder coder];
    return [coder loadObjectsOfType:dbObject fromTable:table whereColumns:columns haveValues:values];
}

-(void)insertObject:(id<DBCoding>)object {
    DBCoder *coder = [DBCoder coderWithObject:object];
    [object encodeWithDBCoder:coder];
    [[DatabaseManager manager] executeUpdate:[coder insertionString] withArgs:[coder values]];
}

-(void)updateObject:(id<DBCoding>)object {
    DBCoder *coder = [DBCoder coderWithObject:object];
    [object encodeWithDBCoder:coder];
    [coder performUpdate];
}
-(void)deleteObject:(id<DBCoding>)object {
    DBCoder *coder = [DBCoder coderWithObject:object];
    [object encodeWithDBCoder:coder];
    [coder performDelete];
}
#pragma mark EXECUTING
-(void)executeUpdate:(NSString*)sql withArgs:(NSArray *)args {
    __weak DatabaseManager *me = self;
    dispatch_async(self.databaseQueue, ^{
        BOOL results = [me.database executeUpdate:sql withArgumentsInArray:args];
        if (!results) {
            //NSLog(@"Error: %@ %@", me.database.lastError, me.database.lastErrorMessage);
        }
    });
}
-(void)executeUpdate:(NSString*)sql {
    __weak DatabaseManager *me = self;
    dispatch_async(self.databaseQueue, ^{
        BOOL results = [me.database executeUpdate:sql];
        if(!results){
            //NSLog(@"%@ %@", me.database.lastError, me.database.lastErrorMessage);
        }
    });
}

-(FMResultSet *)executeSelect:(NSString*)sql {
    __block FMResultSet *results;
    __weak DatabaseManager *me = self;
    dispatch_sync(self.databaseQueue, ^{
        results = [me.database executeQuery:sql];
        if(!results)
        {
            //NSLog(@"Selection error: %@", me.database.lastErrorMessage);
        }
    });
    return results;
}

-(FMResultSet *)executeSelect:(NSString*)sql withArgs:(NSArray *)args {
    __block FMResultSet *results;
    __weak DatabaseManager *me = self;
    dispatch_sync(self.databaseQueue, ^{
        results = [me.database executeQuery:sql withArgumentsInArray:args];
        if(!results)
        {
            //NSLog(@"Selection error: %@", me.database.lastErrorMessage);
        }
    });
    return results;
}
#pragma mark UTILITY
-(int)nextValueForID:(NSString*)column {
    FMResultSet *results = [self executeSelect:[NSString stringWithFormat:@"SELECT value FROM IDS WHERE name = '%@'",column]];
    int index;
    if([results next]) {
        index = [results intForColumn:@"value"];
    } else { index = 0; }
    index++;
    [self updateValueForID:column value:index];
    return index;
}

-(int)lastValueForID:(NSString*)column inTable:(NSString*)table {
    FMResultSet *results = [self executeSelect:[NSString stringWithFormat:@"SELECT MAX(%@) AS max FROM %@", column, table]];
    if([results next]) {
        return [results intForColumn:@"max"];
    }
    return -1;
}

-(void)updateValueForID:(NSString *)column value: (int)val {
    if(val > 1)
        [self executeUpdate:[NSString stringWithFormat:@"UPDATE IDS SET value = %d WHERE name = '%@'",val,column]];
    else
        [self executeUpdate:[NSString stringWithFormat:@"INSERT INTO IDS VALUES ('%@',%d)",column, val]];
}

#pragma mark MODIFYING
-(void)setName:(NSString *)name {
    if(![name isEqualToString:_name]) {
        _name = name;
        NSFileManager *fileManager = [NSFileManager defaultManager];

        NSURL *documentURL = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
        self.path = [documentURL.path stringByAppendingPathComponent:_name];
        

        if(![fileManager fileExistsAtPath:self.path]) {
            //NSLog(@"Copying?");
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"user_data" ofType:@"ttdb"];
            NSError *error;
            [fileManager copyItemAtPath:bundlePath toPath:self.path error:&error];
            if(error)
            {
                //NSLog(@"Error: %@",error);
            }
        }
    }
}

-(void)setTestDatabase:(NSString *)path {
    _database = [FMDatabase databaseWithPath:path];
    [_database open];
    if(_database) {
        NSLog(@"DB opened successfully");
    } else {
        NSLog(@"Last error: %@", [self.database lastError]);
    }
    _path = path;
}

#pragma mark INITIALIZERS
-(FMDatabase *)database {
    if(!_database) {
        _database = [FMDatabase databaseWithPath:self.path];
        [_database open];
        //NSLog(@"Last Error: %@", [_database lastError]);
    }
    return _database;
}
-(dispatch_queue_t)databaseQueue {
    if (!_databaseQueue) {
        _databaseQueue = dispatch_queue_create("dbQueue", NULL);
    }
    return _databaseQueue;
}

+(DatabaseManager *)manager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

@end

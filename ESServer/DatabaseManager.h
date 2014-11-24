//
//  DatabaseManager.h
//  Created by Thomas Williams on 1/7/14.
//  Copyright (c) 2014 Thomas Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NULL_ID -3213

@class FMResultSet;
@protocol DBCoding;

@interface DatabaseManager : NSObject


@property (strong, nonatomic) NSString *name;

- (id)loadObjectWithTemplate:(id <DBCoding>)object;
- (NSArray *)loadObjectsWithTemplate:(id <DBCoding>)template;
- (NSArray *)loadObjectsOfType:(Class)dbObject fromTable:(NSString *)table whereColumns:(NSArray *)columns haveValues:(NSArray *)values;
- (void)insertObject:(id <DBCoding>)object;
- (void)updateObject:(id <DBCoding>)object;
- (void)deleteObject:(id <DBCoding>)object;
- (int)nextValueForID:(NSString *)column;
- (int)lastValueForID:(NSString *)column inTable:(NSString *)table;
- (void)executeUpdate:(NSString *)sql withArgs:(NSArray *)args;
- (void)executeUpdate:(NSString *)sql;
- (FMResultSet *)executeSelect:(NSString *)sql;
- (FMResultSet *)executeSelect:(NSString *)sql withArgs:(NSArray *)args;

+(DatabaseManager *)manager;
- (void)setTestDatabase:(NSString *)path;
@end

//
// Created by Thomas Williams on 3/1/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import <Foundation/Foundation.h>

@class DBCoder;
@class FMResultSet;

@protocol DBCoding <NSObject>
-(NSString*)tableName;
-(NSArray *)primaryKeyColumns;
-(void)encodeWithDBCoder:(DBCoder*)coder;
-(id)initWithDBCoder:(DBCoder*)coder;
@end


@interface DBCoder : NSObject

@property (strong, nonatomic) FMResultSet* results;
@property (readonly) NSArray *columns;
@property (readonly) NSArray *values;

@property (strong, nonatomic) id<DBCoding> object;

- (void)performDelete;
- (void)performUpdate;
- (NSArray *)loadObjects;
- (void)loadObject;
- (NSArray *)loadObjectsOfType:(Class)dbObject fromTable:(NSString *)table whereColumns:(NSArray *)columns haveValues:(NSArray *)values;
- (NSString *)insertionString;
-(int)intForColumn:(NSString*)column;
-(double)doubleForColumn:(NSString*)column;
-(NSDate *)dateForColumn:(NSString *)column;
-(NSString *)stringForColumn:(NSString*)column;

-(void)encodeInt:(int)value forColumn:(NSString*)column;
-(void)encodeDouble:(double)value forColumn:(NSString*)column;
-(void)encodeDate:(NSDate*)date forColumn:(NSString *)column;
-(void)encodeString:(NSString*)string forColumn:(NSString*)column;
+ (DBCoder *)coderWithObject:(id<DBCoding>)object;
+(DBCoder *)coder;
@end
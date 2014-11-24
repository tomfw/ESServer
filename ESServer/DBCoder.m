//
// Created by Thomas Williams on 3/1/14.
// Copyright (c) 2014 Thomas Williams. All rights reserved.
//
//


#import "DBCoder.h"
#import "FMResultSet.h"
#import "DatabaseManager.h"

@interface DBCoder()
@property (strong, nonatomic) NSMutableDictionary *fields;
- (NSString *)assignmentString:(NSString *)column;
- (NSArray *)columnsWithValues;
- (NSArray *)valuesForColumns:(NSArray *)columns;
@end

@implementation DBCoder
-(void)performDelete {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", self.object.tableName, [self whereClauseForColumns:self.object.primaryKeyColumns]];
    [[DatabaseManager manager] executeUpdate:sql withArgs:[self whereClauseValues]];
}
-(void)performUpdate {
    NSMutableArray *columns = [self.columns mutableCopy];
    NSMutableArray *values = [self.values mutableCopy];
    NSMutableArray *whereFields = [NSMutableArray array];

    for (NSUInteger i = 0; i < columns.count; i++) {
        if([self.object.primaryKeyColumns containsObject:columns[i]]) {
            [whereFields addObject:columns[i]];
            [columns removeObjectAtIndex:i];
            [values removeObjectAtIndex:i];
        }
    }

    NSString *result = [NSString stringWithFormat:@"UPDATE %@ SET ",self.object.tableName];
    for (NSUInteger i = 0; i < columns.count; i++) {
        result = [result stringByAppendingString:[self assignmentString:columns[i]]];
        if(i < columns.count - 1)
            result = [result stringByAppendingString:@", "];
    }
    result = [result stringByAppendingString:[NSString stringWithFormat:@" WHERE %@", [self whereClauseForColumns:whereFields]]];
    [values addObjectsFromArray:[self whereClauseValues]];
    [[DatabaseManager manager] executeUpdate:result withArgs:values];
}

-(NSArray*)loadObjects {
    NSArray *columns = [self columnsWithValues];
    NSArray *values = [self valuesForColumns:columns];
    NSLog(@"%@ columns, %@values", columns, values);
    return [self loadObjectsOfType:[self.object class]
                         fromTable:self.object.tableName
                      whereColumns:columns
                        haveValues:values];

}

- (NSArray *)valuesForColumns:(NSArray *)columns {
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *column in columns) {
        [values addObject:(self.fields)[column]];
    }
    return values;
}

- (NSArray *)columnsWithValues {
    NSMutableArray *columns = [NSMutableArray array];
    NSArray *keys = [self.fields allKeys];
    NSArray *values = [self.fields allValues];

    for (NSUInteger i = 0; i < self.values.count; i++) {
        if(values[i] != [NSNull null]) {
            if([values[i] isKindOfClass:[NSNumber class]]) {
                if([values[i] doubleValue] != 0) {
                    [columns addObject:keys[i]];
                }
            }  else {
                [columns addObject:keys[i]];
            }
        }
    }
    return columns;
}

-(void)loadObject {
    NSArray *objects = [self loadObjectsOfType:[self.object class]
                                     fromTable:self.object.tableName
                                  whereColumns:self.object.primaryKeyColumns
                                    haveValues:[self whereClauseValues]];
    if(objects.count == 1)
        self.object = [objects lastObject];
    else {
        NSLog(@"Error: Found %lu objects", objects.count);
        self.object = nil;
    }
}

-(NSArray *)loadObjectsOfType:(Class)dbObject fromTable:(NSString*)table whereColumns:(NSArray *)columns haveValues:(NSArray *)values {
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:10];
    NSString *selector = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ", table];

    selector = [selector stringByAppendingString:[self whereClauseForColumns:columns]];
    self.results = [[DatabaseManager manager] executeSelect:selector withArgs:values];
  //  NSLog(@"Selector: %@ values %@",selector, values);
    while ([self.results next]) {
        id  obj = [dbObject alloc];
        id<DBCoding> codableObject = [obj initWithDBCoder:self];//TODO: double check this b.s. stopped working and needed this ugly hack.
        [objects addObject:codableObject];
    }
    return [objects copy];
}

-(NSString *)whereClauseForColumns:(NSArray *)columns {
    NSString *result = @"";
    for (NSUInteger i = 0; i < columns.count; i++) {
        result = [result stringByAppendingString:[self assignmentString:columns[i]]];
        if(i < columns.count - 1)
            result = [result stringByAppendingString:@"AND "];
    }
    return result; //colName = ? (AND otherCol = ?....)
}

-(NSArray *)whereClauseValues {
    return [self.fields objectsForKeys:self.object.primaryKeyColumns notFoundMarker:[NSNull null]];
}

-(NSString *)assignmentString:(NSString *) column {
    return [NSString stringWithFormat:@"%@ = ? ", column];//colName = ?
}

-(NSString *)insertionString {

    NSArray *columns = self.columns;

    NSString *columnString=@""; //comma delineated list of field names
    NSString *valueString=@""; //?,?,...

    for (NSUInteger i = 0; i < columns.count; i++) {
        columnString = [columnString stringByAppendingString:columns[i]];
        valueString = [valueString stringByAppendingString:@"?"];
        if(i < columns.count - 1) {
            columnString = [columnString stringByAppendingString:@","];
            valueString = [valueString stringByAppendingString:@","];
        }

    }
    return [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", self.object.tableName, columnString, valueString];
}

- (int)intForColumn:(NSString *)column {
    if(!self.results) {
        //NSLog(@"No results!");
        return 0;
    }
    return [self.results intForColumn:column];
}

- (double)doubleForColumn:(NSString *)column {
    if(!self.results) {
        //NSLog(@"No results!");
        return 0;
    }
    return [self.results doubleForColumn:column];
}

- (NSDate *)dateForColumn:(NSString *)column {
    if(!self.results) {
        //NSLog(@"No results!");
        return nil;
    }
    return [self.results dateForColumn:column];
}

- (NSString *)stringForColumn:(NSString *)column {
    if(!self.results) {
        //NSLog(@"No results!");
        return nil;
    }
    return [self.results stringForColumn:column];
}

- (void)encodeInt:(int)value forColumn:(NSString *)column {
    [self.fields setObject:[NSNumber numberWithInt:value] forKey:column];
}

- (void)encodeDouble:(double)value forColumn:(NSString *)column {
    [self.fields setObject:[NSNumber numberWithDouble:value] forKey:column];
}

- (void)encodeDate:(NSDate *)date forColumn:(NSString *)column {
    if(date)
        [self.fields setObject:date forKey:column];
    else
        [self.fields setObject:[NSNull null] forKey:column];
}

- (void)encodeString:(NSString *)string forColumn:(NSString *)column {
    if(string)
        [self.fields setObject:string forKey:column];
    else
        [self.fields setObject:[NSNull null] forKey:column];
}
-(NSArray *)values {
    return [self.fields allValues];
}

-(NSArray *)columns {
    return [self.fields allKeys];
}
-(NSMutableDictionary *)fields {
    if(!_fields)
        _fields = [NSMutableDictionary dictionary];
    return _fields;
}

+(DBCoder *)coderWithObject:(id<DBCoding>)object {
    DBCoder *new = [DBCoder coder];
    new.object = object;
    return new;
}

+(DBCoder *)coder {
    return [[DBCoder alloc] init];
}

@end
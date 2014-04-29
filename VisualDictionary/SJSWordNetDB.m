//
//  SJSWordNetDB.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/11/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSWordNetDB.h"

@implementation SJSWordNetDB {
    FMDatabaseQueue *_queue;
}

- (id)init
{
    NSString *dbFile = [[NSBundle mainBundle] pathForResource:@"wordnet.sqlite" ofType:nil];
    NSLog(@"Sqlite Db: %@", dbFile);
    
    _queue = [FMDatabaseQueue databaseQueueWithPath:dbFile];
    
    return self;
}

- (NSSet *)meaningsForWord:(NSString *)word
{
    __block NSMutableSet *meanings = [NSMutableSet new];
    
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT meaning FROM words_meanings WHERE word = ?", word];
        
        while ([rs next]) {
            [meanings addObject:[rs stringForColumnIndex:0]];
        }
        
        [rs close];
    }];
    
    return meanings;
}

- (NSSet *)wordsForMeaning:(NSString *)meaning
{
    __block NSMutableSet *words = [NSMutableSet new];
    
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT word FROM words_meanings WHERE meaning = ?", meaning];
        
        while ([rs next]) {
            [words addObject:[rs stringForColumnIndex:0]];
        }
        
        [rs close];
    }];
    
    return words;
}

- (NSString *)definitionOfMeaning:(NSString *)meaning
{
    __block NSString *result = nil;
    
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT definition FROM definitions WHERE meaning = ?", meaning];
        
        if ([rs next]) {
            result = [rs stringForColumnIndex:0];
        }
        
        NSLog(@"%@: %@", meaning, result);
        
        [rs close];
    }];
    
    return result;
}

- (BOOL)containsWord:(NSString *)word
{
    __block BOOL result;
    
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT word FROM words_meanings WHERE word = ?", word];
        result = [rs next];
        [rs close];
    }];
    
    return result;
}

- (NSString *)getRandomWord
{
    __block NSString *result = nil;
    
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *countRs = [db executeQuery:@"SELECT COUNT(*) FROM words_meanings"];
        if ([countRs next]) {
            int count = [countRs intForColumnIndex:0];
            int offset = arc4random_uniform(count);
            
            FMResultSet *wordRs = [db executeQuery:@"SELECT word FROM words_meanings LIMIT 1 OFFSET ?",
                                   [NSString stringWithFormat:@"%d", offset]];
            if ([wordRs next]) {
                result = [wordRs stringForColumnIndex:0];
            }
            
            [wordRs close];
        }
        
        [countRs close];
    }];
    
    NSLog(@"Random word: %@", result);
    return result;
}

@end

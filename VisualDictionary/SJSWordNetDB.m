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
    NSMutableSet *_connected;
    NSMutableSet *_disconnected;
}

- (id)init
{
    _connected = [NSMutableSet new];
    _disconnected = [NSMutableSet new];
    
    NSString *dbFile = [[NSBundle mainBundle] pathForResource:@"wordnet.sqlite" ofType:nil];
    NSLog(@"Sqlite Db: %@", dbFile);
    
    _queue = [FMDatabaseQueue databaseQueueWithPath:dbFile];
    
    return self;
}

- (NSArray *)meaningsForWord:(NSString *)word
{
    __block NSMutableArray *meanings = [NSMutableArray new];
    
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT meaning FROM words_meanings WHERE word = ?", word];
        
        while ([rs next]) {
            [meanings addObject:[rs stringForColumnIndex:0]];
        }
        
        [rs close];
    }];
    
    for (NSString *meaning in meanings) {
        NSString *wordMeaningKey = [[word stringByAppendingString:@"-"] stringByAppendingString:meaning];
        [_connected addObject:wordMeaningKey];
    }
    
    return meanings;
}

- (NSArray *)wordsForMeaning:(NSString *)meaning
{
    __block NSMutableArray *words = [NSMutableArray new];
    
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT word FROM words_meanings WHERE meaning = ?", meaning];
        
        while ([rs next]) {
            [words addObject:[rs stringForColumnIndex:0]];
        }
        
        [rs close];
    }];
    
    for (NSString *word in words) {
        NSString *wordMeaningKey = [[word stringByAppendingString:@"-"] stringByAppendingString:meaning];
        [_connected addObject:wordMeaningKey];
    }
    
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

- (BOOL)word:(NSString *)word isConnectedToMeaning:(NSString *)meaning
{
    NSString *wordMeaningKey = [[word stringByAppendingString:@"-"] stringByAppendingString:meaning];
    return [_connected containsObject:wordMeaningKey];
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

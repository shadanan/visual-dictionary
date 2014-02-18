//
//  SJSWordNetDB.h
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/11/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseQueue.h"

@interface SJSWordNetDB : NSObject

@property FMDatabaseQueue *queue;
@property NSMutableSet *connected;
@property NSMutableSet *disconnected;

- (NSArray *)meaningsForWord:(NSString *)word;
- (NSArray *)wordsForMeaning:(NSString *)meaning;
- (NSString *)definitionOfMeaning:(NSString *)meaning;
- (BOOL)word:(NSString *)word isConnectedToMeaning:(NSString *)meaning;
- (BOOL)containsWord:(NSString *)word;

@end

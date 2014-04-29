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

- (NSSet *)meaningsForWord:(NSString *)word;
- (NSSet *)wordsForMeaning:(NSString *)meaning;
- (NSString *)definitionOfMeaning:(NSString *)meaning;
- (BOOL)containsWord:(NSString *)word;
- (NSString *)getRandomWord;

@end

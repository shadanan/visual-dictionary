//
//  SJSWordNode.h
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/13/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SJSWordNode : SKLabelNode

typedef NS_ENUM(NSInteger, NodeType) {
    UnknownType,
    WordType,
    MeaningType
};

@property enum NodeType type;
@property NSInteger distance;
@property NSArray *neighbourNames;

- (id)initWithName:(NSString *)name withType:(NodeType)type;

- (NSArray *)neighbourNodes;

- (void)prune;

- (void)pruneNeighbours;

- (void)grow;

- (void)growRecursivelyWithMaxDepth:(NSUInteger)depth;

- (NSString *)getDefinition;

@end

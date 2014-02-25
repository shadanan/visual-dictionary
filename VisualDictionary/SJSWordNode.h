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
    WordType,
    AdverbType,
    AdjectiveType,
    NounType,
    VerbType
};

@property enum NodeType type;
@property NSInteger distance;
@property (readonly) NSArray *neighbourNames;
@property CGFloat defaultScale;

- (id)initWordWithName:(NSString *)name;
- (id)initMeaningWithName:(NSString *)name;

- (CGFloat)distanceTo:(SKNode *)node;

- (void)disableDynamic;

- (void)enableDynamic;

- (void)promoteToRoot;

- (NSArray *)neighbourNodes;

- (void)grow;

- (void)growRecursivelyWithMaxDepth:(NSUInteger)depth;

- (NSString *)getDefinition;

@end

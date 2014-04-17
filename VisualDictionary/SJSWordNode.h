//
//  SJSWordNode.h
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/13/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SJSTheme.h"
#import "SJSEnums.h"

@interface SJSWordNode : SKLabelNode

@property enum NodeType type;
@property NSInteger distance;
@property (readonly) NSArray *neighbourNames;

- (id)initWordWithName:(NSString *)name;
- (id)initMeaningWithName:(NSString *)name;

- (void)update;

- (void)updateDistances;

- (void)disableDynamic;

- (void)enableDynamic;

- (void)promoteToRoot;

- (NSArray *)neighbourNodes;

- (void)grow;

- (NSMutableAttributedString *)getDefinition;

- (void)setRemove:(BOOL)remove;
- (BOOL)remove;

@end

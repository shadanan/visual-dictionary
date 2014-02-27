//
//  SJSWordNode.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/13/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSWordNode.h"
#import "SJSGraphScene.h"

NSInteger maxNodeThreshold = 20;
NSInteger maxDepth = 3;

@implementation SJSWordNode {
    CGFloat _scale;
    NSArray *_neighbourNames;
    SKShapeNode *_circle;
}

- (id)initWordWithName:(NSString *)name
{
    self = [self initWithName:name withType:WordType];
    return self;
}

- (id)initMeaningWithName:(NSString *)name
{
    if ([name characterAtIndex:0] == 'a') {
        self = [self initWithName:name withType:AdjectiveType];
    } else if ([name characterAtIndex:0] == 'n') {
        self = [self initWithName:name withType:NounType];
    } else if ([name characterAtIndex:0] == 'r') {
        self = [self initWithName:name withType:AdverbType];
    } else if ([name characterAtIndex:0] == 'v') {
        self = [self initWithName:name withType:VerbType];
    } else {
        [NSException raise:@"Invalid meaning node" format:@"Meaning node with name %@ is invalid", name];
    }
    
    return self;
}

- (id)initWithName:(NSString *)name withType:(NodeType)type
{
    self = [super init];
    self.name = name;
    self.type = type;
    
    if (self.type == WordType) {
        self.text = self.name;
    } else {
        self.text = [self getTypeAsAbreviatedString];
    }
    
    self.distance = -1;
    self.zPosition = 100.0;
    self.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    _scale = 1;
    _neighbourNames = nil;
    
    _circle = [SKShapeNode new];
    _circle.name = @"circle";
    _circle.zPosition = 0.0;

    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:[SJSGraphScene.theme nodeSize]];
    self.physicsBody.mass = 1;
    self.physicsBody.dynamic = YES;
    self.physicsBody.linearDamping = 0.2;
    self.physicsBody.friction = 0;
    self.physicsBody.allowsRotation = NO;
    
    [self addChild:_circle];
    
    [self update];
    
    return self;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    [self update];
}

- (void)update
{
    if (self.distance == 0) {
        _circle.fillColor = [SJSGraphScene.theme rootNodeColor];
    } else {
        _circle.fillColor = [SJSGraphScene.theme colorByNodeType:self.type];
    }
    _circle.lineWidth = [SJSGraphScene.theme lineWidth];
    
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, nil, 0, 0, [SJSGraphScene.theme nodeSize] * _scale, 0, M_PI*2, true);
    _circle.path = circlePath;
    CGPathRelease(circlePath);
    
    if (self.type == WordType) {
        self.fontName = [SJSGraphScene.theme wordFontName];
        self.fontSize = [SJSGraphScene.theme wordFontSize] * _scale;
    } else {
        self.fontName = [SJSGraphScene.theme meaningFontName];
        self.fontSize = [SJSGraphScene.theme meaningFontSize] * _scale;
    }
    
    [self updateCanGrow];
    [self reposition];
}

- (NSArray *)neighbourNames
{
    if (_neighbourNames == nil) {
        if (self.type == WordType) {
            _neighbourNames = [SJSGraphScene.wordNetDb meaningsForWord:self.name];
        } else {
            _neighbourNames = [SJSGraphScene.wordNetDb wordsForMeaning:self.name];
        }
    }
    return _neighbourNames;
}

- (void)disableDynamic
{
    SKPhysicsBody *physicsBody = self.physicsBody;
    physicsBody.dynamic = NO;
    self.physicsBody = physicsBody;
}

- (void)enableDynamic
{
    SKPhysicsBody *physicsBody = self.physicsBody;
    physicsBody.dynamic = YES;
    self.physicsBody = physicsBody;
}

- (void)promoteToRoot
{
    [self updateDistances];
    [self pruneWithMaxDepth:maxDepth];
    [self growRecursively];
    [self update];
}

- (void)updateDistances
{
    for (SJSWordNode *node in [self.parent children]) {
        node.distance = -1;
    }
    
    NSMutableArray *queue = [NSMutableArray new];
    self.distance = 0;
    [queue addObject:self];
    
    while (queue.count > 0) {
        SJSWordNode *node = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
        
        for (SJSWordNode *child in [node neighbourNodes]) {
            if (child.distance == -1) {
                child.distance = node.distance + 1;
                [queue addObject:child];
            }
        }
    }
}

- (NSArray *)neighbourNodes
{
    if (self.neighbourNames == nil)
        return nil;
    
    NSMutableArray *neighbourNodes = [NSMutableArray new];
    
    for (NSString *neighbourName in self.neighbourNames) {
        SJSWordNode *neighbourNode = (SJSWordNode *)[self.parent childNodeWithName:neighbourName];
        if (neighbourNode != nil) {
            [neighbourNodes addObject:neighbourNode];
        }
    }
    
    return neighbourNodes;
}

- (void)updateCanGrow
{
    if ([self canGrow]) {
        _circle.strokeColor = [SJSGraphScene.theme canGrowEdgeColor];
    } else {
        _circle.strokeColor = [SJSGraphScene.theme cannotGrowEdgeColor];
    }
}

- (BOOL)canGrow
{
    for (NSString *neighbourName in self.neighbourNames) {
        SJSWordNode *neighbour = (SJSWordNode *)[self.parent childNodeWithName:neighbourName];
        
        if (neighbour == nil) {
            return true;
        }
    }
    return false;
}

- (void)grow
{
    for (NSString *neighbourName in self.neighbourNames) {
        SJSWordNode *neighbour = (SJSWordNode *)[self.parent childNodeWithName:neighbourName];
        
        if (neighbour == nil) {
            if (self.type == WordType) {
                neighbour = [[SJSWordNode alloc] initMeaningWithName:neighbourName];
            } else {
                neighbour = [[SJSWordNode alloc] initWordWithName:neighbourName];
            }
            
            [neighbour reposition];
            [self.parent addChild:neighbour];
        }
    }
    
    self.physicsBody.mass = self.neighbourNames.count;
}

- (void)growRecursively
{
    for (SJSWordNode *node in [self.parent children]) {
        node.distance = -1;
    }
    
    NSMutableArray *queue = [NSMutableArray new];
    self.distance = 0;
    [queue addObject:self];
    
    while (queue.count > 0 && self.parent.children.count < maxNodeThreshold) {
        SJSWordNode *node = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
        
        [node grow];
        for (SJSWordNode *child in [node neighbourNodes]) {
            if (child.distance == -1) {
                child.distance = node.distance + 1;
                [queue addObject:child];
            }
        }
    }
}

- (void)pruneWithMaxDepth:(NSUInteger)depth
{
    for (SJSWordNode *node in [self.parent children]) {
        if (node.distance > depth) {
            [node removeFromParent];
        }
    }
}

- (void)reposition
{
    if (self.position.x <= 0 || self.position.y <= 0 || self.position.x >= self.scene.size.width ||
        self.position.y >= self.scene.size.height) {
        self.position = CGPointMake(((int)arc4random() % 40) - 20 + self.scene.size.width / 2,
                                    ((int)arc4random() % 40) - 20 + self.scene.size.height / 2);
    }
}

- (NSString *)getTypeAsString
{
    if (self.type == WordType) {
        return @"word";
    } else if (self.type == AdverbType) {
        return @"adverb";
    } else if (self.type == AdjectiveType) {
        return @"adjective";
    } else if (self.type == NounType) {
        return @"noun";
    } else if (self.type == VerbType) {
        return @"verb";
    } else {
        return nil;
    }
}

- (NSString *)getTypeAsAbreviatedString
{
    if (self.type == WordType) {
        return @"w";
    } else if (self.type == AdverbType) {
        return @"adv";
    } else if (self.type == AdjectiveType) {
        return @"adj";
    } else if (self.type == NounType) {
        return @"n";
    } else if (self.type == VerbType) {
        return @"v";
    } else {
        return nil;
    }
}

- (NSString *)getDefinition
{
    if (self.type != WordType) {
        return [NSString stringWithFormat:@"(%@) %@",
                [self getTypeAsString], [SJSGraphScene.wordNetDb definitionOfMeaning:self.name]];
    }
    
    if (self.type == WordType) {
        NSArray *neighbours = [self neighbourNodes];
        NSString *result = [[neighbours objectAtIndex:0] getDefinition];
        
        for (int i = 1; i < neighbours.count; i++) {
            NSString *next = [[neighbours objectAtIndex:i] getDefinition];
            if (next != nil) {
                result = [result stringByAppendingString:@"\n"];
                result = [result stringByAppendingString:next];
            }
        }
        
        return result;
    }
    
    return nil;
}

@end

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
CGFloat lineWidth = 0.1;
NSString *wordFont = @"AvenirNextCondensed-DemiBold";
CGFloat wordFontSize = 16;
NSString *meaningFont = @"AvenirNextCondensed-Italic";
CGFloat meaningFontSize = 16;
CGFloat circleRadius = 16;

@implementation SJSWordNode {
    NSArray *_neighbourNames;
    SKShapeNode *_circle;
    Theme _theme;
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
        self.fontName = wordFont;
        self.fontSize = wordFontSize;
        self.text = self.name;
    } else {
        self.fontName = meaningFont;
        self.fontSize = meaningFontSize;
        self.text = [self getTypeAsAbreviatedString];
    }
    
    self.distance = -1;
    self.zPosition = 100.0;
    self.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    self.defaultScale = 1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.defaultScale = 2;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.defaultScale = 1;
    }
    
    _theme = DevelTheme;
    _neighbourNames = nil;
    _circle = [SKShapeNode new];
    
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, nil, 0, 0, circleRadius, 0, M_PI*2, true);
    
    _circle.name = @"circle";
    _circle.path = circlePath;
    _circle.lineWidth = lineWidth;
    _circle.fillColor = [SKColor colorByNodeType:type withTheme:_theme];
    _circle.zPosition = 0.0;

    CGPathRelease(circlePath);
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:circleRadius];
    self.physicsBody.mass = 1;
    self.physicsBody.dynamic = YES;
    self.physicsBody.linearDamping = 0.2;
    self.physicsBody.friction = 0;
    self.physicsBody.allowsRotation = NO;
    
    [self addChild:_circle];
    
    return self;
}

- (void)setScale:(CGFloat)scale
{
    if (self.type == WordType) {
        self.fontSize = wordFontSize * scale;
    } else {
        self.fontSize = meaningFontSize * scale;
    }
    
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, nil, 0, 0, circleRadius * scale, 0, M_PI*2, true);
    _circle.path = circlePath;
    CGPathRelease(circlePath);
}

- (void)setTheme:(Theme)theme
{
    _theme = theme;
    _circle.fillColor = [SKColor colorByNodeType:self.type withTheme:_theme];
    [self updateShapeNodePath];
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

- (CGFloat)distanceTo:(SKNode *)node
{
    return sqrt(pow(self.position.x - node.position.x, 2) + pow(self.position.y - node.position.y, 2));
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
    SJSGraphScene *scene = (SJSGraphScene *)self.scene;
    scene.root = self;
    _circle.fillColor = [SKColor rootNodeColorWithTheme:_theme];
    
    [self updateDistances];
    [self pruneWithMaxDepth:maxDepth];
    [self growRecursively];
    [scene buildEdgeNodes];
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

- (void)pruneWithMaxDepth:(NSUInteger)depth
{
    for (SJSWordNode *node in [self.parent children]) {
        if (node.distance > depth) {
            [node removeFromParent];
        }
    }
    
    for (SJSWordNode *node in [self.parent children]) {
        [self updateShapeNodePath];
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
            
            neighbour.position = CGPointMake(((int)arc4random() % 40) - 20 + self.scene.size.width / 2,
                                             ((int)arc4random() % 40) - 20 + self.scene.size.height / 2);
            [self.parent addChild:neighbour];
            [neighbour updateShapeNodePath];
        }
    }
    
    [self updateShapeNodePath];
    self.physicsBody.mass = self.neighbourNames.count;
}

- (void)updateShapeNodePath
{
    if ([self canGrow]) {
        _circle.strokeColor = [SKColor canGrowEdgeColorWithTheme:_theme];
    } else {
        _circle.strokeColor = [SKColor cannotGrowEdgeColorWithTheme:_theme];
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

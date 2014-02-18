//
//  SJSWordNode.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/13/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSWordNode.h"
#import "SJSGraphScene.h"

@implementation SJSWordNode

NSInteger maxNodeThreshold = 40;
CGFloat lineWidth = 0.1;
NSString *wordFont = @"AvenirNextCondensed-DemiBold";
CGFloat fontSize = 16;
CGFloat circleRadius = 12;

- (id)initWithName:(NSString *)name withType:(NodeType)type
{
    self = [super initWithFontNamed:wordFont];
    
    self.type = type;
    self.name = name;
    
    if (self.type == WordType)
        self.text = name;
    
    self.distance = -1;
    
    self.fontSize = fontSize;
    self.zPosition = 100.0;
    self.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    self.neighbourNames = nil;
    
    SKShapeNode *shapeNode = [SKShapeNode new];
    
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, nil, 0, 0, circleRadius, 0, M_PI*2, true);
    
    shapeNode.name = @"circle";
    shapeNode.path = circlePath;
    shapeNode.lineWidth = lineWidth;
    shapeNode.fillColor = [SKColor darkGrayColor];
    shapeNode.strokeColor = [SKColor lightGrayColor];
    shapeNode.zPosition = 0.0;
    
    CGPathRelease(circlePath);
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:circleRadius];
    self.physicsBody.mass = 1;
    self.physicsBody.dynamic = YES;
    self.physicsBody.linearDamping = 0.2;
    self.physicsBody.friction = 0;
    self.physicsBody.allowsRotation = NO;
    
    [self addChild:shapeNode];
    
    return self;
}

- (NSArray *)neighbourNodes
{
    if (self.neighbourNames == nil)
        return nil;
    
    NSMutableArray *neighbourNodes = [NSMutableArray new];
    
    for (NSString *neighbourName in self.neighbourNames) {
        [neighbourNodes addObject:[self.parent childNodeWithName:neighbourName]];
    }
    
    return neighbourNodes;
}

- (void)prune
{
    // Prune recursively
    [self pruneNeighbours];
    
    // Prune yourself
    NSLog(@"Pruning: %@", self.name);
    [self removeFromParent];
}

- (void)pruneNeighbours
{
    NSArray *neighbourNodes = [self neighbourNodes];
    
    if (neighbourNodes == nil) {
        return;
    }
    
    for (SJSWordNode *neighbour in neighbourNodes) {
        [neighbour prune];
    }
}

- (void)grow
{
    SJSGraphScene *scene = (SJSGraphScene *)self.scene;
    
    NodeType neighbourType = UnknownType;
    if (self.type == WordType) {
        self.neighbourNames = [scene.wordNetDb meaningsForWord:self.name];
        neighbourType = MeaningType;
    } else if (self.type == MeaningType) {
        self.neighbourNames = [scene.wordNetDb wordsForMeaning:self.name];
        neighbourType = WordType;
    }
    
    for (NSString *neighbourName in self.neighbourNames) {
        SJSWordNode *neighbour = (SJSWordNode *)[self.parent childNodeWithName:neighbourName];
        
        if (neighbour == nil) {
            neighbour = [[SJSWordNode alloc] initWithName:neighbourName withType:neighbourType];
            neighbour.position = CGPointMake(((int)arc4random() % 40) - 20 + self.scene.size.width / 2,
                                             ((int)arc4random() % 40) - 20 + self.scene.size.height / 2);
            [self.parent addChild:neighbour];
        }
    }
    
    self.physicsBody.mass = self.neighbourNames.count;
}

- (void)growRecursivelyWithMaxDepth:(NSUInteger)depth
{
    if (depth == 0) {
        return;
    }
    
    [self grow];
    
    for (SJSWordNode *neighbour in [self neighbourNodes]) {
        [neighbour growRecursivelyWithMaxDepth:depth - 1];
    }
}

- (NSString *)getDefinition
{
    SJSGraphScene *scene = (SJSGraphScene *)self.scene;
    if (self.type == MeaningType) {
        return [scene.wordNetDb definitionOfMeaning:self.name];
    }
    
    if (self.type == WordType) {
        NSArray *neighbours = [self neighbourNodes];
        NSString *result = [[neighbours objectAtIndex:0] getDefinition];
        
        for (int i = 1; i < neighbours.count; i++) {
            NSString *next = [[neighbours objectAtIndex:i] getDefinition];
            if (next != nil) {
                [result stringByAppendingString:@"\n"];
                [result stringByAppendingString:next];
            }
        }
        
        return result;
    }
    
    return nil;
}

@end

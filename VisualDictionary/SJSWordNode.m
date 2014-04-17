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
    SKShapeNode *_nodeFrame;
    BOOL _remove;
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
    self.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    _scale = 1;
    _neighbourNames = nil;
    _remove = NO;
    
    _nodeFrame = [SKShapeNode new];
    _nodeFrame.zPosition = -0.5;
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:[SJSGraphScene.theme nodeSize]];
    self.physicsBody.mass = 1;
    self.physicsBody.dynamic = YES;
    self.physicsBody.linearDamping = 0.2;
    self.physicsBody.friction = 0;
    self.physicsBody.allowsRotation = NO;
    
    [self addChild:_nodeFrame];
    
    [self update];
    
    return self;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    [self update];
}

- (void)setRemove:(BOOL)remove
{
    _remove = remove;
}

- (BOOL)remove
{
    return _remove;
}

- (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
}

- (void)update
{
    if (self.distance == 0) {
        _nodeFrame.fillColor = [SJSGraphScene.theme rootNodeColor];
        self.fontSize = [SJSGraphScene.theme rootNodeFontSize] * _scale;
        self.fontName = [SJSGraphScene.theme rootNodeFontNameByNodeType:self.type];
        self.fontColor = [SJSGraphScene.theme rootNodeFontColor];
    } else {
        _nodeFrame.fillColor = [SJSGraphScene.theme colorByNodeType:self.type];
        self.fontSize = [SJSGraphScene.theme fontSizeByNodeType:self.type] * _scale;
        self.fontName = [SJSGraphScene.theme fontNameByNodeType:self.type];
        self.fontColor = [SJSGraphScene.theme fontColorByNodeType:self.type];
    }
    
    _nodeFrame.lineWidth = [SJSGraphScene.theme lineWidth];
    
    if ([SJSGraphScene.theme nodeStyleByNodeType:self.type] == CircleStyle) {
        CGMutablePathRef circlePath = CGPathCreateMutable();
        CGPathAddArc(circlePath, nil, 0, 0, [SJSGraphScene.theme nodeSize] * _scale, 0, M_PI*2, true);
        _nodeFrame.path = circlePath;
        CGPathRelease(circlePath);
    } else if ([SJSGraphScene.theme nodeStyleByNodeType:self.type] == RoundedRectStyle) {
        CGRect wordFrame = [self calculateAccumulatedFrame];
        CGFloat width = wordFrame.size.width + [SJSGraphScene.theme roundedRectMarginX] * 2 * _scale;
        CGFloat height = wordFrame.size.height + [SJSGraphScene.theme roundedRectMarginY] * 2 * _scale;
        CGPathRef path = [self newPathForRoundedRect:CGRectMake(-width/2, -height/2, width, height) radius:[SJSGraphScene.theme roundedRectRadius]];
        _nodeFrame.path = path;
        CGPathRelease(path);
    }
    
    if ([self canGrow]) {
        _nodeFrame.strokeColor = [SJSGraphScene.theme canGrowEdgeColor];
    } else {
        _nodeFrame.strokeColor = [SJSGraphScene.theme cannotGrowEdgeColor];
    }
    
    if (self.position.x <= 0 || self.position.x >= self.scene.size.width ||
        self.position.y <= [SJSGraphScene.theme buttonBarHeight] || self.position.y >= self.scene.size.height) {
        self.position = CGPointMake(MIN(MAX(self.position.x, 1), self.scene.size.width - 1),
                                    MIN(MAX(self.position.y, [SJSGraphScene.theme buttonBarHeight] + 1), self.scene.size.height - 1));
    }
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
    
    for (SJSWordNode *node in [self.parent children]) {
        if (node.distance > maxDepth) {
            node.remove = YES;
        }
    }
    
    [self growRecursively];
    [self update];
    
    for (SJSWordNode *node in [self.parent children]) {
        if (node.remove == YES) {
            [node removeFromParent];
        }
    }
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

- (NSInteger)countNodes
{
    NSInteger count = 0;
    
    for (SJSWordNode *node in [self.parent children]) {
        if (node.remove == NO) {
            count++;
        }
    }
    
    return count;
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
            
            [self.parent addChild:neighbour];
            
            CGFloat x = self.position.x + arc4random_uniform(40) - 20;
            CGFloat y = self.position.y + arc4random_uniform(40) - 20;
            neighbour.position = CGPointMake(x, y);
        } else {
            neighbour.remove = NO;
        }
    }
    
    self.physicsBody.mass = self.neighbourNames.count;
}

- (void)growRecursively
{
    for (SJSWordNode *node in [self.parent children]) {
        node.distance = -1;
    }
    
    CGFloat zPos = -1;
    self.zPosition = zPos--;
    
    NSMutableArray *queue = [NSMutableArray new];
    self.distance = 0;
    [queue addObject:self];
    
    while (queue.count > 0 && [self countNodes] < maxNodeThreshold) {
        SJSWordNode *node = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
        
        [node grow];
        for (SJSWordNode *child in [node neighbourNodes]) {
            child.zPosition = zPos--;
            
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

- (NSMutableAttributedString *)getDefinition
{
    if (self.type != WordType) {
        NSString *typeString = [self getTypeAsString];
        NSString *definitionString = [SJSGraphScene.wordNetDb definitionOfMeaning:self.name];
        
        NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", typeString, definitionString]];
        NSRange typeRange = NSMakeRange(0, typeString.length + 2);
        NSRange definitionRange = NSMakeRange(typeString.length + 2, definitionString.length);
        
        [result addAttribute:NSFontAttributeName value:[SJSGraphScene.theme typeFont] range:typeRange];
        [result addAttribute:NSForegroundColorAttributeName value:[SJSGraphScene.theme typeColor] range:typeRange];
        
        [result addAttribute:NSFontAttributeName value:[SJSGraphScene.theme definitionFont] range:definitionRange];
        [result addAttribute:NSForegroundColorAttributeName value:[SJSGraphScene.theme definitionColor] range:definitionRange];
        
        return result;
    }
    
    if (self.type == WordType) {
        NSArray *neighbours = [self neighbourNodes];
        NSMutableAttributedString *result = [[neighbours objectAtIndex:0] getDefinition];
        
        for (int i = 1; i < neighbours.count; i++) {
            NSMutableAttributedString *next = [[neighbours objectAtIndex:i] getDefinition];
            if (next != nil) {
                [result appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
                [result appendAttributedString:next];
            }
        }
        
        return result;
    }
    
    return nil;
}

@end

//
//  SJSEdgeNode.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/16/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSEdgeNode.h"
#import "SJSGraphScene.h"

@implementation SJSEdgeNode {
    SJSWordNode __weak *_nodeA;
    SJSWordNode __weak *_nodeB;
}

- (id)initWithNodeA:(SJSWordNode *)nodeA withNodeB:(SJSWordNode *)nodeB
{
    self = [super init];
    
    _nodeA = nodeA;
    _nodeB = nodeB;
    
    self.zPosition = 50;
    
    [self updatePath];
    [self updateTheme];
    
    return self;
}

- (void)updateTheme
{
    self.lineWidth = [SJSGraphScene.theme lineWidth];
    self.strokeColor = [SJSGraphScene.theme edgeColor];
}

- (void)updatePath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, _nodeA.position.x, _nodeA.position.y);
    CGPathAddLineToPoint(path, nil, _nodeB.position.x, _nodeB.position.y);
    
    self.path = path;
    
    CGPathRelease(path);
}

@end

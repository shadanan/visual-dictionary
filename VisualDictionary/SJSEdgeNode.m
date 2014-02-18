//
//  SJSEdgeNode.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/16/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSEdgeNode.h"
#import "SJSGraphScene.h"

@implementation SJSEdgeNode

- (id)initWithNodeA:(SJSWordNode *)nodeA withNodeB:(SJSWordNode *)nodeB
{
    self = [super init];
    
    self.nodeA = nodeA;
    self.nodeB = nodeB;
    
    [self updatePath];
    
    self.zPosition = 50;
    self.lineWidth = 0.1;
    self.strokeColor = [UIColor lightGrayColor];
    
    return self;
}

- (void)updatePath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, self.nodeA.position.x, self.nodeA.position.y);
    CGPathAddLineToPoint(path, nil, self.nodeB.position.x, self.nodeB.position.y);
    
    self.path = path;
    
    CGPathRelease(path);
}

@end

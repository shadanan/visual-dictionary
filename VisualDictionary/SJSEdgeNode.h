//
//  SJSEdgeNode.h
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/16/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SJSWordNode.h"

@interface SJSEdgeNode : SKShapeNode

- (id)initWithNodeA:(SJSWordNode *)nodeA withNodeB:(SJSWordNode *)nodeB;

- (void)update;

- (void)updatePath;

@end

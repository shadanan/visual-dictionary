//
//  SJSGraphScene.h
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SJSWordNode.h"
#import "SJSEdgeNode.h"
#import "SJSWordNetDB.h"
#import "SJSDefinitionsView.h"

@interface SJSGraphScene : SKScene

@property BOOL contentCreated;
@property NSTimeInterval lastTime;
@property SJSWordNetDB *wordNetDb;
@property SJSWordNode *root;
@property SJSWordNode *currentNode;
@property BOOL dragging;

@property NSInteger searchAreaState;
@property UIView *searchArea;
@property UITextField *searchField;
@property SKLabelNode *searchIcon;

@property SJSDefinitionsView *definitionsView;

@property CGFloat scale;

- (void)setMessage:(NSString *)message;

- (void)setMessage:(NSString *)message withDuration:(NSTimeInterval)duration;

- (void)buildEdgeNodes;

@end

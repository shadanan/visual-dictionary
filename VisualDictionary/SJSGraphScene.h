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
#import "SJSSearchView.h"
#import "SJSColor.h"
#import "SJSEnums.h"

@interface SJSGraphScene : SKScene

@property BOOL contentCreated;
@property NSTimeInterval lastTime;
@property SJSWordNode *root;
@property SJSWordNode *currentNode;
@property BOOL dragging;

@property SJSDefinitionsView *definitionsView;

+ (SJSWordNetDB *)wordNetDb;

- (CGFloat)scale;
- (void)setScale:(CGFloat)scale;

- (void)setTheme:(Theme)theme;

- (void)setMessage:(NSString *)message;

- (void)setMessage:(NSString *)message withDuration:(NSTimeInterval)duration;

- (void)createSceneForWord:(NSString *)word;

- (void)rebuildEdgeNodes;

@end

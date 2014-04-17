//
//  SJSGraphScene.h
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SJSIconButton.h"
#import "SJSTextButton.h"
#import "SJSSearchButton.h"
#import "SJSWordNode.h"
#import "SJSEdgeNode.h"
#import "SJSWordNetDB.h"
#import "SJSDefinitionsView.h"
#import "SJSSearchView.h"
#import "SJSTheme.h"
#import "SJSEnums.h"

@interface SJSGraphScene : SKScene

+ (SJSWordNetDB *)wordNetDb;
+ (SJSTheme *)theme;

- (CGFloat)scale;
- (void)setScale:(CGFloat)scale;

- (void)setTheme:(Theme)theme;

- (void)setMessage:(NSString *)message withDuration:(NSTimeInterval)duration;

- (void)createSceneForRandomWord;

@end

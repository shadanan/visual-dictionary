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
#import "SJSTheme.h"
#import "SJSEnums.h"

@interface SJSGraphScene : SKScene<UIGestureRecognizerDelegate>

@property float r0;
@property float ka;
@property float kp;

@property CGFloat scale;
@property (readonly) BOOL contentCreated;

+ (SJSTheme *)theme;

- (void)setTheme:(Theme)theme;

- (void)createSceneForRandomWord;

- (void)createSceneForWord:(NSString *)word;

- (void)flashWordNotFound:(NSString *)word;

- (void)historyAppend:(NSString *)word;

@end

//
//  SJSTheme.h
//  VisualDictionary
//
//  Created by Shad Sharma on 2/26/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "SJSEnums.h"

@interface SJSTheme : NSObject

- (id)initWithTheme:(Theme)theme;

- (void)setTheme:(Theme)theme;

- (SKColor *)backgroundColor;

- (SKColor *)searchBackgroundColor;

- (SKColor *)rootNodeColor;

- (SKColor *)wordNodeColor;

- (SKColor *)adverbNodeColor;

- (SKColor *)adjectiveNodeColor;

- (SKColor *)nounNodeColor;

- (SKColor *)verbNodeColor;

- (SKColor *)edgeColor;

- (SKColor *)canGrowEdgeColor;

- (SKColor *)cannotGrowEdgeColor;

- (SKColor *)messageLabelColor;

- (SKColor *)colorByNodeType:(NodeType)type;

@end

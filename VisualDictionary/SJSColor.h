//
//  SJSColor.h
//  VisualDictionary
//
//  Created by Shad Sharma on 2/25/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "SJSEnums.h"

@interface SKColor (Extensions)

+ (SKColor *)backgroundColorWithTheme:(Theme)theme;

+ (SKColor *)searchBackgroundColorWithTheme:(Theme)theme;

+ (SKColor *)rootNodeColorWithTheme:(Theme)theme;

+ (SKColor *)wordNodeColorWithTheme:(Theme)theme;

+ (SKColor *)adverbNodeColorWithTheme:(Theme)theme;

+ (SKColor *)adjectiveNodeColorWithTheme:(Theme)theme;

+ (SKColor *)nounNodeColorWithTheme:(Theme)theme;

+ (SKColor *)verbNodeColorWithTheme:(Theme)theme;

+ (SKColor *)canGrowEdgeColorWithTheme:(Theme)theme;

+ (SKColor *)cannotGrowEdgeColorWithTheme:(Theme)theme;

+ (SKColor *)colorByNodeType:(NodeType)type withTheme:(Theme)theme;

@end

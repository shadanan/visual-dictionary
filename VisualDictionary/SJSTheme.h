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

- (CGFloat)searchHeight;
- (CGFloat)searchAlpha;
- (UIColor *)searchBackgroundColor;
- (UIFont *)searchFieldFont;
- (UIColor *)searchFieldColor;
- (UIColor *)searchFieldBackgroundColor;

- (SKColor *)rootNodeColor;
- (SKColor *)wordNodeColor;
- (SKColor *)adverbNodeColor;
- (SKColor *)adjectiveNodeColor;
- (SKColor *)nounNodeColor;
- (SKColor *)verbNodeColor;
- (SKColor *)colorByNodeType:(NodeType)type;
- (CGFloat)nodeSize;

- (NSString *)wordFontName;
- (CGFloat)wordFontSize;

- (NSString *)meaningFontName;
- (CGFloat)meaningFontSize;

- (SKColor *)edgeColor;
- (CGFloat)lineWidth;

- (SKColor *)canGrowEdgeColor;
- (SKColor *)cannotGrowEdgeColor;

- (SKColor *)messageColor;
- (NSString *)messageFontName;
- (CGFloat)messageFontSize;

- (SKColor *)anchorPointColor;
- (CGFloat)anchorPointGlowWidth;
- (CGFloat)anchorPointRadius;

- (SKColor *)pruneIconColor;
- (CGFloat)pruneIconSize;

- (CGFloat)searchIconSize;

- (CGFloat)definitionsHeight;
- (CGFloat)definitionsAlpha;
- (UIColor *)definitionsBackgroundColor;
- (UIColor *)definitionsColor;
- (NSString *)definitionsFontName;
- (CGFloat)definitionsFontSize;

@end

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

- (void)updateBackgroundSprite:(SKSpriteNode *)background;

- (CGFloat)searchHeight;
- (CGFloat)searchAlpha;
- (UIColor *)searchBackgroundColor;
- (UIFont *)searchFieldFont;
- (UIColor *)searchFieldColor;
- (UIColor *)searchFieldBackgroundColor;

- (UIColor *)rootNodeColor;
- (UIColor *)currentNodeColor;
- (UIColor *)wordNodeColor;
- (UIColor *)adverbNodeColor;
- (UIColor *)adjectiveNodeColor;
- (UIColor *)nounNodeColor;
- (UIColor *)verbNodeColor;
- (UIColor *)colorByNodeType:(NodeType)type;

- (UIColor *)rootNodeFontColor;
- (UIColor *)currentNodeFontColor;
- (UIColor *)wordNodeFontColor;
- (UIColor *)adverbNodeFontColor;
- (UIColor *)adjectiveNodeFontColor;
- (UIColor *)nounNodeFontColor;
- (UIColor *)verbNodeFontColor;
- (UIColor *)fontColorByNodeType:(NodeType)type;

- (CGFloat)rootNodeFontSize;
- (CGFloat)currentNodeFontSize;
- (CGFloat)fontSizeByNodeType:(NodeType)type;

- (NSString *)rootNodeFontNameByNodeType:(NodeType)type;
- (NSString *)currentNodeFontNameByNodeType:(NodeType)type;
- (NSString *)fontNameByNodeType:(NodeType)type;

- (NodeStyle)nodeStyleByNodeType:(NodeType)type;

- (CGFloat)nodeSize;
- (CGFloat)roundedRectMarginX;
- (CGFloat)roundedRectMarginY;
- (CGFloat)roundedRectRadius;

- (UIColor *)edgeColor;
- (CGFloat)lineWidth;

- (UIColor *)currentNodeEdgeColor;
- (UIColor *)canGrowEdgeColor;
- (UIColor *)cannotGrowEdgeColor;

- (NSString *)theSaurusFontName;

- (UIColor *)wordColor;
- (NSString *)wordFontName;
- (CGFloat)wordFontSize;

- (UIColor *)messageColor;
- (NSString *)messageFontName;
- (CGFloat)messageFontSize;

- (CGFloat)activeAlpha;
- (CGFloat)inactiveAlpha;
- (CGFloat)disabledAlpha;

- (UIColor *)anchorPointColor;
- (CGFloat)anchorPointGlowWidth;
- (CGFloat)anchorPointRadius;

- (UIColor *)pruneIconColor;
- (CGFloat)pruneIconSize;

- (NSString *)wordDefFontName;
- (CGFloat)wordDefFontSize;
- (UIColor *)wordDefFontColor;
- (NSString *)typeFontName;
- (CGFloat)typeFontSize;
- (UIColor *)typeFontColor;
- (NSString *)definitionFontName;
- (CGFloat)definitionFontSize;
- (UIColor *)definitionFontColor;

- (CGFloat)definitionsHeight;
- (UIColor *)definitionsBackgroundColor;

- (CGFloat)buttonBarHeight;
- (UIColor *)buttonBarStrokeColor;
- (UIColor *)buttonBarFillColor;
- (UIColor *)buttonBarFontColor;
- (NSString *)buttonBarFontName;
- (CGFloat)buttonBarFontSize;
- (UIColor *)buttonBarIconColor;

- (CGFloat)textButtonFontSize;
- (CGFloat)iconButtonIconHeight;

- (NSString *)helpButtonIconText;
- (NSString *)helpButtonFontName;

- (UIColor *)searchButtonFillColor;
- (UIColor *)searchButtonFontColor;
- (NSString *)searchButtonFontName;
- (CGFloat)searchButtonFontSize;

- (CGRect)backButtonFrameInFrame:(CGRect)frame;
- (CGRect)forwardButtonFrameInFrame:(CGRect)frame;
- (CGRect)helpButtonFrameInFrame:(CGRect)frame;
- (CGRect)searchButtonFrameInFrame:(CGRect)frame;

@end

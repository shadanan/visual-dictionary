//
//  SJSTheme.m
//  VisualDictionary
//
//  Created by Shad Sharma on 2/26/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSTheme.h"

@implementation SJSTheme {
    Theme _theme;
    CGFloat _scale;
    UIUserInterfaceIdiom _idiom;
}

- (id)initWithTheme:(Theme)theme
{
    self = [super init];
    if (self) {
        _theme = theme;
        _idiom = [[UIDevice currentDevice] userInterfaceIdiom];
        _scale = UIScreen.mainScreen.scale;
    }
    return self;
}

- (void)setTheme:(Theme)theme
{
    _theme = theme;
}

- (void)updateBackgroundSprite:(SKSpriteNode *)background
{
    if (_theme == LightTheme) {
        background.texture = [SKTexture textureWithImageNamed:@"thesaurus_bg_day.jpg"];
    } else if (_theme == DarkTheme) {
        background.texture = [SKTexture textureWithImageNamed:@"thesaurus_bg_night.jpg"];
    } else {
        background.texture = [SKTexture textureWithImageNamed:@"thesaurus_bg_day.jpg"];
    }
    
    if (_scale > 1.0) {
        background.size = CGSizeMake(background.texture.size.width / 2, background.texture.size.height / 2);
    } else {
        background.size = background.texture.size;
    }
}

- (CGFloat)searchHeight
{
    return 80;
}

- (CGFloat)searchAlpha
{
    return 0.8;
}

- (UIColor *)searchBackgroundColor
{
    return [UIColor lightGrayColor];
}

- (UIFont *)searchFieldFont
{
    return [UIFont systemFontOfSize:16];
}

- (UIColor *)searchFieldColor
{
    return [UIColor blackColor];
}

- (UIColor *)searchFieldBackgroundColor
{
    return [UIColor whiteColor];
}

- (UIColor *)rootNodeColor
{
    return [UIColor colorWithRed:0.96 green:0.38 blue:0.31 alpha:1];
}

- (UIColor *)wordNodeColor
{
    return [UIColor whiteColor];
}

- (UIColor *)adverbNodeColor
{
    return [UIColor colorWithRed:0.45 green:0.64 blue:0.41 alpha:1];
}

- (UIColor *)adjectiveNodeColor
{
    return [UIColor colorWithRed:0.15 green:0.55 blue:0.82 alpha:1];
}

- (UIColor *)nounNodeColor
{
    return [UIColor colorWithRed:0.16 green:0.63 blue:0.6 alpha:1];
}

- (UIColor *)verbNodeColor
{
    return [UIColor colorWithRed:0.52 green:0.6 blue:0.03 alpha:1];
}

- (UIColor *)colorByNodeType:(NodeType)type
{
    if (type == WordType) {
        return [self wordNodeColor];
    } else if (type == AdverbType) {
        return [self adverbNodeColor];
    } else if (type == AdjectiveType) {
        return [self adjectiveNodeColor];
    } else if (type == NounType) {
        return [self nounNodeColor];
    } else if (type == VerbType) {
        return [self verbNodeColor];
    } else {
        return nil;
    }
}

- (UIColor *)rootNodeFontColor
{
    return [UIColor whiteColor];
}

- (UIColor *)wordNodeFontColor
{
    return [UIColor colorWithRed:0.26 green:0.48 blue:0.70 alpha:1];
}

- (UIColor *)adverbNodeFontColor
{
    return [UIColor whiteColor];
}

- (UIColor *)adjectiveNodeFontColor
{
    return [UIColor whiteColor];
}

- (UIColor *)nounNodeFontColor
{
    return [UIColor whiteColor];
}

- (UIColor *)verbNodeFontColor
{
    return [UIColor whiteColor];
}

- (UIColor *)fontColorByNodeType:(NodeType)type
{
    if (type == WordType) {
        return [self wordNodeFontColor];
    } else if (type == AdverbType) {
        return [self adverbNodeFontColor];
    } else if (type == AdjectiveType) {
        return [self adjectiveNodeFontColor];
    } else if (type == NounType) {
        return [self nounNodeFontColor];
    } else if (type == VerbType) {
        return [self verbNodeFontColor];
    } else {
        return nil;
    }
}

- (NodeStyle)nodeStyleByNodeType:(NodeType)type
{
    if (type == WordType) {
        return RoundedRectStyle;
    } else {
        return CircleStyle;
    }
}

- (CGFloat)rootNodeFontSize
{
    return 20;
}

- (CGFloat)fontSizeByNodeType:(NodeType)type
{
    return 16;
}

- (NSString *)rootNodeFontNameByNodeType:(NodeType)type
{
    if (type == WordType) {
        return @"Georgia-Italic";
    } else {
        return @"Futura-MediumItalic";
    }
}

- (NSString *)fontNameByNodeType:(NodeType)type
{
    if (type == WordType) {
        return @"Georgia";
    } else {
        return @"Futura-Medium";
    }
}

- (CGFloat)roundedRectMarginX
{
    return 5;
}

- (CGFloat)roundedRectMarginY
{
    return 5;
}

- (CGFloat)roundedRectRadius
{
    return 2;
}

- (UIColor *)edgeColor
{
    if (_theme == LightTheme) {
        return [UIColor blackColor];
    } else if (_theme == DarkTheme) {
        return [UIColor lightGrayColor];
    } else {
        return [UIColor blackColor];
    }
}

- (CGFloat)lineWidth
{
    if (_theme == LightTheme) {
        return 0.1;
    } else if (_theme == DarkTheme) {
        return 0.1;
    } else {
        return 0.1;
    }
}

- (CGFloat)nodeSize
{
    if (_theme == LightTheme) {
        return 16;
    } else if (_theme == DarkTheme) {
        return 16;
    } else {
        return 16;
    }
}

- (UIColor *)canGrowEdgeColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [UIColor colorWithRed:0.82 green:0.21 blue:0.51 alpha:1];
    }
}

- (UIColor *)cannotGrowEdgeColor
{
    return [self edgeColor];
}

- (UIColor *)messageColor
{
    if (_theme == LightTheme) {
        return [UIColor blackColor];
    } else if (_theme == DarkTheme) {
        return [UIColor whiteColor];
    } else {
        return [UIColor blackColor];
    }
}

- (NSString *)messageFontName
{
    return @"AvenirNext-Regular";
}

- (CGFloat)messageFontSize
{
    if (_idiom == UIUserInterfaceIdiomPhone) {
        return 16;
    } else {
        return 24;
    }
}

- (CGFloat)activeAlpha
{
    return 0.6;
}

- (CGFloat)inactiveAlpha
{
    return 0.3;
}

- (CGFloat)disabledAlpha
{
    return 0.05;
}

- (UIColor *)anchorPointColor
{
    if (_theme == LightTheme) {
        return [UIColor blackColor];
    } else if (_theme == DarkTheme) {
        return [UIColor whiteColor];
    } else {
        return [UIColor blackColor];
    }
}

- (CGFloat)anchorPointGlowWidth
{
    return 0.1;
}

- (CGFloat)anchorPointRadius
{
    if (_idiom == UIUserInterfaceIdiomPhone) {
        return 60;
    } else {
        return 100;
    }
}

- (UIColor *)pruneIconColor
{
    if (_theme == LightTheme) {
        return [UIColor blackColor];
    } else if (_theme == DarkTheme) {
        return [UIColor whiteColor];
    } else {
        return [UIColor blackColor];
    }
}

- (CGFloat)pruneIconSize
{
    if (_idiom == UIUserInterfaceIdiomPhone) {
        if (_theme == LightTheme) {
            return 60;
        } else if (_theme == DarkTheme) {
            return 60;
        } else {
            return 60;
        }
    } else {
        if (_theme == LightTheme) {
            return 100;
        } else if (_theme == DarkTheme) {
            return 100;
        } else {
            return 100;
        }
    }
}

- (UIFont *)typeFont
{
    return [UIFont fontWithName:@"Georgia-Italic" size:13];
}

- (UIFont *)definitionFont
{
    return [UIFont fontWithName:@"Georgia" size:11];
}

- (UIColor *)typeColor
{
    return [UIColor colorWithRed:1 green:0.7 blue:0.45 alpha:1];
}

- (UIColor *)definitionColor
{
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

- (CGFloat)definitionsHeight
{
    if (_idiom == UIUserInterfaceIdiomPhone) {
        if (_theme == LightTheme) {
            return 100;
        } else if (_theme == DarkTheme) {
            return 100;
        } else {
            return 100;
        }
    } else {
        if (_theme == LightTheme) {
            return 200;
        } else if (_theme == DarkTheme) {
            return 200;
        } else {
            return 200;
        }
    }
}

- (UIColor *)definitionsBackgroundColor
{
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
}

- (CGFloat)buttonBarHeight
{
    return 40;
}

- (UIColor *)buttonBarStrokeColor
{
    return [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
}

- (UIColor *)buttonBarFillColor
{
    return [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
}

- (UIColor *)buttonBarFontColor
{
    return [UIColor whiteColor];
}

- (NSString *)buttonBarFontName
{
    return @"Futura-Medium";
}

- (CGFloat)buttonBarFontSize
{
    return 8;
}

- (UIColor *)buttonBarIconColor {
    return [UIColor blackColor];
}

- (UIColor *)searchButtonFillColor {
    return [UIColor colorWithRed:0.67 green:0.09 blue:0.13 alpha:1];
}

- (CGFloat)textButtonFontSize {
    return 28;
}

- (CGFloat)iconButtonIconHeight {
    return 23;
}

- (NSString *)helpButtonIconText {
    return @"?";
}

- (NSString *)helpButtonFontName {
    return @"Futura-Medium";
}

- (UIColor *)searchButtonFontColor {
    return [UIColor whiteColor];
}

- (NSString *)searchButtonFontName {
    return @"Futura-CondensedMedium";
}

- (CGFloat)searchButtonFontSize {
    return 32;
}

- (CGRect)backButtonFrameInFrame:(CGRect)frame
{
    return [self rectWithIndex:0 withFrame:frame];
}

- (CGRect)forwardButtonFrameInFrame:(CGRect)frame
{
    return [self rectWithIndex:1 withFrame:frame];
}

- (CGRect)helpButtonFrameInFrame:(CGRect)frame
{
    return [self rectWithIndex:2 withFrame:frame];
}

- (CGRect)settingsButtonFrameInFrame:(CGRect)frame
{
    return [self rectWithIndex:3 withFrame:frame];
}

- (CGRect)searchButtonFrameInFrame:(CGRect)frame
{
    return [self rectWithIndex:4 withFrame:frame];
}

- (CGRect)rectWithIndex:(NSInteger)index withFrame:(CGRect)frame {
    return CGRectMake([self positionWithIndex:index withFrame:frame] - 1, -1, [self widthWithIndex:index withFrame:frame], frame.size.height);
}

- (CGFloat)positionWithIndex:(NSInteger)index withFrame:(CGRect)frame {
    int sum = 0;
    for (int i = 0; i < index; i++) {
        sum += [self widthWithIndex:i withFrame:frame];
    }
    return sum;
}

- (CGFloat)widthWithIndex:(NSInteger)index withFrame:(CGRect)frame {
    if (index == 0) {
        return 64;
    } else if (index == 1) {
        return 64;
    } else if (index == 2) {
        return 48;
    } else if (index == 3) {
        return 48;
    } else {
        return frame.size.width - [self positionWithIndex:4 withFrame:frame];
    }
}

@end

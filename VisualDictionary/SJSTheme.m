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
    UIUserInterfaceIdiom _idiom;
}

- (id)initWithTheme:(Theme)theme
{
    self = [super init];
    if (self) {
        _theme = theme;
        _idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    }
    return self;
}

- (void)setTheme:(Theme)theme
{
    _theme = theme;
}

- (SKColor *)backgroundColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1];
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
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [UIColor colorWithRed:0.85 green:0.92 blue:0.98 alpha:0.75];
    }
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

- (SKColor *)rootNodeColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0 green:0.3 blue:0.3 alpha:1];
    }
}

- (SKColor *)wordNodeColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    }
}

- (SKColor *)adverbNodeColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0 green:0.6 blue:0 alpha:1];
    }
}

- (SKColor *)adjectiveNodeColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0 green:0 blue:0.6 alpha:1];
    }
}

- (SKColor *)nounNodeColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.3 green:0 blue:0.3 alpha:1];
    }
}

- (SKColor *)verbNodeColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.3 green:0.3 blue:0 alpha:1];
    }
}

- (SKColor *)colorByNodeType:(NodeType)type
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

- (NSString *)wordFontName
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return @"AvenirNextCondensed-DemiBold";
    }
}

- (CGFloat)wordFontSize
{
    if (_theme == LightTheme) {
        return 16;
    } else if (_theme == DarkTheme) {
        return 16;
    } else {
        return 16;
    }
}

- (NSString *)meaningFontName
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return @"AvenirNextCondensed-Italic";
    }
}

- (CGFloat)meaningFontSize
{
    if (_theme == LightTheme) {
        return 16;
    } else if (_theme == DarkTheme) {
        return 16;
    } else {
        return 16;
    }
}

- (SKColor *)edgeColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor lightGrayColor];
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

- (SKColor *)canGrowEdgeColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.8 green:0.8 blue:0 alpha:1];
    }
}

- (SKColor *)cannotGrowEdgeColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor lightGrayColor];
    }
}

- (SKColor *)messageColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor whiteColor];
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
   
- (SKColor *)anchorPointColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor whiteColor];
    }
}

- (CGFloat)anchorPointGlowWidth
{
    if (_theme == LightTheme) {
        return 0.1;
    } else if (_theme == DarkTheme) {
        return 0.1;
    } else {
        return 0.1;
    }
}

- (CGFloat)anchorPointRadius
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

- (SKColor *)pruneIconColor
{
    if (_theme == LightTheme) {
        return [SKColor whiteColor];
    } else if (_theme == DarkTheme) {
        return [SKColor whiteColor];
    } else {
        return [SKColor whiteColor];
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

- (CGFloat)searchIconSize
{
    if (_idiom == UIUserInterfaceIdiomPhone) {
        if (_theme == LightTheme) {
            return 30;
        } else if (_theme == DarkTheme) {
            return 30;
        } else {
            return 30;
        }
    } else {
        if (_theme == LightTheme) {
            return 45;
        } else if (_theme == DarkTheme) {
            return 45;
        } else {
            return 45;
        }
    }
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

- (CGFloat)definitionsAlpha
{
    return 0.8;
}

- (UIColor *)definitionsBackgroundColor
{
    return [UIColor whiteColor];
}

- (UIColor *)definitionsColor
{
    return [UIColor blackColor];
}

- (NSString *)definitionsFontName
{
    return @"Avenir-Book";
}

- (CGFloat)definitionsFontSize
{
    return 14;
}


@end

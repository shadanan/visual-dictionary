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
}

- (id)initWithTheme:(Theme)theme
{
    self = [super init];
    _theme = theme;
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

- (SKColor *)searchBackgroundColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.85 green:0.92 blue:0.98 alpha:0.75];
    }
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

- (SKColor *)messageLabelColor
{
    if (_theme == LightTheme) {
        return nil;
    } else if (_theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor whiteColor];
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

@end

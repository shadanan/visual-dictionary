//
//  SJSColor.m
//  VisualDictionary
//
//  Created by Shad Sharma on 2/25/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSColor.h"
#import "SJSWordNode.h"

@implementation SKColor (Extensions)

+ (SKColor *)backgroundColorWithTheme:(Theme)theme
{
    if (theme == LightTheme) {
        return nil;
    } else if (theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1];
    }
}

+ (SKColor *)searchBackgroundColorWithTheme:(Theme)theme
{
    if (theme == LightTheme) {
        return nil;
    } else if (theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.85 green:0.92 blue:0.98 alpha:0.75];
    }
}

+ (SKColor *)rootNodeColorWithTheme:(Theme)theme
{
    if (theme == LightTheme) {
        return nil;
    } else if (theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0 green:0.3 blue:0.3 alpha:1];
    }
}

+ (SKColor *)wordNodeColorWithTheme:(Theme)theme
{
    if (theme == LightTheme) {
        return nil;
    } else if (theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    }
}

+ (SKColor *)adverbNodeColorWithTheme:(Theme)theme
{
    if (theme == LightTheme) {
        return nil;
    } else if (theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0 green:0.6 blue:0 alpha:1];
    }
}

+ (SKColor *)adjectiveNodeColorWithTheme:(Theme)theme
{
    if (theme == LightTheme) {
        return nil;
    } else if (theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0 green:0 blue:0.6 alpha:1];
    }
}

+ (SKColor *)nounNodeColorWithTheme:(Theme)theme
{
    if (theme == LightTheme) {
        return nil;
    } else if (theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.3 green:0 blue:0.3 alpha:1];
    }
}

+ (SKColor *)verbNodeColorWithTheme:(Theme)theme
{
    if (theme == LightTheme) {
        return nil;
    } else if (theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.3 green:0.3 blue:0 alpha:1];
    }
}

+ (SKColor *)canGrowEdgeColorWithTheme:(Theme)theme
{
    if (theme == LightTheme) {
        return nil;
    } else if (theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor colorWithRed:0.8 green:0.8 blue:0 alpha:1];
    }
}

+ (SKColor *)cannotGrowEdgeColorWithTheme:(Theme)theme
{
    if (theme == LightTheme) {
        return nil;
    } else if (theme == DarkTheme) {
        return nil;
    } else {
        return [SKColor lightGrayColor];
    }
}

+ (SKColor *)colorByNodeType:(NodeType)type withTheme:(Theme)theme
{
    if (type == WordType) {
        return [SKColor wordNodeColorWithTheme:theme];
    } else if (type == AdverbType) {
        return [SKColor adverbNodeColorWithTheme:theme];
    } else if (type == AdjectiveType) {
        return [SKColor adjectiveNodeColorWithTheme:theme];
    } else if (type == NounType) {
        return [SKColor nounNodeColorWithTheme:theme];
    } else if (type == VerbType) {
        return [SKColor verbNodeColorWithTheme:theme];
    } else {
        return nil;
    }
}

@end

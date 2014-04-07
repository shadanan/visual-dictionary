//
//  SJSSearchButton.m
//  VisualDictionary
//
//  Created by Shad Sharma on 3/23/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSSearchButton.h"
#import "SJSGraphScene.h"

@implementation SJSSearchButton {
    SKLabelNode *_label;
}

- (SJSSearchButton *)init {
    self = [super init];
    
    if (self) {
        _label = [[SKLabelNode alloc] init];
        _label.text = @"SEARCH";
        _label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self addChild:_label];
        
        [self update];
    }
    
    return self;
}

- (void)update
{
    self.strokeColor = [SJSGraphScene.theme buttonBarStrokeColor];
    self.fillColor = [SJSGraphScene.theme searchButtonFillColor];
    _label.fontName = [SJSGraphScene.theme searchButtonFontName];
    _label.fontSize = [SJSGraphScene.theme searchButtonFontSize];
    _label.fontColor = [SJSGraphScene.theme searchButtonFontColor];
}

- (void)setFrame:(CGRect)frame
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, frame);
    self.path = path;
    CGPathRelease(path);
    
    _label.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    self.antialiased = NO;
}

@end

//
//  SJSHelpButton.m
//  VisualDictionary
//
//  Created by Shad Sharma on 3/29/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSTextButton.h"
#import "SJSGraphScene.h"

@implementation SJSTextButton {
    SKLabelNode *_label;
    SKLabelNode *_icon;
}

- (SJSTextButton *)init
{
    self = [super init];
    
    if (self) {
        _label = [[SKLabelNode alloc] init];
        _label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _label.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
        [self addChild:_label];
        
        _icon = [[SKLabelNode alloc] init];
        _icon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _icon.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self addChild:_icon];
        
        [self update];
    }
    
    return self;
}

- (void)update
{
    self.strokeColor = [SJSGraphScene.theme buttonBarStrokeColor];
    _label.fontName = [SJSGraphScene.theme buttonBarFontName];
    _label.fontSize = [SJSGraphScene.theme buttonBarFontSize];
    _label.fontColor = [SJSGraphScene.theme buttonBarFontColor];
    
    _icon.fontColor = [SJSGraphScene.theme buttonBarFontColor];
    _icon.fontSize = [SJSGraphScene.theme textButtonFontSize];
}

- (void)setFrame:(CGRect)frame
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, frame);
    self.path = path;
    CGPathRelease(path);
    
    _label.position = CGPointMake(CGRectGetMidX(frame), 2);
    
    CGRect labelRect = [_label calculateAccumulatedFrame];
    CGFloat midY = (frame.size.height - labelRect.size.height) / 2 + labelRect.size.height;
    _icon.position = CGPointMake(CGRectGetMidX(frame), midY);
    
    self.antialiased = NO;
}

- (void)setLabelText:(NSString *)text
{
    _label.text = text;
}

- (void)setIconText:(NSString *)text
{
    _icon.text = text;
}

- (void)setIconFontName:(NSString *)fontName
{
    _icon.fontName = fontName;
}

@end

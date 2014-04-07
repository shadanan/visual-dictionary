//
//  SJSBarButton.m
//  VisualDictionary
//
//  Created by Shad Sharma on 3/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSIconButton.h"
#import "SJSGraphScene.h"

@implementation SJSIconButton {
    SKLabelNode *_label;
    SKSpriteNode *_icon;
    
    SKTexture *_texture;
    SKTexture *_disabledTexture;
}

- (SJSIconButton *)init
{
    self = [super init];
    
    if (self) {
        _label = [[SKLabelNode alloc] init];
        _label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _label.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
        [self addChild:_label];
        
        _icon = [[SKSpriteNode alloc] init];
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

- (void)setText:(NSString *)text
{
    _label.text = text;
}

- (void)setIcon:(NSString *)iconFile
{
    _texture = [SKTexture textureWithImageNamed:iconFile];
    _icon.texture = _texture;
    [self setHeight:[SJSGraphScene.theme iconButtonIconHeight]];
}

- (void)setDisabledIcon:(NSString *)iconFile
{
    _disabledTexture = [SKTexture textureWithImageNamed:iconFile];
    _icon.texture = _texture;
}

- (void)setWidth:(CGFloat)width
{
    CGFloat textureRatio = _texture.size.width / _texture.size.height;
    _icon.size = CGSizeMake(textureRatio, width / textureRatio);
}

- (void)setHeight:(CGFloat)height
{
    CGFloat textureRatio = _texture.size.width / _texture.size.height;
    _icon.size = CGSizeMake(height * textureRatio, height);
}

- (void)enable
{
    _icon.texture = _texture;
}

- (void)disable
{
    _icon.texture = _disabledTexture;
}

@end

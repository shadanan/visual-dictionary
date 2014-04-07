//
//  SJSTextButton.h
//  VisualDictionary
//
//  Created by Shad Sharma on 3/29/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SJSTheme.h"
#import "SJSEnums.h"

@interface SJSTextButton : SKShapeNode

- (SJSTextButton *)init;
- (void)update;
- (void)setFrame:(CGRect)frame;
- (void)setLabelText:(NSString *)text;
- (void)setIconText:(NSString *)text;
- (void)setIconFontName:(NSString *)fontName;

@end

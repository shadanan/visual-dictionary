//
//  SJSSearchView.h
//  VisualDictionary
//
//  Created by Shad Sharma on 2/25/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <UIKit/UIKit.h>
#import "SJSColors.h"
#import "SJSEnums.h"

@interface SJSSearchView : UIView

- (void)setDelegate:(id)delegate;

- (void)update;

- (void)open;

- (void)close;

@end

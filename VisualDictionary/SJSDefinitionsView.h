//
//  SJSDefinitionsView.h
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/17/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJSDefinitionsView : UIView

- (void)setText:(NSAttributedString *)text;

- (void)update;

- (void)open;

- (void)close;

@end

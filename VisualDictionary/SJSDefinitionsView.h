//
//  SJSDefinitionsView.h
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/17/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJSDefinitionsView : UIView

@property BOOL closed;
@property UILabel *definitionsLabel;
@property UIScrollView *scrollView;

- (void)close;

- (void)open;

- (void)setText:(NSString *)text;

@end

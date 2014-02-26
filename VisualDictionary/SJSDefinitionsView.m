//
//  SJSDefinitionsView.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/17/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSDefinitionsView.h"

CGFloat definitionFontSize = 14;

@implementation SJSDefinitionsView {
    CGFloat _height;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _height = frame.size.height;
        
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.8;
        self.closed = YES;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        self.definitionsLabel = [[UILabel alloc] init];
        self.definitionsLabel.frame = CGRectMake(10, 5, frame.size.width - 20, frame.size.height - 20);
        self.definitionsLabel.textColor = [UIColor blackColor];
        self.definitionsLabel.font = [UIFont fontWithName:@"Avenir-Book" size:definitionFontSize];
        self.definitionsLabel.numberOfLines = 0;
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.definitionsLabel.frame.size.height + 10);
        [self.scrollView addSubview:self.definitionsLabel];
        
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    NSLog(@"Definition: %@", text);
    self.definitionsLabel.text = text;
//    [self.definitionsLabel setNeedsLayout];
    [self.definitionsLabel sizeToFit];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.definitionsLabel.frame.size.height + 10);
}

- (void)close
{
    if (!self.closed) {
        [UIView animateWithDuration:0.2 animations:^{
            self.center = CGPointMake(self.center.x, self.center.y + _height);
            self.closed = YES;
        }];
    }
}

- (void)open
{
    if (self.closed) {
        [UIView animateWithDuration:0.2 animations:^{
            self.center = CGPointMake(self.center.x, self.center.y - _height);
            self.closed = NO;
        }];
    }
}

@end

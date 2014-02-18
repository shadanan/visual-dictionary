//
//  SJSDefinitionsView.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/17/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSDefinitionsView.h"

@implementation SJSDefinitionsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.5;
        self.closed = YES;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        self.definitionsLabel = [[UILabel alloc] init];
        self.definitionsLabel.frame = CGRectMake(10, 5, frame.size.width - 20, frame.size.height - 20);
        self.definitionsLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
        self.definitionsLabel.textColor = [UIColor blackColor];
        self.definitionsLabel.font = [UIFont fontWithName:@"Avenir-Book" size:12];
        self.definitionsLabel.numberOfLines = 0;
        [self.definitionsLabel sizeToFit];
        
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
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.definitionsLabel.frame.size.height + 10);
}

- (void)close
{
    if (!self.closed) {
        [UIView animateWithDuration:0.2 animations:^{
            self.center = CGPointMake(self.center.x, self.center.y + 100);
            self.closed = YES;
        }];
    }
}

- (void)open
{
    if (self.closed) {
        [UIView animateWithDuration:0.2 animations:^{
            self.center = CGPointMake(self.center.x, self.center.y - 100);
            self.closed = NO;
        }];
    }
}

@end

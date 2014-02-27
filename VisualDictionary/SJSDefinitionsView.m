//
//  SJSDefinitionsView.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/17/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSDefinitionsView.h"
#import "SJSGraphScene.h"

@implementation SJSDefinitionsView {
    BOOL _closed;
    UILabel *_definitionsLabel;
    UIScrollView *_scrollView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _closed = YES;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _definitionsLabel = [[UILabel alloc] init];
        _definitionsLabel.numberOfLines = 0;
        
        [_scrollView addSubview:_definitionsLabel];
        [self addSubview:_scrollView];
        
        [self update];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _scrollView.frame = CGRectMake(0, 0, self.width, self.height);
    
    [self update];
}

- (void)update
{
    self.alpha = [SJSGraphScene.theme definitionsAlpha];
    self.backgroundColor = [SJSGraphScene.theme definitionsBackgroundColor];
    _definitionsLabel.textColor = [SJSGraphScene.theme definitionsColor];
    _definitionsLabel.font = [UIFont fontWithName:[SJSGraphScene.theme definitionsFontName] size:[SJSGraphScene.theme definitionsFontSize]];
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setText:(NSString *)text
{
    _definitionsLabel.text = text;
    _definitionsLabel.frame = CGRectMake(10, 5, self.width - 20, self.height - 20);
    [_definitionsLabel sizeToFit];
    _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _definitionsLabel.frame.size.height + 10);
}

- (void)open
{
    if (_closed) {
        [UIView animateWithDuration:0.2 animations:^{
            self.center = CGPointMake(self.center.x, self.center.y - self.height);
            _closed = NO;
        }];
    }
}

- (void)close
{
    if (!_closed) {
        [UIView animateWithDuration:0.2 animations:^{
            self.center = CGPointMake(self.center.x, self.center.y + self.height);
            _closed = YES;
        }];
    }
}

@end

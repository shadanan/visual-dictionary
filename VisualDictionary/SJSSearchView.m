//
//  SJSSearchView.m
//  VisualDictionary
//
//  Created by Shad Sharma on 2/25/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSSearchView.h"
#import "SJSGraphScene.h"

@implementation SJSSearchView {
    BOOL _closed;
    UITextField *_searchField;
    SJSGraphScene *_scene;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _closed = NO;
        self.center = CGPointMake(self.center.x, self.height / 2);
        self.backgroundColor = [SKColor whiteColor];
        self.alpha = 0.8;
        
        _searchField = [UITextField new];
        _searchField.frame = CGRectMake(20, self.height - 48, self.width - 40, 32);
        _searchField.borderStyle = UITextBorderStyleRoundedRect;
        _searchField.textColor = [UIColor blackColor];
        _searchField.font = [UIFont systemFontOfSize:16.0];
        _searchField.placeholder = @"Search for Words";
        _searchField.backgroundColor = [SKColor whiteColor];
        _searchField.autocorrectionType = UITextAutocorrectionTypeYes;
        _searchField.keyboardType = UIKeyboardTypeDefault;
        _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        [self addSubview:_searchField];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _searchField.frame = CGRectMake(20, self.height - 48, self.width - 40, 32);
}

- (void)setDelegate:(id)delegate
{
    _searchField.delegate = delegate;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setTheme:(Theme)theme
{
    self.backgroundColor = [SKColor searchBackgroundColorWithTheme:theme];
}

- (void)open
{
    if (_closed) {
        [UIView animateWithDuration:0.2 animations:^{
            self.center = CGPointMake(self.center.x, self.center.y + self.height);
            _closed = NO;
        }];
    }
    
    [_searchField becomeFirstResponder];
}

- (void)close
{
    if (!_closed) {
        [UIView animateWithDuration:0.2 animations:^{
            self.center = CGPointMake(self.center.x, self.center.y - self.height);
            _closed = YES;
        }];
    }
    
    [_searchField resignFirstResponder];
}

@end

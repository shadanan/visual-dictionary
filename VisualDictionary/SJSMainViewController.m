//
//  SJSMainViewController.m
//  TheSaurus
//
//  Created by Shad Sharma on 2015-05-22.
//  Copyright (c) 2015 Shad Sharma. All rights reserved.
//

#import "SJSMainViewController.h"

@implementation SJSMainViewController {
    SJSViewController *_graphViewController;
    float _scaleStart;
    BOOL _scaling;
    
    __weak IBOutlet UIView *settingsView;
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UITextField *springCoefficientTextField;
    __weak IBOutlet UITextField *springLengthTextField;
    __weak IBOutlet UITextField *chargeCoefficientTextField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    searchBar.delegate = self;
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender {
    if ([self isSearchBarVisible]) {
        [self hideSearchBar];
    }
}


CGFloat maxScale = 2.5;
CGFloat minScale = 0.25;

CGFloat limitScale(CGFloat scale)
{
    if (scale > maxScale) {
        return maxScale;
    } else if (scale < minScale) {
        return minScale;
    } else {
        return scale;
    }
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateBegan) {
        _scaleStart = self.graphScene.scale;
        _scaling = YES;
    } else if ([sender state] == UIGestureRecognizerStateEnded) {
        _scaling = NO;
    }
    
    self.graphScene.scale = limitScale(_scaleStart * sender.scale);
    NSLog(@"Scale: %f", self.graphScene.scale);
}

- (void)hideAllExcept:(id)sender
{
    if (sender != settingsView) {
        if ([self isSettingsVisible]) {
            [self hideSettings];
        }
    }
    
    if (sender != searchBar) {
        if ([self isSearchBarVisible]) {
            [self hideSearchBar];
        }
    }
}

// Search related functions
- (IBAction)toggleSearchBar:(UIBarButtonItem *)sender {
    if ([self isSearchBarVisible]) {
        [self hideSearchBar];
    } else {
        [self hideAllExcept:searchBar];
        [self showSearchBar];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sender
{
    if (sender == searchBar) {
        [self hideSearchBar];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sender
{
    if (sender == searchBar) {
        NSString *word = [[searchBar.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([searchBar.text isEqualToString:@""]) {
            [self hideSearchBar];
        } else if (![SJSWordNetDB.instance containsWord:word]) {
            [self.graphScene flashWordNotFound:word];
        } else {
            [self hideSearchBar];
            
            [self.graphScene historyAppend:word];
            [self.graphScene createSceneForWord:word];
        }
    }
}

- (BOOL)isSearchBarVisible
{
    return searchBar.alpha != 0;
}

- (void)hideSearchBar
{
    [searchBar resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        searchBar.alpha = 0;
    }];
}

- (void)showSearchBar
{
    [searchBar becomeFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        searchBar.alpha = 1;
    }];
}


// Settings related functions
- (IBAction)toggleSettings:(UIBarButtonItem *)sender {
    if ([self isSettingsVisible]) {
        [self hideSettings];
    } else {
        [self hideAllExcept:settingsView];
        [self showSettings];
    }
}

- (BOOL)isSettingsVisible
{
    return settingsView.alpha != 0;
}

- (void)hideSettings
{
    [UIView animateWithDuration:0.2 animations:^{
        settingsView.alpha = 0;
    }];
}

- (void)showSettings
{
    [UIView animateWithDuration:0.2 animations:^{
        settingsView.alpha = 0.8;
    }];
}

- (IBAction)springCoefficientChanged:(UITextField *)sender {
    self.graphScene.ka = sender.text.floatValue;
}

- (IBAction)springLengthChanged:(UITextField *)sender {
    self.graphScene.r0 = sender.text.floatValue;
}

- (IBAction)chargeCoefficientChanged:(UITextField *)sender {
    self.graphScene.kp = sender.text.floatValue;
}


- (void)viewDidLayoutSubviews
{
    springCoefficientTextField.text = [NSString stringWithFormat:@"%f", self.graphScene.ka];
    springLengthTextField.text = [NSString stringWithFormat:@"%f", self.graphScene.r0];
    chargeCoefficientTextField.text = [NSString stringWithFormat:@"%f", self.graphScene.kp];
}

- (SJSGraphScene *)graphScene
{
    return [_graphViewController graphScene];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"graphSegue"]) {
        _graphViewController = segue.destinationViewController;
    }
}

@end

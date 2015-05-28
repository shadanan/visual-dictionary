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
    
    __weak IBOutlet UIView *settingsView;
    __weak IBOutlet UISearchBar *searchBar;

    float initialSpringCoefficient;
    __weak IBOutlet UILabel *springCoefficientLabel;
    __weak IBOutlet UISlider *springCoefficientSlider;

    float initialSpringLength;
    __weak IBOutlet UILabel *springLengthLabel;
    __weak IBOutlet UISlider *springLengthSlider;

    float initialChargeCoefficient;
    __weak IBOutlet UILabel *chargeCoefficientLabel;
    __weak IBOutlet UISlider *chargeCoefficientSlider;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    searchBar.delegate = self;
    [self showSearchBar];
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
        searchBar.alpha = 0.95;
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
    [self loadSettings];
    [UIView animateWithDuration:0.2 animations:^{
        settingsView.alpha = 0.95;
    }];
}

- (void)loadSettings
{
    initialSpringCoefficient = self.graphScene.ka;
    springCoefficientSlider.value = self.graphScene.ka;
    springCoefficientLabel.text = [NSString stringWithFormat:@"%1.2f", initialSpringCoefficient];
    
    initialSpringLength = self.graphScene.r0;
    springLengthSlider.value = self.graphScene.r0;
    springLengthLabel.text = [NSString stringWithFormat:@"%1.2f", initialSpringLength];
    
    initialChargeCoefficient = self.graphScene.kp;
    chargeCoefficientSlider.value = log10f(self.graphScene.kp);
    chargeCoefficientLabel.text = [NSString stringWithFormat:@"%1.2f", initialChargeCoefficient];
}

- (IBAction)springCoefficientValueChanged:(UISlider *)sender {
    float springCoefficient = springCoefficientSlider.value;
    self.graphScene.ka = springCoefficient;
    springCoefficientLabel.text = [NSString stringWithFormat:@"%1.2f", springCoefficient];
}

- (IBAction)springLengthValueChanged:(UISlider *)sender {
    float springLength = springLengthSlider.value;
    self.graphScene.r0 = springLength;
    springLengthLabel.text = [NSString stringWithFormat:@"%1.2f", springLength];
}

- (IBAction)chargeCoefficientValueChanged:(UISlider *)sender {
    float chargeCoefficient = powf(10, chargeCoefficientSlider.value);
    self.graphScene.kp = chargeCoefficient;
    chargeCoefficientLabel.text = [NSString stringWithFormat:@"%1.2f", chargeCoefficient];
}

- (IBAction)touchUpInsideApply:(UIButton *)sender {
    [self hideSettings];
}

- (IBAction)touchUpInsideCancel:(UIButton *)sender {
    self.graphScene.ka = initialSpringCoefficient;
    self.graphScene.r0 = initialSpringLength;
    self.graphScene.kp = initialChargeCoefficient;
    [self hideSettings];
}

- (SJSGraphScene *)graphScene
{
    return [_graphViewController graphScene];
}

- (IBAction)showAbout:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"aboutSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"graphSegue"]) {
        _graphViewController = segue.destinationViewController;
    }
}

@end

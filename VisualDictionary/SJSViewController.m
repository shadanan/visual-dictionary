//
//  SJSViewController.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSViewController.h"
#import "SJSGraphScene.h"
#import "SJSDefinitionsView.h"

@interface SJSViewController ()

@end

@implementation SJSViewController {
    CGFloat _scaleStart;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SKView *skView = (SKView *) self.view;
    skView.ignoresSiblingOrder = YES;

    SJSGraphScene *wordScene = [SJSGraphScene sceneWithSize:skView.bounds.size];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _scaleStart = 1;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _scaleStart = 1.5;
    }
    
    wordScene.scaleMode = SKSceneScaleModeAspectFill;
    wordScene.scale = _scaleStart;
    
    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    recognizer.delegate = (id)self;
    [skView addGestureRecognizer:recognizer];
    
    [skView presentScene:wordScene];
    
    [self performSelectorInBackground:@selector(loadWordNetDb:) withObject:wordScene];
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    SKView *skView = (SKView *) self.view;
    SJSGraphScene *wordScene = (SJSGraphScene *)skView.scene;
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        _scaleStart = wordScene.scale;
    }
    
    wordScene.scale = _scaleStart * recognizer.scale;
    
}

- (void)loadWordNetDb:(SJSGraphScene *)wordScene
{
    wordScene.wordNetDb = [SJSWordNetDB new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

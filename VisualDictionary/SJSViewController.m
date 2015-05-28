//
//  SJSViewController.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSViewController.h"

@implementation SJSViewController {
    SJSGraphScene *_graphScene;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SKView *skView = (SKView *) self.view;
    skView.ignoresSiblingOrder = YES;

    _graphScene = [SJSGraphScene sceneWithSize:skView.bounds.size];
    [skView presentScene:_graphScene];
}

- (SJSGraphScene*)graphScene
{
    return _graphScene;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake) {
        [_graphScene createSceneForRandomWord];
    }
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    NSLog(@"Panning!");
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

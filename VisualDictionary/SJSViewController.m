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
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(goToAboutViewController:)
     name:@"GoToAboutViewController"
     object:nil];
    
    [self becomeFirstResponder];
    
    SKView *skView = (SKView *) self.view;
    skView.ignoresSiblingOrder = YES;

    _graphScene = [SJSGraphScene sceneWithSize:skView.bounds.size];
    _graphScene.scaleMode = SKSceneScaleModeAspectFill;    
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

- (void)goToAboutViewController:(NSNotification *) notification
{
    [self performSegueWithIdentifier:@"AboutSegue" sender:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

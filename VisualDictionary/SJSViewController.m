//
//  SJSViewController.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSViewController.h"
#import "SJSGraphScene.h"

CGFloat maxScale = 2.5;
CGFloat minScale = 0.25;

@implementation SJSViewController {
    CGFloat _scaleStart;
    SJSGraphScene *_wordScene;
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

    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    recognizer.delegate = (id)self;
    [skView addGestureRecognizer:recognizer];
    
    _wordScene = [SJSGraphScene sceneWithSize:skView.bounds.size];
    _wordScene.scaleMode = SKSceneScaleModeAspectFill;
    _wordScene.scale = 1;
    
    [skView presentScene:_wordScene];
}

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

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        _scaleStart = _wordScene.scale;
    }
    
    _wordScene.scale = limitScale(_scaleStart * recognizer.scale);
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake) {
        [_wordScene createSceneForRandomWord];
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

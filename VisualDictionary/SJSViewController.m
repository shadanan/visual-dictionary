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

@implementation SJSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SKView *skView = (SKView *) self.view;
    skView.showsNodeCount = YES;
    skView.showsFPS = YES;
    skView.ignoresSiblingOrder = YES;

    SJSGraphScene *wordScene = [SJSGraphScene sceneWithSize:skView.bounds.size];
    wordScene.scaleMode = SKSceneScaleModeAspectFill;
    
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
    wordScene.scale = recognizer.scale;
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

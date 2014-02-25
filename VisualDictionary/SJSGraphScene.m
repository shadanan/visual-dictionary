//
//  SJSGraphScene.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSGraphScene.h"

NSInteger searchAreaOpen = 40;

@implementation SJSGraphScene {
    CGFloat _anchorRadius;
    CGFloat _springLength;
}

- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated) {
        self.contentCreated = true;
        [self createSceneContents];
    }
}

- (void)didChangeSize:(CGSize)oldSize
{
    if (self.searchArea != nil && self.searchField != nil) {
        self.searchArea.frame = CGRectMake(0, 0, self.frame.size.width, searchAreaOpen * 2);
        self.searchField.frame = CGRectMake(20, self.searchArea.frame.size.height - 48, self.searchArea.frame.size.width - 40, 32);
    }
    
    if (self.root != nil) {
        self.root.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
}

- (void)createSceneContents
{
    NSLog(@"Scale: %f", self.scale);
    
    _anchorRadius = 60 * self.scale;
    _springLength = 60 * self.scale;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.scaleMode = SKSceneScaleModeResizeFill;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.speed = 4;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.friction = 0;
    
    self.searchArea = [UIView new];
    self.searchArea.frame = CGRectMake(0, 0, self.frame.size.width, searchAreaOpen * 2);
    self.searchArea.backgroundColor = [SKColor colorWithRed:0.85 green:0.92 blue:0.98 alpha:0.75];
    self.searchAreaState = searchAreaOpen;
    self.searchArea.center = CGPointMake(self.searchArea.center.x, self.searchAreaState);
    [self.view addSubview:self.searchArea];
    
    self.searchField = [UITextField new];
    self.searchField.frame = CGRectMake(20, self.searchArea.frame.size.height - 48, self.searchArea.frame.size.width - 40, 32);
    self.searchField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchField.textColor = [UIColor blackColor];
    self.searchField.font = [UIFont systemFontOfSize:16.0];
    self.searchField.placeholder = @"Search for Words";
    self.searchField.backgroundColor = [SKColor whiteColor];
    self.searchField.autocorrectionType = UITextAutocorrectionTypeYes;
    self.searchField.keyboardType = UIKeyboardTypeDefault;
    self.searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchField.delegate = (id)self;
    [self.searchArea addSubview:self.searchField];
    
    self.searchIcon = [SKLabelNode new];
    self.searchIcon.name = @"searchIcon";
    self.searchIcon.text = [[NSString alloc] initWithUTF8String:"\xF0\x9F\x94\x8D"];
    self.searchIcon.fontSize = 24;
    self.searchIcon.position = CGPointMake(CGRectGetMaxX(self.frame) - 4, CGRectGetMaxY(self.frame) - 20);
    self.searchIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    self.searchIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    self.searchIcon.zPosition = 200;
    self.searchIcon.hidden = YES;
    [self addChild:self.searchIcon];
    
    SKShapeNode *anchorPoint = [SKShapeNode new];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, nil, 0, 0, _anchorRadius, 0, M_PI*2, YES);
    anchorPoint.path = path;
    CGPathRelease(path);
    
    anchorPoint.name = @"anchorPoint";
    anchorPoint.fillColor = [SKColor whiteColor];
    anchorPoint.alpha = 0;
    anchorPoint.glowWidth = 1;
    anchorPoint.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:anchorPoint];
    
    
    SKNode *edgeNodes = [[SKNode alloc] init];
    edgeNodes.name = @"edgeNodes";
    [self addChild:edgeNodes];
    
    SKNode *wordNodes = [[SKNode alloc] init];
    wordNodes.name = @"wordNodes";
    [self addChild:wordNodes];
    
    self.definitionsView = [[SJSDefinitionsView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 100)];
    [self.view addSubview:self.definitionsView];
}

- (void)openSearchPane
{
    self.searchAreaState = searchAreaOpen;
    self.searchArea.center = CGPointMake(self.searchArea.center.x, self.searchAreaState);
    [self.searchField becomeFirstResponder];
    self.searchIcon.hidden = YES;
}

- (void)closeSearchPane
{
    self.searchAreaState = -searchAreaOpen;
    self.searchArea.center = CGPointMake(self.searchArea.center.x, self.searchAreaState);
    [self.searchField resignFirstResponder];
    self.searchIcon.hidden = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.searchField) {
        [self createSceneForWord:[[self.searchField.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    return false;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeSearchPane];
    [self.definitionsView close];
    
    CGPoint start = [[touches anyObject] locationInNode:self];
    
    self.currentNode = nil;
    for (SKNode *node in [self nodesAtPoint:start]) {
        if ([node isKindOfClass:[SJSWordNode class]]) {
            self.dragging = NO;
            self.currentNode = (SJSWordNode *)node;
            [self.currentNode disableDynamic];
        }
        
        if ([node.name isEqualToString:@"searchIcon"]) {
            [self openSearchPane];
        }
    }
    
    if (self.currentNode != nil) {
        NSLog(@"Node name: %@", self.currentNode.name);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.currentNode != nil) {
        self.dragging = YES;
        CGPoint point = [[touches anyObject] locationInNode:self];
        self.currentNode.position = point;
        
        SKShapeNode *anchorPoint = (SKShapeNode *)[self childNodeWithName:@"anchorPoint"];
        if (![anchorPoint hasActions]) {
            if (anchorPoint.alpha != 0.4 && [self.currentNode distanceTo:anchorPoint] < _anchorRadius) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:0.4 duration:0.2];
                [anchorPoint runAction:fadeIn];
            } else if (anchorPoint.alpha != 0.2 && [self.currentNode distanceTo:anchorPoint] >= _anchorRadius) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:0.2 duration:0.2];
                [anchorPoint runAction:fadeIn];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.currentNode != nil) {
        [self.currentNode enableDynamic];
        
        if (!self.dragging) {
            [self.currentNode grow];
            [self buildEdgeNodes];
            
            [self.definitionsView open];
            [self.definitionsView setText:[self.currentNode getDefinition]];
        }
        
        SKShapeNode *anchorPoint = (SKShapeNode *)[self childNodeWithName:@"anchorPoint"];
        SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.2];
        [anchorPoint runAction:fadeOut];
        
        if (self.dragging && [self.currentNode distanceTo:anchorPoint] < _anchorRadius) {
            [self.root enableDynamic];
            [self.currentNode disableDynamic];
            
            [self.currentNode promoteToRoot];
            SKAction *moveToCentre = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:0.2];
            [self.root runAction:moveToCentre];
        }
    }
}

- (SKLabelNode *)createStatusNode:(NSString *)message
{
    if ([self childNodeWithName:@"statusNode"] != nil) {
        [[self childNodeWithName:@"statusNode"] removeFromParent];
    }
    
    SKLabelNode *statusNode = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Regular"];
    statusNode.name = @"statusNode";
    statusNode.text = message;
    statusNode.fontSize = 16;
    statusNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    statusNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    statusNode.position = CGPointMake(CGRectGetMinX(self.frame) + 16, CGRectGetMinY(self.frame) + 10);
    
    return statusNode;
}

- (void)setMessage:(NSString *)message
{
    NSLog(@"setMessage: %@", message);
    SKLabelNode *statusNode = [self createStatusNode:message];
    [self addChild:statusNode];
}

- (void)setMessage:(NSString *)message withDuration:(NSTimeInterval)duration
{
    NSLog(@"setMessage: %@, duration: %f", message, duration);
    SKLabelNode *statusNode = [self createStatusNode:message];
    [self addChild:statusNode];
    
    SKAction *pause = [SKAction waitForDuration:duration];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.25];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *sequence = [SKAction sequence:@[pause, fadeOut, remove]];
    [statusNode runAction:sequence];
}

- (void)createSceneForWord:(NSString *)word
{
    if (![self.wordNetDb containsWord:word]) {
        [self setMessage:[word stringByAppendingString:@" not found in dictionary"] withDuration:5.0];
        return;
    }
    
    [self closeSearchPane];
    
    SKNode *wordNodes = [self childNodeWithName:@"wordNodes"];
    
    [wordNodes removeAllChildren];
    
    self.root = [[SJSWordNode alloc] initWordWithName:word];
    self.root.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self.root disableDynamic];
    [wordNodes addChild:self.root];
    
    [self.root promoteToRoot];
}

- (void)buildEdgeNodes
{
    SKNode *wordNodes = [self childNodeWithName:@"wordNodes"];
    
    SKNode *edgeNodes = [self childNodeWithName:@"edgeNodes"];
    [edgeNodes removeAllChildren];
    
    for (int i = 0; i < wordNodes.children.count; i++) {
        SJSWordNode *me = [wordNodes.children objectAtIndex:i];
        for (int j = i + 1; j < wordNodes.children.count; j++) {
            SJSWordNode *them = [wordNodes.children objectAtIndex:j];
            
            if ((me.type != WordType && them.type == WordType && [self.wordNetDb word:them.name isConnectedToMeaning:me.name]) || (me.type == WordType && them.type != WordType && [self.wordNetDb word:me.name isConnectedToMeaning:them.name])) {
                SJSEdgeNode *edge = [[SJSEdgeNode alloc] initWithNodeA:me withNodeB:them];
                [edgeNodes addChild:edge];
            }
        }
    }
}

- (BOOL)node:(SJSWordNode *)node1 isConnectedTo:(SJSWordNode *)node2
{
    if (node1.type != WordType && node2.type == WordType) {
        return [self.wordNetDb word:node2.name isConnectedToMeaning:node1.name];
    }
    
    if (node1.type == WordType && node2.type != WordType) {
        return [self.wordNetDb word:node1.name isConnectedToMeaning:node2.name];
    }
    
    return false;
}

- (void)update:(NSTimeInterval)currentTime
{
    SKNode *wordNodes = [self childNodeWithName:@"wordNodes"];
    
    double r0 = _springLength * self.scale;
    double ka = 1 * self.scale;
    double kp = 10000 * self.scale;
    
    for (SJSWordNode *me in wordNodes.children) {
        double x1 = me.position.x;
        double y1 = me.position.y;
        
        [me setScale:self.scale];
        
        // No forces on the root
        if (me == self.root) {
            continue;
        }
        
        double fx = 0.0;
        double fy = 0.0;
        
        for (SJSWordNode *them in wordNodes.children) {
            if (me == them) {
                continue;
            }
            
            double x2 = them.position.x;
            double y2 = them.position.y;
            
            double r = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2)) + 0.1;
            double theta = atan2(y2 - y1, x2 - x1);
            
            double fa = 0;
            double fp = 0;
            
            if ([self node:me isConnectedTo:them]) {
                fa = ka * (r - r0);
            }
            fp = -kp / pow(r, 2);
            
            fx += (fa + fp) * cos(theta);
            fy += (fa + fp) * sin(theta);
            
            if (fa > 1000 || fa < -1000 || fp > 1000 || fp < -1000) {
                NSLog(@"me: %@  them: %@  p(%f, %f)  fa(%f, %f)  fp(%f, %f)",
                      me.name, them.name, x1, y1,
                      fa * cos(theta), fa * sin(theta), fp * cos(theta), fp * sin(theta));
            }
        }
        
        [me.physicsBody applyForce:CGVectorMake(fx, fy)];
    }
}

- (void)didSimulatePhysics
{
    SKNode *edgeNodes = [self childNodeWithName:@"edgeNodes"];
    for (SJSEdgeNode *edge in edgeNodes.children) {
        [edge updatePath];
    }    
}

@end

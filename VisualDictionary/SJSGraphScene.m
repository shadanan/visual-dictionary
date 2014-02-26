//
//  SJSGraphScene.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSGraphScene.h"

NSInteger searchAreaOpen = 40;
CGFloat searchIconSize = 30;
CGFloat pruneIconSize = 60;
CGFloat anchorRadius = 60;
CGFloat springLength = 60;

CGFloat searchHeight = 80;
CGFloat definitionsHeightIPhone = 100;
CGFloat definitionsHeightIPad = 200;

static SJSWordNetDB *wordNetDb = nil;

@implementation SJSGraphScene {
    CGFloat _anchorRadius;
    CGFloat _springLength;
    CGFloat _scale;
    Theme _theme;
    
    SJSSearchView *_searchView;
    SKLabelNode *_searchIcon;
    SKLabelNode *_pruneIcon;
    SKShapeNode *_anchorPoint;
}

+ (void)initialize
{
    if (!wordNetDb) {
        wordNetDb = [[SJSWordNetDB alloc] init];
    }
}

+ (SJSWordNetDB *)wordNetDb
{
    return wordNetDb;
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
    if (_searchView != nil) {
        [_searchView updateWidth:self.frame.size.width];
    }
    
    if (self.root != nil) {
        self.root.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
}

- (void)createSceneContents
{
    NSLog(@"Scale: %f", _scale);
    
    _theme = DevelTheme;
    self.scaleMode = SKSceneScaleModeResizeFill;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.speed = 4;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.friction = 0;
    
    _searchView = [[SJSSearchView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, searchHeight)];
    _searchView.delegate = self;
    [self.view addSubview:_searchView];
    
    _searchIcon = [SKLabelNode new];
    _searchIcon.name = @"searchIcon";
    _searchIcon.text = [[NSString alloc] initWithUTF8String:"\xF0\x9F\x94\x8D"];
    _searchIcon.fontSize = searchIconSize * _scale;
    _searchIcon.position = CGPointMake(CGRectGetMaxX(self.frame) - 4, CGRectGetMaxY(self.frame) - 20);
    _searchIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _searchIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _searchIcon.zPosition = 200;
    _searchIcon.hidden = YES;
    [self addChild:_searchIcon];
    
    _pruneIcon = [SKLabelNode new];
    _pruneIcon.name = @"pruneIcon";
    _pruneIcon.text = [[NSString alloc] initWithUTF8String:"\xE2\x99\xBC"];
    _pruneIcon.color = [SKColor whiteColor];
    _pruneIcon.alpha = 0;
    _pruneIcon.fontSize = pruneIconSize * _scale;
    _pruneIcon.position = CGPointMake(4, 4);
    _pruneIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _pruneIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    _pruneIcon.zPosition = 200;
    [self addChild:_pruneIcon];
    
    _anchorPoint = [SKShapeNode new];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, nil, 0, 0, _anchorRadius, 0, M_PI*2, YES);
    _anchorPoint.path = path;
    CGPathRelease(path);
    
    _anchorPoint.name = @"anchorPoint";
    _anchorPoint.fillColor = [SKColor whiteColor];
    _anchorPoint.alpha = 0;
    _anchorPoint.glowWidth = 1;
    _anchorPoint.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_anchorPoint];
    
    
    SKNode *edgeNodes = [[SKNode alloc] init];
    edgeNodes.name = @"edgeNodes";
    [self addChild:edgeNodes];
    
    SKNode *wordNodes = [[SKNode alloc] init];
    wordNodes.name = @"wordNodes";
    [self addChild:wordNodes];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.definitionsView = [[SJSDefinitionsView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, definitionsHeightIPhone)];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.definitionsView = [[SJSDefinitionsView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, definitionsHeightIPad)];
    }
    
    [self.view addSubview:self.definitionsView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *word = [[textField.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self createSceneForWord:word];
    return NO;
}

- (CGFloat)scale
{
    return _scale;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    _anchorRadius = anchorRadius * _scale;
    _springLength = springLength * _scale;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, nil, 0, 0, _anchorRadius, 0, M_PI*2, YES);
    _anchorPoint.path = path;
    CGPathRelease(path);
}

- (void)setTheme:(Theme)theme
{
    _theme = theme;
    self.backgroundColor = [SKColor backgroundColorWithTheme:_theme];
}

- (void)openSearchPane
{
    [_searchView open];
    _searchIcon.hidden = YES;
}

- (void)closeSearchPane
{
    [_searchView close];
    _searchIcon.hidden = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.root != nil) {
        [self closeSearchPane];
    }
    
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
        
        if (![_anchorPoint hasActions]) {
            if (_anchorPoint.alpha != 0.4 && [_anchorPoint containsPoint:self.currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:0.4 duration:0.2];
                [_anchorPoint runAction:fadeIn];
            } else if (_anchorPoint.alpha != 0.2 && ![_anchorPoint containsPoint:self.currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:0.2 duration:0.2];
                [_anchorPoint runAction:fadeIn];
            }
        }
        
        if (![_pruneIcon hasActions]) {
            if (_pruneIcon.alpha != 0.4 && [_pruneIcon containsPoint:self.currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:0.4 duration:0.2];
                [_pruneIcon runAction:fadeIn];
            } else if (_pruneIcon.alpha != 0.2 && ![_pruneIcon containsPoint:self.currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:0.2 duration:0.2];
                [_pruneIcon runAction:fadeIn];
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
            [self updateScene];
            
            [self.definitionsView open];
            [self.definitionsView setText:[self.currentNode getDefinition]];
        }
        
        SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.2];
        [_anchorPoint runAction:fadeOut];
        [_pruneIcon runAction:fadeOut];
        
        if (self.dragging && [_anchorPoint containsPoint:self.currentNode.position]) {
            [self.root enableDynamic];
            [self.currentNode disableDynamic];
            
            self.root = self.currentNode;
            [self.root promoteToRoot];
            [self updateScene];
            SKAction *moveToCentre = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:0.2];
            [self.root runAction:moveToCentre];
        }
        
        if (self.dragging && [_pruneIcon containsPoint:self.currentNode.position]) {
            [self prune:self.currentNode];
            self.currentNode = nil;
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
    if (![wordNetDb containsWord:word]) {
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
    [self updateScene];
}

- (void)prune:(SJSWordNode *)node
{
    [node removeFromParent];
    [self.root updateDistances];
    
    SKNode *wordNodes = [self childNodeWithName:@"wordNodes"];
    for (SJSWordNode *child in wordNodes.children) {
        if (child.distance == -1) {
            [child removeFromParent];
        }
    }
    
    [self updateScene];
}

- (void)updateScene
{
    [self rebuildEdgeNodes];
    [self updateCanGrow];
}

- (void)updateCanGrow
{
    SKNode *wordNodes = [self childNodeWithName:@"wordNodes"];
    for (SJSWordNode *node in wordNodes.children) {
        [node updateCanGrow];
    }
}

- (void)rebuildEdgeNodes
{
    SKNode *wordNodes = [self childNodeWithName:@"wordNodes"];
    
    SKNode *edgeNodes = [self childNodeWithName:@"edgeNodes"];
    [edgeNodes removeAllChildren];
    
    for (int i = 0; i < wordNodes.children.count; i++) {
        SJSWordNode *me = [wordNodes.children objectAtIndex:i];
        for (int j = i + 1; j < wordNodes.children.count; j++) {
            SJSWordNode *them = [wordNodes.children objectAtIndex:j];
            
            if ((me.type != WordType && them.type == WordType && [wordNetDb word:them.name isConnectedToMeaning:me.name]) || (me.type == WordType && them.type != WordType && [wordNetDb word:me.name isConnectedToMeaning:them.name])) {
                SJSEdgeNode *edge = [[SJSEdgeNode alloc] initWithNodeA:me withNodeB:them];
                [edgeNodes addChild:edge];
            }
        }
    }
}

- (BOOL)node:(SJSWordNode *)node1 isConnectedTo:(SJSWordNode *)node2
{
    if (node1.type != WordType && node2.type == WordType) {
        return [wordNetDb word:node2.name isConnectedToMeaning:node1.name];
    }
    
    if (node1.type == WordType && node2.type != WordType) {
        return [wordNetDb word:node1.name isConnectedToMeaning:node2.name];
    }
    
    return false;
}

- (void)update:(NSTimeInterval)currentTime
{
    SKNode *wordNodes = [self childNodeWithName:@"wordNodes"];
    
    double r0 = _springLength * _scale;
    double ka = 1 * _scale;
    double kp = 10000 * _scale;
    
    for (SJSWordNode *me in wordNodes.children) {
        double x1 = me.position.x;
        double y1 = me.position.y;
        
        [me setScale:_scale];
        
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

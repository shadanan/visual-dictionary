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
    BOOL _dragging;
    BOOL _contentCreated;
    CGFloat _anchorRadius;
    CGFloat _springLength;
    CGFloat _scale;
    Theme _theme;
    
    SKNode *_edgeNodes;
    SKNode *_wordNodes;
    
    SJSWordNode *_currentNode;
    SJSWordNode *_root;
    
    SJSSearchView *_searchView;
    SJSDefinitionsView *_definitionsView;
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
    if (!_contentCreated) {
        _contentCreated = true;
        [self createSceneContents];
    }
}

- (void)didChangeSize:(CGSize)oldSize
{
    _searchView.frame = CGRectMake(0, 0, self.width, searchHeight);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _definitionsView.frame = CGRectMake(0, self.height, self.width, definitionsHeightIPhone);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _definitionsView.frame = CGRectMake(0, self.height, self.width, definitionsHeightIPad);
    }
    
    if (_root != nil) {
        _root.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)createSceneContents
{
    NSLog(@"Scale: %f", _scale);
    
    _theme = DevelTheme;
    self.scaleMode = SKSceneScaleModeResizeFill;
    self.backgroundColor = [SKColor backgroundColorWithTheme:_theme];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.speed = 4;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.friction = 0;
    
    _searchView = [[SJSSearchView alloc] initWithFrame:CGRectMake(0, 0, self.width, searchHeight)];
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
    
    
    _edgeNodes = [[SKNode alloc] init];
    _edgeNodes.name = @"edgeNodes";
    [self addChild:_edgeNodes];
    
    _wordNodes = [[SKNode alloc] init];
    _wordNodes.name = @"wordNodes";
    [self addChild:_wordNodes];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _definitionsView = [[SJSDefinitionsView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, definitionsHeightIPhone)];
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _definitionsView = [[SJSDefinitionsView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, definitionsHeightIPad)];
    }
    
    [self.view addSubview:_definitionsView];
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
    if (_root != nil) {
        [self closeSearchPane];
    }
    
    [_definitionsView close];
    
    CGPoint start = [[touches anyObject] locationInNode:self];
    
    _currentNode = nil;
    for (SKNode *node in [self nodesAtPoint:start]) {
        if ([node isKindOfClass:[SJSWordNode class]]) {
            _dragging = NO;
            _currentNode = (SJSWordNode *)node;
            [_currentNode disableDynamic];
        }
        
        if ([node.name isEqualToString:@"searchIcon"]) {
            [self openSearchPane];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_currentNode != nil) {
        _dragging = YES;
        CGPoint point = [[touches anyObject] locationInNode:self];
        _currentNode.position = point;
        
        if (![_anchorPoint hasActions]) {
            if (_anchorPoint.alpha != 0.4 && [_anchorPoint containsPoint:_currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:0.4 duration:0.2];
                [_anchorPoint runAction:fadeIn];
            } else if (_anchorPoint.alpha != 0.2 && ![_anchorPoint containsPoint:_currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:0.2 duration:0.2];
                [_anchorPoint runAction:fadeIn];
            }
        }
        
        if (![_pruneIcon hasActions]) {
            if (_pruneIcon.alpha != 0.4 && [_pruneIcon containsPoint:_currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:0.4 duration:0.2];
                [_pruneIcon runAction:fadeIn];
            } else if (_pruneIcon.alpha != 0.2 && ![_pruneIcon containsPoint:_currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:0.2 duration:0.2];
                [_pruneIcon runAction:fadeIn];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_currentNode != nil) {
        [_currentNode enableDynamic];
        
        if (!_dragging) {
            [_currentNode grow];
            [self updateScene];
            
            [_definitionsView open];
            [_definitionsView setText:[_currentNode getDefinition]];
        }
        
        SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.2];
        [_anchorPoint runAction:fadeOut];
        [_pruneIcon runAction:fadeOut];
        
        if (_dragging && [_anchorPoint containsPoint:_currentNode.position]) {
            [_root enableDynamic];
            [_currentNode disableDynamic];
            
            _root = _currentNode;
            [_root promoteToRoot];
            [self updateScene];
            SKAction *moveToCentre = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:0.2];
            [_root runAction:moveToCentre];
        }
        
        if (_dragging && [_pruneIcon containsPoint:_currentNode.position]) {
            [self prune:_currentNode];
            _currentNode = nil;
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

- (void)clearScene
{
    [_wordNodes removeAllChildren];
    [self updateScene];
}

- (void)createSceneForWord:(NSString *)word
{
    if (![wordNetDb containsWord:word]) {
        [self setMessage:[word stringByAppendingString:@" not found in dictionary"] withDuration:5.0];
        return;
    }
    
    [self closeSearchPane];
    
    [_wordNodes removeAllChildren];
    
    _root = [[SJSWordNode alloc] initWordWithName:word];
    _root.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [_root disableDynamic];
    [_wordNodes addChild:_root];
    
    [_root promoteToRoot];
    [self updateScene];
}

- (void)prune:(SJSWordNode *)node
{
    if (node == _root) {
        [self clearScene];
        [_searchView open];
        return;
    }
    
    [node removeFromParent];
    [_root updateDistances];
    
    for (SJSWordNode *child in _wordNodes.children) {
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
    for (SJSWordNode *node in _wordNodes.children) {
        [node updateCanGrow];
    }
}

- (void)rebuildEdgeNodes
{
    [_edgeNodes removeAllChildren];
    
    for (int i = 0; i < _wordNodes.children.count; i++) {
        SJSWordNode *me = [_wordNodes.children objectAtIndex:i];
        for (int j = i + 1; j < _wordNodes.children.count; j++) {
            SJSWordNode *them = [_wordNodes.children objectAtIndex:j];
            
            if ((me.type != WordType && them.type == WordType && [wordNetDb word:them.name isConnectedToMeaning:me.name]) || (me.type == WordType && them.type != WordType && [wordNetDb word:me.name isConnectedToMeaning:them.name])) {
                SJSEdgeNode *edge = [[SJSEdgeNode alloc] initWithNodeA:me withNodeB:them];
                [_edgeNodes addChild:edge];
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
    double r0 = _springLength * _scale;
    double ka = 1 * _scale;
    double kp = 10000 * _scale;
    
    for (SJSWordNode *me in _wordNodes.children) {
        double x1 = me.position.x;
        double y1 = me.position.y;
        
        [me setScale:_scale];
        
        // No forces on the root
        if (me == _root) {
            continue;
        }
        
        double fx = 0.0;
        double fy = 0.0;
        
        for (SJSWordNode *them in _wordNodes.children) {
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
    for (SJSEdgeNode *edge in _edgeNodes.children) {
        [edge updatePath];
    }    
}

@end

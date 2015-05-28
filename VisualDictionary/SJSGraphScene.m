//
//  SJSGraphScene.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSGraphScene.h"

static SJSTheme *theme = nil;
CGFloat maxScale = 2.5;
CGFloat minScale = 0.25;

@implementation SJSGraphScene {
    BOOL _updateRequired;
    BOOL _dragging;
    BOOL _panning;
    NSInteger _touchCount;
    CGPoint _panPosCurr;
    CGPoint _panPosStart;
    BOOL _scaling;
    CGPoint _positionStart;
    CGFloat _scaleStart;
    CGFloat _scale;
    CGSize _initialSize;
    
    NSInteger _histpos;
    NSMutableArray *_history;
    
    SKNode *_allNodes;
    SKNode *_edgeNodes;
    SKNode *_wordNodes;
    
    SJSWordNode *_activeNode;
    SJSWordNode *_currentNode;
    SJSWordNode *_definitionNode;
    SJSWordNode *_root;
    
    SJSDefinitionsView *_definitionsView;

    SKLabelNode *_wordNode;
    SKLabelNode *_messageNode;
}

+ (void)initialize
{
    if (!theme) {
        theme = [[SJSTheme alloc] initWithTheme:DevelTheme];
    }
}

+ (SJSTheme *)theme
{
    return theme;
}

- (void)didMoveToView:(SKView *)view
{
    if (!_contentCreated) {
        [self createSceneContents];
        _contentCreated = true;
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

- (CGFloat)scale
{
    return _scale;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    self.size = CGSizeMake(_initialSize.width / _scale, _initialSize.height / _scale);
    _wordNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 134 / _scale);
    _messageNode.position = CGPointMake(CGRectGetMidX(self.frame), _wordNode.position.y - [theme wordFontSize] / _scale);
    [_wordNode setScale:1 / _scale];
    [_messageNode setScale:1 / _scale];
}


- (void)createSceneContents
{
    _touchCount = 0;

    self.backgroundColor = [SKColor whiteColor];

    self.anchorPoint = CGPointMake(0.5, 0.5);
    self.scaleMode = SKSceneScaleModeAspectFill;
    _initialSize = self.size;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.speed = 1.0;
    
    self.ka = 1;
    self.r0 = 50;
    self.kp = 10000;
    
    _history = [[NSMutableArray alloc] init];
    _histpos = -1;
    
    _allNodes = [[SKNode alloc] init];
    _allNodes.name = @"allNodes";
    _allNodes.zPosition = 0;
    [self addChild:_allNodes];
    
    _edgeNodes = [[SKNode alloc] init];
    _edgeNodes.name = @"edgeNodes";
    _edgeNodes.zPosition = 50;
    [_allNodes addChild:_edgeNodes];
    
    _wordNodes = [[SKNode alloc] init];
    _wordNodes.name = @"wordNodes";
    _wordNodes.zPosition = 1000;
    [_allNodes addChild:_wordNodes];
    
    CGRect definitionsFrame = CGRectMake(0, self.view.frame.size.height - [theme definitionsHeight] - [theme buttonBarHeight],
                                         self.view.frame.size.width, [theme definitionsHeight]);
    _definitionsView = [[SJSDefinitionsView alloc] initWithFrame:definitionsFrame];
    [self.view addSubview:_definitionsView];

    
    // Create message nodes
    _wordNode = [SKLabelNode new];
    _wordNode.alpha = 0;
    _wordNode.fontColor = [theme wordColor];
    _wordNode.fontName = [theme wordFontName];
    _wordNode.fontSize = [theme wordFontSize];
    _wordNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _wordNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _wordNode.zPosition = 20000;
    [self addChild:_wordNode];
    
    _messageNode = [SKLabelNode new];
    _messageNode.alpha = 0;
    _messageNode.text = @"not found in dictionary";
    _messageNode.fontColor = [theme messageColor];
    _messageNode.fontName = [theme messageFontName];
    _messageNode.fontSize = [theme messageFontSize];
    _messageNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _messageNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _messageNode.zPosition = 20000;
    [self addChild:_messageNode];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [pinch setDelegate:self];
    [self.view addGestureRecognizer:pinch];
    
    self.scale = 1;
    _updateRequired = YES;
}

- (void)setTheme:(Theme)t
{
    theme.theme = t;
    _updateRequired = YES;
}

- (void)update
{
    NSLog(@"Updating all objects.");
    
//    _pruneIcon.fontColor = [theme pruneIconColor];
//    _pruneIcon.fontSize = [theme pruneIconSize];
//    _pruneIcon.alpha = [theme disabledAlpha];
//    _pruneIcon.position = CGPointMake(4, 4 + [theme buttonBarHeight]);
//    
//    _anchorPoint.fillColor = [theme anchorPointColor];
//    _anchorPoint.glowWidth = [theme anchorPointGlowWidth];
//    _anchorPoint.alpha = [theme disabledAlpha];
//    _anchorPoint.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    for (SJSWordNode *node in _wordNodes.children) {
        [node update];
    }
    
    [_edgeNodes removeAllChildren];
    
    for (int i = 0; i < _wordNodes.children.count; i++) {
        SJSWordNode *me = [_wordNodes.children objectAtIndex:i];
        for (int j = i + 1; j < _wordNodes.children.count; j++) {
            SJSWordNode *them = [_wordNodes.children objectAtIndex:j];
            
            if ([me isConnectedTo:them]) {
                SJSEdgeNode *edge = [[SJSEdgeNode alloc] initWithNodeA:me withNodeB:them];
                [_edgeNodes addChild:edge];
            }
        }
    }
    
    if (_definitionNode != nil) {
        [_definitionsView setText:[_definitionNode getDefinition]];
    }
}

- (void)historyAppend:(NSString *)word
{
    if (_histpos >= 0 && _histpos < _history.count) {
        NSString *curr = [_history objectAtIndex:_histpos];
        if ([curr isEqualToString:word]) {
            return;
        }
    }
    
    _histpos += 1;
    while (_histpos < _history.count) {
        [_history removeLastObject];
    }
    
    [_history addObject:word];
}

- (NSString *)historyPrevious
{
    if (_histpos > 0) {
        _histpos -= 1;
        return [_history objectAtIndex:_histpos];
    }
    return nil;
}

- (NSString *)historyNext
{
    if (_histpos < _history.count - 1) {
        _histpos += 1;
        return [_history objectAtIndex:_histpos];
    }
    return nil;
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

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateBegan) {
        _scaleStart = self.scale;
        _scaling = YES;
    } else if ([sender state] == UIGestureRecognizerStateEnded) {
        _scaling = NO;
        _touchCount = 0;
    }
    
    
    self.scale = limitScale(_scaleStart * sender.scale);
    NSLog(@"Scale: %f", self.scale);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchCount += [touches count];
    if (_touchCount != 1) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInNode:_allNodes];
    NSLog(@"Touch Began:  %f %f", pos.x, pos.y);
    
    if (_currentNode != nil) {
        [_currentNode enableDynamic];
    }

    _currentNode = nil;
    _dragging = NO;

    _panning = NO;
    _panPosCurr = [touch locationInNode:self];
    _panPosStart = _allNodes.position;
    
    for (SKNode *node in [_allNodes nodesAtPoint:pos]) {
        if ([node isKindOfClass:[SJSWordNode class]]) {
            _currentNode = (SJSWordNode *)node;
            [_currentNode disableDynamic];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchCount != 1) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInNode:_allNodes];
//    NSLog(@"Touch Moved:  %f %f", pos.x, pos.y);
    
    if (_currentNode == nil) {
        _panning = YES;
        CGPoint curr = [touch locationInNode:self];
        CGFloat x = _panPosStart.x + curr.x - _panPosCurr.x;
        CGFloat y = _panPosStart.y + curr.y - _panPosCurr.y;
        _allNodes.position = CGPointMake(x, y);
    } else {
        _dragging = YES;
        _currentNode.position = pos;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchCount -= [touches count];
    if (_touchCount != 0) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInNode:_allNodes];
    NSLog(@"Touch Ended:  %f %f", pos.x, pos.y);
    
    if (_definitionNode != nil && _currentNode != _definitionNode && !_panning) {
        [_definitionNode reset];
        [_definitionNode enableDynamic];
        _definitionNode = nil;
        [_definitionsView close];
        _updateRequired = YES;
    }
    
    if (_currentNode != nil) {
        if (!_dragging) {
            _definitionNode = _currentNode;
            [_definitionNode disableDynamic];
            [_definitionNode highlight];
            [_currentNode grow];
            [_root updateDistances];
            _updateRequired = YES;
            
            [_definitionsView open];
            [_definitionsView setText:[_definitionNode getDefinition]];
            
            if ([touch tapCount] == 2) {
                [self promoteToRoot:_currentNode];
            }
        }
    }
}

- (void)promoteToRoot:(SJSWordNode *)node
{
    [_root enableDynamic];
    _root = _currentNode;
    [_root disableDynamic];

    [_root promoteToRoot];
    _updateRequired = YES;

    if (_root.type == WordType) {
        [self historyAppend:_root.name];
    }
}

- (void)flashWordNotFound:(NSString *)word
{
    [_wordNode removeAllActions];
    [_messageNode removeAllActions];
    
    _wordNode.text = word;
    _wordNode.xScale = 10;
    _wordNode.yScale = 10;
    _wordNode.alpha = 0;
    _messageNode.xScale = 10;
    _messageNode.yScale = 10;
    _messageNode.alpha = 0;
    
    CGFloat duration = 2.0;
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.25];
    SKAction *scaleIn = [SKAction scaleTo:1 / _scale duration:0.25];
    SKAction *scaleAndFadeIn = [SKAction group:@[fadeIn, scaleIn]];
    
    SKAction *pause = [SKAction waitForDuration:duration - 0.25];
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.25];
    SKAction *scaleOut = [SKAction scaleTo:0.1 duration:0.25];
    SKAction *scaleAndFadeOut = [SKAction group:@[fadeOut, scaleOut]];
    
    SKAction *sequence = [SKAction sequence:@[scaleAndFadeIn, pause, scaleAndFadeOut]];
    
    [_wordNode runAction:sequence];
    [_messageNode runAction:sequence];
}

- (void)clearScene
{
    _root = nil;
    _currentNode = nil;
    
    [_definitionsView close];
    
    for (SJSWordNode *child in _wordNodes.children) {
        [child removeFromParent];
    }
    
    _updateRequired = YES;
}

- (void)createSceneForRandomWord
{
    NSString *word = [SJSWordNetDB.instance getRandomWord];
    [self historyAppend:word];
    [self createSceneForWord:word];
}

- (void)createSceneForWord:(NSString *)word
{
    [self clearScene];

    SKAction *centerRoot = [SKAction moveTo:CGPointMake(0, 0) duration:0.5];
    centerRoot.timingMode = SKActionTimingEaseInEaseOut;
    [_allNodes runAction:centerRoot];
    
    _root = [[SJSWordNode alloc] initWordWithName:word];
    [_root disableDynamic];
    _root.position = self.position;
    [_wordNodes addChild:_root];
    
    [_root promoteToRoot];
    _updateRequired = YES;
}

- (void)prune:(SJSWordNode *)node
{
    if (node == _root) {
        [self clearScene];
        return;
    }
    
    [node removeFromParent];
    [_root updateDistances];
    
    for (SJSWordNode *child in _wordNodes.children) {
        if (child.distance == -1) {
            [child removeFromParent];
        }
    }
    
    _updateRequired = YES;
}

- (void)update:(NSTimeInterval)currentTime
{
    if (_updateRequired) {
        _updateRequired = NO;
        [self update];
    }
    
    for (SJSWordNode *me in _wordNodes.children) {
        float x1 = me.position.x;
        float y1 = me.position.y;
                
        // No forces on the root
        if (me == _root) {
            continue;
        }
        
        float fx = 0;
        float fy = 0;
        
        for (SJSWordNode *them in _wordNodes.children) {
            if (me == them) {
                continue;
            }
            
            float x2 = them.position.x;
            float y2 = them.position.y;
            
            float r = sqrtf(powf(x1 - x2, 2) + powf(y1 - y2, 2)) + 0.1;
            float theta = atan2f(y2 - y1, x2 - x1);
            
            // Repulsive force
            float f = -self.kp / powf(r, 2);
            
            // Attractive force
            if ([me isConnectedTo:them]) {
                f += self.ka * (r - self.r0);
            }
            
            fx += f * cosf(theta);
            fy += f * sinf(theta);
        }
        
        [me.physicsBody applyImpulse:CGVectorMake(limitForce(fx), limitForce(fy))];
    }
}

CGFloat limitForce(CGFloat force)
{
    return MIN(MAX(force, -1000), 1000);
}

- (void)didSimulatePhysics
{
    for (SJSEdgeNode *edge in _edgeNodes.children) {
        [edge update];
    }    
}

@end

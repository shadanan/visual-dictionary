//
//  SJSGraphScene.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSGraphScene.h"

static SJSTheme *theme = nil;

@implementation SJSGraphScene {
    BOOL _updateRequired;
    BOOL _dragging;
    CGFloat _scale;
    CGSize _initialSize;
    
    NSInteger _histpos;
    NSMutableArray *_history;
    
    SKNode *_edgeNodes;
    SKNode *_wordNodes;
    
    SJSWordNode *_activeNode;
    SJSWordNode *_currentNode;
    SJSWordNode *_definitionNode;
    SJSWordNode *_root;
    
    SJSDefinitionsView *_definitionsView;
    SKLabelNode *_pruneIcon;
    SKShapeNode *_anchorPoint;

    SKShapeNode *_splash;
    
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
}


- (void)createSceneContents
{
    self.backgroundColor = [SKColor whiteColor];

    self.anchorPoint = CGPointMake(0.5, 0.5);
    self.scaleMode = SKSceneScaleModeAspectFill;
    _initialSize = self.size;
    _scale = 1;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.speed = 1.0;
    
    self.r0 = 0;
    self.ka = 0.5;
    self.kp = 20000;
    
    _history = [[NSMutableArray alloc] init];
    _histpos = -1;
    
//    _pruneIcon = [SKLabelNode new];
//    _pruneIcon.name = @"pruneIcon";
//    _pruneIcon.text = [[NSString alloc] initWithUTF8String:"\xE2\x99\xBC"];
//    _pruneIcon.alpha = 0;
//    _pruneIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
//    _pruneIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
//    _pruneIcon.zPosition = 50;
//    [self addChild:_pruneIcon];
//    
//    _anchorPoint = [SKShapeNode new];
//    _anchorPoint.name = @"anchorPoint";
//    _anchorPoint.alpha = 0;
//    _anchorPoint.zPosition = 50;
//    
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddArc(path, nil, 0, 0, [theme anchorPointRadius], 0, M_PI*2, YES);
//    _anchorPoint.path = path;
//    CGPathRelease(path);
//    
//    [self addChild:_anchorPoint];
    
    _edgeNodes = [[SKNode alloc] init];
    _edgeNodes.name = @"edgeNodes";
    _edgeNodes.zPosition = 50;
    [self addChild:_edgeNodes];
    
    _wordNodes = [[SKNode alloc] init];
    _wordNodes.name = @"wordNodes";
    _wordNodes.zPosition = 1000;
    [self addChild:_wordNodes];
    
    CGRect definitionsFrame = CGRectMake(0, self.view.frame.size.height - [theme definitionsHeight] - [theme buttonBarHeight],
                                         self.view.frame.size.width, [theme definitionsHeight]);
    _definitionsView = [[SJSDefinitionsView alloc] initWithFrame:definitionsFrame];
    [self.view addSubview:_definitionsView];
    
    // Create the splash
    _splash = [[SKShapeNode alloc] init];
    _splash.name = @"splashNode";
    _splash.zPosition = 15000;
    _splash.strokeColor = [UIColor blackColor];
    _splash.fillColor = [UIColor whiteColor];
    _splash.position = CGPointMake(self.view.frame.size.width / 2,
                                   (self.view.frame.size.height - [theme buttonBarHeight] - 10) / 2 + [theme buttonBarHeight]);
    
    CGRect splashFrame = CGRectMake(-150, -200, 300, 400);
    CGPathRef splashPath = CGPathCreateWithRoundedRect(splashFrame, 2, 2, NULL);
    _splash.path = splashPath;
    CGPathRelease(splashPath);
    
    SKLabelNode *theNode = [[SKLabelNode alloc] init];
    theNode.text = @"THE";
    theNode.fontName = [theme theSaurusFontName];
    theNode.fontSize = 150;
    theNode.fontColor = [UIColor blackColor];
    theNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    theNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    theNode.position = CGPointMake(CGRectGetMidX(splashFrame), CGRectGetMaxY(splashFrame) - 20);
    theNode.zPosition = 2;
    [_splash addChild:theNode];
    
    SKLabelNode *saurusNode = [[SKLabelNode alloc] init];
    saurusNode.text = @"SAURUS";
    saurusNode.fontName = [theme theSaurusFontName];
    saurusNode.fontSize = 68;
    saurusNode.fontColor = [UIColor blackColor];
    saurusNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    saurusNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    saurusNode.position = CGPointMake(CGRectGetMidX(splashFrame), [theNode calculateAccumulatedFrame].origin.y - 10);
    saurusNode.zPosition = 2;
    [_splash addChild:saurusNode];
    
    SKSpriteNode *dinosaurNode = [[SKSpriteNode alloc] init];
    dinosaurNode.texture = [SKTexture textureWithImageNamed:@"brontosaurus.png"];
    CGFloat ratio = dinosaurNode.texture.size.width / dinosaurNode.texture.size.height;
    CGFloat width = splashFrame.size.width - 14;
    dinosaurNode.size = CGSizeMake(width, width / ratio);
    dinosaurNode.anchorPoint = CGPointMake(0.5, 1);
    dinosaurNode.position = CGPointMake(CGRectGetMidX(splashFrame), [saurusNode calculateAccumulatedFrame].origin.y);
    dinosaurNode.zPosition = 1;
    [_splash addChild:dinosaurNode];
    
    SKLabelNode *infoNode = [[SKLabelNode alloc] init];
    infoNode.text = @"An Interactive Visual Thesaurus";
    infoNode.fontName = [theme theSaurusFontName];
    infoNode.fontSize = 12;
    infoNode.fontColor = [UIColor blackColor];
    infoNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    infoNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    infoNode.position = CGPointMake(CGRectGetMidX(splashFrame), CGRectGetMinY(splashFrame) + 10);
    infoNode.zPosition = 2;
    [_splash addChild:infoNode];
    
    [self addChild:_splash];
    
    
    // Create message nodes
    _wordNode = [SKLabelNode new];
    _wordNode.alpha = 0;
    _wordNode.fontColor = [theme wordColor];
    _wordNode.fontName = [theme wordFontName];
    _wordNode.fontSize = [theme wordFontSize];
    _wordNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _wordNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _wordNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 134);
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
    _messageNode.position = CGPointMake(CGRectGetMidX(self.frame), _wordNode.position.y - [theme wordFontSize]);
    _messageNode.zPosition = 20000;
    [self addChild:_messageNode];
    
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

- (void)hideSplash
{
    if (_splash.alpha == 0) {
        return;
    }
    
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.25];
    [_splash runAction:fadeOut];
}

- (void)showSplash
{
    if (_splash.alpha == 1) {
        return;
    }
    
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:0.25];
    [_splash runAction:fadeIn];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInNode:self];
    NSLog(@"Touch Began:  %f %f", pos.x, pos.y);
    
    if (_root == nil) {
        [self showSplash];
    }
    
    _currentNode = nil;
    _dragging = NO;
    
    for (SKNode *node in [self nodesAtPoint:pos]) {
        if ([node isKindOfClass:[SJSWordNode class]]) {
            _currentNode = (SJSWordNode *)node;
            [_currentNode disableDynamic];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInNode:self];
//    NSLog(@"Touch Moved:  %f %f", pos.x, pos.y);
    
    if (_currentNode != nil) {
        _dragging = YES;
        
        _currentNode.position = pos;
        
        CGFloat activeAlpha = [theme activeAlpha];
        CGFloat inactiveAlpha = [theme inactiveAlpha];
        
        if (![_anchorPoint hasActions]) {
            if (_anchorPoint.alpha != activeAlpha && [_anchorPoint containsPoint:_currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:activeAlpha duration:0.2];
                [_anchorPoint runAction:fadeIn];
            } else if (_anchorPoint.alpha != inactiveAlpha && ![_anchorPoint containsPoint:_currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:inactiveAlpha duration:0.2];
                [_anchorPoint runAction:fadeIn];
            }
        }
        
        if (![_pruneIcon hasActions]) {
            if (_pruneIcon.alpha != activeAlpha && [_pruneIcon containsPoint:_currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:activeAlpha duration:0.2];
                [_pruneIcon runAction:fadeIn];
            } else if (_pruneIcon.alpha != inactiveAlpha && ![_pruneIcon containsPoint:_currentNode.position]) {
                SKAction *fadeIn = [SKAction fadeAlphaTo:inactiveAlpha duration:0.2];
                [_pruneIcon runAction:fadeIn];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInNode:self];
    NSLog(@"Touch Ended:  %f %f", pos.x, pos.y);
    
    if (_currentNode != nil && _currentNode != _root) {
        [_currentNode enableDynamic];
    }
    
    if (_definitionNode != nil && _currentNode != _definitionNode) {
        [_definitionNode reset];
        _definitionNode = nil;
        [_definitionsView close];
        _updateRequired = YES;
    }
    
    if (_dragging) {
        if (_currentNode != nil) {
            SKAction *fadeOut = [SKAction fadeAlphaTo:[theme disabledAlpha] duration:0.2];
            [_anchorPoint runAction:fadeOut];
            [_pruneIcon runAction:fadeOut];

            if ([_anchorPoint containsPoint:pos]) {
                [_root enableDynamic];
                _root = _currentNode;
                [_root disableDynamic];
                
                [_root promoteToRoot];
                _updateRequired = YES;
                
                if (_root.type == WordType) {
                    [self historyAppend:_root.name];
                }
                
                SKAction *moveToCentre = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:0.2];
                [_root runAction:moveToCentre];
                
                return;
            }
            
            if ([_pruneIcon containsPoint:pos]) {
                [self prune:_currentNode];
                _currentNode = nil;
                
                return;
            }
        }
    } else {
        if ([_splash containsPoint:pos] && _splash.alpha == 1) {
            return;
        }
        
        if (_currentNode != nil) {
            _definitionNode = _currentNode;
            [_definitionNode highlight];
            [_currentNode grow];
            [_root updateDistances];
            _updateRequired = YES;
            
            [_definitionsView open];
            [_definitionsView setText:[_definitionNode getDefinition]];
        }
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
    SKAction *scaleIn = [SKAction scaleTo:1 duration:0.25];
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
    [self hideSplash];
    
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
        [self showSplash];
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
//        [me.physicsBody applyForce:CGVectorMake(limitForce(fx), limitForce(fy))];
    }
}

CGFloat limitForce(CGFloat force)
{
    //    return force;
    return MIN(MAX(force, -1000), 1000);
}

- (void)didSimulatePhysics
{
    for (SJSEdgeNode *edge in _edgeNodes.children) {
        [edge update];
    }    
}

@end

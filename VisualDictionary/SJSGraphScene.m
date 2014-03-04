//
//  SJSGraphScene.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSGraphScene.h"

CGFloat springLength = 60;

static SJSWordNetDB *wordNetDb = nil;
static SJSTheme *theme = nil;

@implementation SJSGraphScene {
    BOOL _dragging;
    BOOL _contentCreated;
    CGFloat _scale;
    
    NSInteger _histpos;
    NSMutableArray *_history;
    
    SKNode *_edgeNodes;
    SKNode *_wordNodes;
    
    SJSWordNode *_currentNode;
    SJSWordNode *_root;
    
    SJSSearchView *_searchView;
    SJSDefinitionsView *_definitionsView;
    SKLabelNode *_backIcon;
    SKLabelNode *_forwardIcon;
    SKLabelNode *_searchIcon;
    SKLabelNode *_pruneIcon;
    SKShapeNode *_anchorPoint;
}

+ (void)initialize
{
    if (!wordNetDb) {
        wordNetDb = [[SJSWordNetDB alloc] init];
    }
    
    if (!theme) {
        theme = [[SJSTheme alloc] initWithTheme:DevelTheme];
    }
}

+ (SJSWordNetDB *)wordNetDb
{
    return wordNetDb;
}

+ (SJSTheme *)theme
{
    return theme;
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
    if (_root != nil) {
        _root.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
    
    [self update];
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
    self.scaleMode = SKSceneScaleModeResizeFill;
    self.backgroundColor = [theme backgroundColor];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.speed = 4;
    
    _history = [[NSMutableArray alloc] init];
    _histpos = -1;
    
    _searchView = [[SJSSearchView alloc] initWithFrame:CGRectMake(0, 0, self.width, [theme searchHeight])];
    _searchView.delegate = self;
    [self.view addSubview:_searchView];
    
    _backIcon = [SKLabelNode new];
    _backIcon.name = @"backIcon";
    _backIcon.text = [[NSString alloc] initWithUTF8String:"\xE2\x87\xA7"];
    _backIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _backIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _backIcon.zPosition = 200;
    _backIcon.zRotation = M_PI_2;
    _backIcon.hidden = YES;
    [self addChild:_backIcon];
    
    _forwardIcon = [SKLabelNode new];
    _forwardIcon.name = @"forwardIcon";
    _forwardIcon.text = [[NSString alloc] initWithUTF8String:"\xE2\x87\xA7"];
    _forwardIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _forwardIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _forwardIcon.zPosition = 200;
    _forwardIcon.zRotation = -M_PI_2;
    _forwardIcon.hidden = YES;
    [self addChild:_forwardIcon];
    
    _searchIcon = [SKLabelNode new];
    _searchIcon.name = @"searchIcon";
    _searchIcon.text = [[NSString alloc] initWithUTF8String:"\xF0\x9F\x94\x8D"];
    _searchIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _searchIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _searchIcon.zPosition = 200;
    _searchIcon.hidden = YES;
    [self addChild:_searchIcon];
    
    _pruneIcon = [SKLabelNode new];
    _pruneIcon.name = @"pruneIcon";
    _pruneIcon.text = [[NSString alloc] initWithUTF8String:"\xE2\x99\xBC"];
    _pruneIcon.alpha = 0;
    _pruneIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _pruneIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    _pruneIcon.zPosition = 200;
    [self addChild:_pruneIcon];
    
    _anchorPoint = [SKShapeNode new];
    _anchorPoint.name = @"anchorPoint";
    _anchorPoint.alpha = 0;
    [self addChild:_anchorPoint];
    
    
    _edgeNodes = [[SKNode alloc] init];
    _edgeNodes.name = @"edgeNodes";
    [self addChild:_edgeNodes];
    
    _wordNodes = [[SKNode alloc] init];
    _wordNodes.name = @"wordNodes";
    [self addChild:_wordNodes];
    
    _definitionsView = [[SJSDefinitionsView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, [theme definitionsHeight])];
    [self.view addSubview:_definitionsView];
    
    [self update];
    [self openSearchPane];
}

- (CGFloat)scale
{
    return _scale;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    [self update];
}

- (void)setTheme:(Theme)t
{
    theme.theme = t;
    [self update];
}

- (void)update
{
    self.backgroundColor = [theme backgroundColor];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.friction = 0;
    
    if (_histpos <= 0) {
        _backIcon.color = [theme backIconDisabledColor];
        NSLog(@"Back Disabled");
    } else {
        _backIcon.color = [theme backIconEnabledColor];
        NSLog(@"Back Enabled");
    }
    _backIcon.fontSize = [theme backIconSize];
    _backIcon.position = CGPointMake(CGRectGetMinX(self.frame) + [theme backIconSize] / 2 + 8,
                                     CGRectGetMaxY(self.frame) - 34);
    
    if (_histpos == _history.count - 1) {
        _forwardIcon.color = [theme backIconDisabledColor];
        NSLog(@"Forward Disabled");
    } else {
        _forwardIcon.color = [theme backIconEnabledColor];
        NSLog(@"Forward Enabled");
    }
    _forwardIcon.fontSize = [theme forwardIconSize];
    _forwardIcon.position = CGPointMake(CGRectGetMinX(self.frame) + [theme backIconSize] * 3 / 2 + 18,
                                        CGRectGetMaxY(self.frame) - 34);
    
    _searchIcon.fontSize = [theme searchIconSize];
    _searchIcon.position = CGPointMake(CGRectGetMaxX(self.frame) - 4, CGRectGetMaxY(self.frame) - 20);
    
    _pruneIcon.color = [theme pruneIconColor];
    _pruneIcon.fontSize = [theme pruneIconSize];
    _pruneIcon.position = CGPointMake(4, 4);
    
    _anchorPoint.fillColor = [theme anchorPointColor];
    _anchorPoint.glowWidth = [theme anchorPointGlowWidth];
    _anchorPoint.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, nil, 0, 0, [theme anchorPointRadius] * _scale, 0, M_PI*2, YES);
    _anchorPoint.path = path;
    CGPathRelease(path);
    
    [_definitionsView close];
    _definitionsView.frame = CGRectMake(0, self.height, self.width, [theme definitionsHeight]);
    
    [self closeSearchPane];
    _searchView.frame = CGRectMake(0, -[theme searchHeight], self.width, [theme searchHeight]);
    
    for (SJSWordNode *node in _wordNodes.children) {
        [node update];
    }
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *word = [[textField.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![wordNetDb containsWord:word]) {
        [self setMessage:[word stringByAppendingString:@" not found in dictionary"] withDuration:2.0];
    } else {
        [self closeSearchPane];
        [self createSceneForWord:word];
        [self historyAppend:word];
    }
    
    return NO;
}

- (void)historyAppend:(NSString *)word
{
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

- (void)openSearchPane
{
    [_searchView open];
    _backIcon.hidden = YES;
    _forwardIcon.hidden = YES;
    _searchIcon.hidden = YES;
}

- (void)closeSearchPane
{
    [_searchView close];
    _backIcon.hidden = NO;
    _forwardIcon.hidden = NO;
    _searchIcon.hidden = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_root != nil) {
        [self closeSearchPane];
    }
    
    _currentNode = nil;
    _dragging = NO;
    [_definitionsView close];
    
    CGPoint start = [[touches anyObject] locationInNode:self];
    for (SKNode *node in [self nodesAtPoint:start]) {
        if ([node isKindOfClass:[SJSWordNode class]]) {
            _currentNode = (SJSWordNode *)node;
            [_currentNode disableDynamic];
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
    CGPoint end = [[touches anyObject] locationInNode:self];
    
    if (_dragging) {
        if (_currentNode != nil) {
            [_currentNode enableDynamic];
            
            SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.2];
            [_anchorPoint runAction:fadeOut];
            [_pruneIcon runAction:fadeOut];

            if ([_anchorPoint containsPoint:end]) {
                [_root enableDynamic];
                [_currentNode disableDynamic];
                
                _root = _currentNode;
                [_root promoteToRoot];
                [self update];
                [self historyAppend:_root.name];
                
                SKAction *moveToCentre = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:0.2];
                [_root runAction:moveToCentre];
                
                return;
            }
            
            if ([_pruneIcon containsPoint:end]) {
                [self prune:_currentNode];
                _currentNode = nil;
                
                return;
            }
        }
    } else {
        if ([_searchIcon containsPoint:end]) {
            [self openSearchPane];
            return;
        }
        
        if ([_backIcon containsPoint:end]) {
            NSString *previous = [self historyPrevious];
            if (previous != nil) {
                [self createSceneForWord:previous];
            }

            return;
        }
        
        if ([_forwardIcon containsPoint:end]) {
            NSString *next = [self historyNext];
            if (next != nil) {
                [self createSceneForWord:next];
            }
            
            return;
        }
        
        if (_currentNode != nil) {
            [_currentNode grow];
            [self update];
            
            [_definitionsView open];
            [_definitionsView setText:[_currentNode getDefinition]];
        }
    }
}

- (void)setMessage:(NSString *)message withDuration:(NSTimeInterval)duration
{
    SKLabelNode *statusNode = [SKLabelNode new];
    statusNode.text = message;
    statusNode.color = [theme messageColor];
    statusNode.fontName = [theme messageFontName];
    statusNode.fontSize = [theme messageFontSize];
    statusNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    statusNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    statusNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 70);
    statusNode.zPosition = 200;
    
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
    [self update];
}

- (void)createSceneForWord:(NSString *)word
{
    [_wordNodes removeAllChildren];
    
    _root = [[SJSWordNode alloc] initWordWithName:word];
    _root.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [_root disableDynamic];
    [_wordNodes addChild:_root];
    
    [_root promoteToRoot];
    [self update];
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
    
    [self update];
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
    double r0 = springLength * pow(_scale, 2);
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
        [edge update];
    }    
}

@end

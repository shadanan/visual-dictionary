//
//  SJSGraphScene.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSGraphScene.h"

CGFloat springLength = 80;
CGFloat maxScale = 2.5;
CGFloat minScale = 0.25;

static SJSWordNetDB *wordNetDb = nil;
static SJSTheme *theme = nil;
static CGFloat scale = 1;

@implementation SJSGraphScene {
    BOOL _dragging;
    BOOL _contentCreated;
    CGFloat _scaleStart;
    
    NSInteger _histpos;
    NSMutableArray *_history;
    
    SKNode *_edgeNodes;
    SKNode *_wordNodes;
    
    SJSWordNode *_activeNode;
    SJSWordNode *_currentNode;
    SJSWordNode *_root;
    
    SJSSearchView *_searchView;
    SJSDefinitionsView *_definitionsView;
    SKLabelNode *_pruneIcon;
    SKShapeNode *_anchorPoint;
    SKSpriteNode *_backgroundSprite;

    SKShapeNode *_buttonBar;
    SJSIconButton *_backButton;
    SJSIconButton *_forwardButton;
    SJSTextButton *_helpButton;
//    SJSIconButton *_settingsButton;
    SJSSearchButton *_searchButton;
    
    SKShapeNode *_splash;
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

+ (CGFloat)scale
{
    return scale;
}

+ (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
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
        _scaleStart = scale;
    }
    
    scale = limitScale(_scaleStart * recognizer.scale);
    [self update];

    NSLog(@"Scale: %f", scale);
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
    _backgroundSprite = [[SKSpriteNode alloc] init];
    _backgroundSprite.zPosition = -100;
    _backgroundSprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_backgroundSprite];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.speed = 4;
    
    _history = [[NSMutableArray alloc] init];
    _histpos = -1;
    
    _searchView = [[SJSSearchView alloc] initWithFrame:CGRectMake(0, 0, self.width, [theme searchHeight])];
    _searchView.delegate = self;
    [self.view addSubview:_searchView];
    
    _buttonBar = [[SKShapeNode alloc] init];
    _buttonBar.name = @"buttonBar";
    _buttonBar.zPosition = 10000;
    [self addChild:_buttonBar];
    
    _backButton = [[SJSIconButton alloc] init];
    _backButton.text = @"BACK";
    [_backButton setIcon:@"backward_enabled.png"];
    [_backButton setDisabledIcon:@"backward_disabled.png"];
    [_buttonBar addChild:_backButton];
    
    _forwardButton = [[SJSIconButton alloc] init];
    _forwardButton.text = @"FORWARD";
    [_forwardButton setIcon:@"forward_enabled.png"];
    [_forwardButton setDisabledIcon:@"forward_disabled.png"];
    [_buttonBar addChild:_forwardButton];
    
    _helpButton = [[SJSTextButton alloc] init];
    [_helpButton setLabelText:@"HELP"];
    [_helpButton setIconText:[theme helpButtonIconText]];
    [_helpButton setIconFontName:[theme helpButtonFontName]];
    [_buttonBar addChild:_helpButton];
    
//    _settingsButton = [[SJSIconButton alloc] init];
//    _settingsButton.text = @"SETTINGS";
//    [_settingsButton setIcon:@"cog.png"];
//    [_buttonBar addChild:_settingsButton];
    
    _searchButton = [[SJSSearchButton alloc] init];
    [_buttonBar addChild:_searchButton];
    
    _pruneIcon = [SKLabelNode new];
    _pruneIcon.name = @"pruneIcon";
    _pruneIcon.text = [[NSString alloc] initWithUTF8String:"\xE2\x99\xBC"];
    _pruneIcon.alpha = 0;
    _pruneIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _pruneIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    _pruneIcon.zPosition = 50;
    [self addChild:_pruneIcon];
    
    _anchorPoint = [SKShapeNode new];
    _anchorPoint.name = @"anchorPoint";
    _anchorPoint.alpha = 0;
    _anchorPoint.zPosition = 50;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, nil, 0, 0, [theme anchorPointRadius], 0, M_PI*2, YES);
    _anchorPoint.path = path;
    CGPathRelease(path);
    
    [self addChild:_anchorPoint];
    
    _edgeNodes = [[SKNode alloc] init];
    _edgeNodes.name = @"edgeNodes";
    _edgeNodes.zPosition = 50;
    [self addChild:_edgeNodes];
    
    _wordNodes = [[SKNode alloc] init];
    _wordNodes.name = @"wordNodes";
    _wordNodes.zPosition = 1000;
    [self addChild:_wordNodes];
    
    CGRect definitionsFrame = CGRectMake(0, self.view.frame.size.height - [theme definitionsHeight] - [theme buttonBarHeight], self.view.frame.size.width, [theme definitionsHeight]);
    _definitionsView = [[SJSDefinitionsView alloc] initWithFrame:definitionsFrame];
    [self.view addSubview:_definitionsView];
    
    _splash = [[SKShapeNode alloc] init];
    _splash.name = @"splashNode";
    _splash.zPosition = 15000;
    _splash.strokeColor = [UIColor blackColor];
    _splash.fillColor = [UIColor whiteColor];
    
    CGRect splashFrame = CGRectMake(10, [theme buttonBarHeight] + 10,
                                    self.view.frame.size.width - 20,
                                    self.view.frame.size.height - [theme buttonBarHeight] - 34);
    CGPathRef splashPath = [SJSGraphScene newPathForRoundedRect:splashFrame radius:2];
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
    
    [self update];
}

- (void)setTheme:(Theme)t
{
    theme.theme = t;
    [self update];
}

- (void)update
{
    [theme updateBackgroundSprite:_backgroundSprite];
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, [theme buttonBarHeight], self.frame.size.width, self.frame.size.height - [theme buttonBarHeight])];
    self.physicsBody.friction = 0;
    
    CGMutablePathRef buttonBarPath = CGPathCreateMutable();
    CGPathAddRect(buttonBarPath, nil, CGRectMake(-1, -1, self.frame.size.width + 2, [theme buttonBarHeight] + 1));
    _buttonBar.path = buttonBarPath;
    CGPathRelease(buttonBarPath);
    
    _buttonBar.strokeColor = [theme buttonBarStrokeColor];
    _buttonBar.lineWidth = 1;
    _buttonBar.fillColor = [theme buttonBarFillColor];
    _buttonBar.antialiased = NO;
    
    _backButton.frame = [theme backButtonFrameInFrame:_buttonBar.frame];
    _forwardButton.frame = [theme forwardButtonFrameInFrame:_buttonBar.frame];
    _helpButton.frame = [theme helpButtonFrameInFrame:_buttonBar.frame];
//    _settingsButton.frame = [theme settingsButtonFrameInFrame:_buttonBar.frame];
    _searchButton.frame = [theme searchButtonFrameInFrame:_buttonBar.frame];
    
    if (_histpos <= 0) {
        [_backButton disable];
    } else {
        [_backButton enable];
    }
    
    if (_histpos == _history.count - 1) {
        [_forwardButton disable];
    } else {
        [_forwardButton enable];
    }
    
    _pruneIcon.fontColor = [theme pruneIconColor];
    _pruneIcon.fontSize = [theme pruneIconSize];
    _pruneIcon.alpha = [theme disabledAlpha];
    _pruneIcon.position = CGPointMake(4, 4 + [theme buttonBarHeight]);
    
    _anchorPoint.fillColor = [theme anchorPointColor];
    _anchorPoint.glowWidth = [theme anchorPointGlowWidth];
    _anchorPoint.alpha = [theme disabledAlpha];
    _anchorPoint.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    [_definitionsView close];
    
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
    
    if ([word isEqualToString:@""]) {
        [self closeSearchPane];
    } else if (![wordNetDb containsWord:word]) {
        [self flashWordNotFound:word];
    } else {
        [self closeSearchPane];
        [self historyAppend:word];
        [self createSceneForWord:word];
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

- (void)openSearchPane
{
    [self hideSplash];
    [_searchView open];
}

- (void)closeSearchPane
{
    [_searchView close];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeSearchPane];
    if (_root == nil) {
        [self showSplash];
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
        if (point.y < [theme buttonBarHeight]) {
            _currentNode.position = CGPointMake(point.x, [theme buttonBarHeight]);
        } else {
            _currentNode.position = point;
        }
        
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
    CGPoint end = [[touches anyObject] locationInNode:self];
    NSLog(@"Touch Ended:  %f %f", end.x, end.y);
    
    if (_currentNode != nil && _currentNode != _root) {
        [_currentNode enableDynamic];
    }
    
    if (_dragging) {
        if (_currentNode != nil) {
            SKAction *fadeOut = [SKAction fadeAlphaTo:[theme disabledAlpha] duration:0.2];
            [_anchorPoint runAction:fadeOut];
            [_pruneIcon runAction:fadeOut];

            if ([_anchorPoint containsPoint:end]) {
                [_root enableDynamic];
                _root = _currentNode;
                [_root disableDynamic];
                
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
        if ([_backButton containsPoint:end]) {
            NSString *previous = [self historyPrevious];
            if (previous != nil) {
                [self createSceneForWord:previous];
            }

            return;
        }
        
        if ([_forwardButton containsPoint:end]) {
            NSString *next = [self historyNext];
            if (next != nil) {
                [self createSceneForWord:next];
            }
            
            return;
        }
        
        if ([_helpButton containsPoint:end]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GoToAboutViewController" object:self];
            return;
        }
        
//        if ([_settingsButton containsPoint:end]) {
//            NSLog(@"Settings clicked!");
//            return;
//        }
        
        if ([_searchButton containsPoint:end]) {
            [self openSearchPane];
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

- (void)flashWordNotFound:(NSString *)word
{
    SKLabelNode *wordNode = [SKLabelNode new];
    wordNode.text = word;
    wordNode.fontColor = [theme wordColor];
    wordNode.fontName = [theme wordFontName];
    wordNode.fontSize = [theme wordFontSize];
    wordNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    wordNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    wordNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 134);
    wordNode.zPosition = 20000;
    [self addChild:wordNode];
    
    SKLabelNode *messageNode = [SKLabelNode new];
    messageNode.text = @"not found in dictionary";
    messageNode.fontColor = [theme messageColor];
    messageNode.fontName = [theme messageFontName];
    messageNode.fontSize = [theme messageFontSize];
    messageNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    messageNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    messageNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 114);
    messageNode.zPosition = 20000;
    [self addChild:messageNode];
    
    CGFloat duration = 2.0;
    SKAction *moveDown = [SKAction moveByX:0 y:-50 duration:duration];
    
    SKAction *pause = [SKAction waitForDuration:duration - 0.5];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5];
    SKAction *pauseThenFadeOut = [SKAction sequence:@[pause, fadeOut]];
    SKAction *moveDownAndFadeOut = [SKAction group:@[moveDown, pauseThenFadeOut]];
    
    SKAction *remove = [SKAction removeFromParent];
    SKAction *sequence = [SKAction sequence:@[moveDownAndFadeOut, remove]];
    
    [wordNode runAction:sequence];
    [messageNode runAction:sequence];
}

- (void)clearScene
{
    _root = nil;
    _currentNode = nil;
    
    for (SJSWordNode *child in _wordNodes.children) {
        [child removeFromParent];
    }
    
    [self update];
}

- (void)createSceneForRandomWord
{
    [self hideSplash];
    
    NSString *word = [wordNetDb getRandomWord];
    [self historyAppend:word];
    [self createSceneForWord:word];
}

- (void)createSceneForWord:(NSString *)word
{
    [self clearScene];
    
    _root = [[SJSWordNode alloc] initWordWithName:word];
    [_root disableDynamic];
    _root.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [_wordNodes addChild:_root];
    
    [_root promoteToRoot];
    [self update];
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
    double r0 = springLength * scale;
    double ka = 1 * scale;
    double kp = 10000 * scale;
    
    for (SJSWordNode *me in _wordNodes.children) {
        double x1 = me.position.x;
        double y1 = me.position.y;
                
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

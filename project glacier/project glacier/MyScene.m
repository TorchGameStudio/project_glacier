//
//  MyScene.m
//  project glacier
//
//  Created by Bruce Rick on 2014-08-26.
//  Copyright (c) 2014 Bruce Rick. All rights reserved.
//

#import "MyScene.h"
#import "GameData.h"

#define GLACIER_MARGINS 20

#define ENEMY_SPAWN_START_TIME 0.2
#define ENEMY_START_SPEED 20

#define DAMAGE_SIZE_DECREASE 0.95

static inline CGFloat skRandf(){
    return arc4random() / (CGFloat) RAND_MAX;
}
static inline CGFloat getRandomNumberBetween(CGFloat low, CGFloat high){
    return skRandf() * (high - low) + low;
}

enum {
    
    YUP = 0,
    YDOWN,
    XLEFT,
    XRIGHT
    
} EnemyStartPosition;

@implementation MyScene
{
    BOOL _isGameRunning;
    float _previousEnemySpawnTime;
    
    float _enemySpawnTime;
    float _enemySpeed;
    float _enemiesToSpawn;
    
    NSMutableArray *_enemiesToDelete;
    int _score;
}

///--------------------------------------------------
/// Init Methods
///--------------------------------------------------
#pragma mark - Init Methods

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
      [self _init];
    }
    return self;
}

- (void)_init
{
    _isGameRunning = false;
    _previousEnemySpawnTime = 0;
    _enemySpawnTime = ENEMY_SPAWN_START_TIME;
    _enemySpeed = ENEMY_START_SPEED;
    _enemiesToSpawn = 1;
  
    _enemiesToDelete = [[NSMutableArray alloc] init];
    self.enemies = [[NSMutableArray alloc] init];
    [self _initGameBackground];
    [self _initPlayer];
    [self _initMenu];
    [self _initHighScoreLabel];
}

- (void)_initMenu
{
    self.menuBackground = [[SKSpriteNode alloc] initWithImageNamed:@"Menu"];
    self.menuBackground.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.playButton = [[SKSpriteNode alloc] initWithImageNamed:@"PlayButton"];
    self.playButton.position = CGPointMake(self.frame.size.width/1.9, self.frame.size.height/5);
    [self addChild:self.menuBackground];
    [self addChild:self.playButton];
}

- (void)_initPlayer
{
    self.player = [[SKSpriteNode alloc] initWithImageNamed:@"Player"];
    self.player.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addChild:self.player];
}

- (void)_initGameBackground
{
    self.gameBackground = [[SKSpriteNode alloc] initWithImageNamed:@"GameBackground"];
    self.gameBackground.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addChild:self.gameBackground];
}

- (void)_initScoreLabel
{
    [self.scoreLabel removeFromParent];
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", _score];
    self.scoreLabel.fontSize = 20;
    self.scoreLabel.fontColor = [SKColor blackColor];
    self.scoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - self.scoreLabel.frame.size.height/2);
    [self addChild:self.scoreLabel];
}

- (void)_initHighScoreLabel
{
    [self.highScoreLabel removeFromParent];
    self.highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    self.highScoreLabel.text = [NSString stringWithFormat:@"High Score: %ld", [GameData sharedGameData].highScore];
    self.highScoreLabel.fontSize = 20;
    self.highScoreLabel.fontColor = [SKColor blackColor];
    self.highScoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/5.5 - self.highScoreLabel.frame.size.height * 2);
    [self addChild:self.highScoreLabel];
}

///--------------------------------------------------
/// Static Methods
///--------------------------------------------------
#pragma mark - Static Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint touchLocation = [t locationInNode:self.scene];
    
    if(!_isGameRunning)
    {
        [self _checkIfMenuItemTappedWithLocation:touchLocation];
    }
    else
    {
        for(SKSpriteNode *enemy in _enemies)
        {
            BOOL enemyTapped = CGRectContainsPoint(enemy.frame, touchLocation);
            if(enemyTapped)
            {
                [_enemiesToDelete addObject:enemy];
                [enemy removeFromParent];
                _score += 10;
            }
        }
    }
}

- (void)update:(CFTimeInterval)currentTime
{
    [self _deleteEnemies];
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", _score];
  
    if(_isGameRunning)
    {
        if(currentTime - _previousEnemySpawnTime > _enemySpawnTime)
        {
            _score += 1;
            _previousEnemySpawnTime = currentTime;
            //_enemySpawnTime /= 1.01;
            _enemySpeed /= 1.025
          ;
            [self _spawnEnemy];
        }
        
        for(SKSpriteNode *enemy in self.enemies)
        {
            BOOL enemyHitPlayer = CGRectIntersectsRect(enemy.frame, self.player.frame);
            if(enemyHitPlayer)
            {
                [_enemiesToDelete addObject:enemy];
                
                float playerScale = (self.player.size.width*DAMAGE_SIZE_DECREASE)/self.player.size.width*self.player.xScale;
                [self.player setScale:playerScale];
            }
        }
      
        BOOL isGameOver = self.player.size.width*self.player.xScale < DAMAGE_SIZE_DECREASE*4;
        if(isGameOver)
        {
          _isGameRunning = NO;
          [_enemiesToDelete addObjectsFromArray:self.enemies];
          [self _deleteEnemies];
          [self _endGame];
        }
      
    }
}

///--------------------------------------------------
/// Utility Methods
///--------------------------------------------------
#pragma mark - Utility Methods

- (void)_checkIfMenuItemTappedWithLocation:(CGPoint)touchLocation
{
    BOOL playButtonTapped = CGRectContainsPoint(self.playButton.frame, touchLocation);
    if(playButtonTapped)
    {
        [self _startGame];
    }
}

- (void)_spawnEnemy
{
    for(int i = 0; i < _enemiesToSpawn; i++)
    {
    
        SKSpriteNode *enemy = [[SKSpriteNode alloc] initWithImageNamed:@"Enemy"];
        
        enemy.position = [self _randomEnemyPosition];
        SKAction *moveToCenter = [SKAction moveTo:self.player.position duration:_enemySpeed];
        [enemy runAction:moveToCenter];
        
        [self.enemies addObject:enemy];
        [self addChild:enemy];
    }
}

- (CGPoint)_randomEnemyPosition
{
    CGPoint enemyPosition;
    
    int StartPosition = getRandomNumberBetween(0,3);
    
    SKSpriteNode *enemySprite = [[SKSpriteNode alloc] initWithImageNamed:@"Enemy"];
    
    switch (StartPosition)
    {
            case YUP:
            enemyPosition = CGPointMake(getRandomNumberBetween(1, self.frame.size.width),
                                        self.frame.size.height + enemySprite.frame.size.height);
            break;
            
            case YDOWN:
            enemyPosition = CGPointMake(getRandomNumberBetween(1, self.frame.size.width),
                                        0 - enemySprite.frame.size.height);
            break;
            
            case XLEFT:
            enemyPosition = CGPointMake(0 - enemySprite.frame.size.width,
                                        getRandomNumberBetween(1, self.frame.size.height));
            break;
            
            case XRIGHT:
            enemyPosition = CGPointMake(self.frame.size.width + enemySprite.frame.size.width,
                                        getRandomNumberBetween(1, self.frame.size.height));
            break;
            
            default:
            break;
    }
  
    //Help increase randomness
    if(abs(enemyPosition.x - enemyPosition.y) < 50)
    {
      return [self _randomEnemyPosition];
    }
  
    return enemyPosition;
}

- (CGSize)_playerStartSize
{
    return CGSizeMake(self.frame.size.width - GLACIER_MARGINS*2,
                      self.frame.size.height - GLACIER_MARGINS*2);
}

- (void)_startGame
{
    _isGameRunning = true;
    self.playButton.hidden = TRUE;
    self.menuBackground.hidden = TRUE;
    self.highScoreLabel.hidden = TRUE;
    _score = 0;
    [self _initScoreLabel];
}

- (void)_endGame
{
    float highscore = [GameData sharedGameData].highScore;
    if(_score > highscore)
    {
        [[GameData sharedGameData] setHighScore:_score];
        [[GameData sharedGameData] save];
    }
    
    [self _init];
    [self _initScoreLabel];
}

- (void)_deleteEnemies
{
  for(SKSpriteNode *enemy in _enemiesToDelete)
  {
    [enemy removeFromParent];
  }
  
  [self.enemies removeObjectsInArray:_enemiesToDelete];
  _enemiesToDelete = [[NSMutableArray alloc] init];
}

@end;

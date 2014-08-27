//
//  MyScene.m
//  project glacier
//
//  Created by Bruce Rick on 2014-08-26.
//  Copyright (c) 2014 Bruce Rick. All rights reserved.
//

#import "MyScene.h"

#define GLACIER_MARGINS 20

#define ENEMY_SPAWN_START_TIME 0.2
#define ENEMY_START_SPEED 3
#define ENEMY_WIDTH 20
#define ENEMY_HEIGHT 20

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
    
}

///--------------------------------------------------
/// Init Methods
///--------------------------------------------------
#pragma mark - Init Methods

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        _isGameRunning = false;
        _previousEnemySpawnTime = 0;
        _enemySpawnTime = ENEMY_SPAWN_START_TIME;
        _enemySpeed = ENEMY_START_SPEED;
        _enemiesToSpawn = 1;
        
        _enemiesToDelete = [[NSMutableArray alloc] init];
        self.enemies = [[NSMutableArray alloc] init];
        
        [self _initPlayer];
        [self _initMenu];
    }
    return self;
}

- (void)_initMenu
{
    self.playButton = [[SKSpriteNode alloc] initWithImageNamed:@"PlayButton"];
    self.playButton.position = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    [self addChild:self.playButton];
}

- (void)_initPlayer
{
    self.player = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:[self _playerStartSize]];
    self.player.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addChild:self.player];
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
            if(CGRectContainsPoint(enemy.frame, touchLocation))
            {
                [_enemiesToDelete addObject:enemy];
                [enemy removeFromParent];
            }
        }
    }
}

- (void)update:(CFTimeInterval)currentTime
{
    if(_isGameRunning)
    {
        if(currentTime - _previousEnemySpawnTime > _enemySpawnTime)
        {
            _previousEnemySpawnTime = currentTime;
            //_enemySpawnTime /= 1.05;
            //_enemySpeed /= 1.05;
            [self _spawnEnemy];
        }
        
        for(SKSpriteNode *enemy in self.enemies)
        {
            if(CGRectIntersectsRect(enemy.frame, self.player.frame))
            {
                [_enemiesToDelete addObject:enemy];
                [enemy removeFromParent];
                
                float playerScale = (self.player.size.width*DAMAGE_SIZE_DECREASE)/self.player.size.width*self.player.xScale;
                [self.player setScale:playerScale];
                
                
                if(self.player.size.width*self.player.xScale < DAMAGE_SIZE_DECREASE)
                {
                    _isGameRunning = NO;
                }
            }
        }
        
        [self.enemies removeObjectsInArray:_enemiesToDelete];
        _enemiesToDelete = [[NSMutableArray alloc] init];
    }
}

///--------------------------------------------------
/// Utility Methods
///--------------------------------------------------
#pragma mark - Utility Methods

- (void)_checkIfMenuItemTappedWithLocation:(CGPoint)touchLocation
{
    if(CGRectContainsPoint(self.playButton.frame, touchLocation))
    {
        _isGameRunning = true;
        self.playButton.hidden = TRUE;
    }
}

- (void)_spawnEnemy
{
    for(int i = 0; i < _enemiesToSpawn; i++)
    {
    
        SKSpriteNode *enemy = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor]
                                                             size:CGSizeMake(ENEMY_WIDTH, ENEMY_HEIGHT)];
        
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
    
    switch (StartPosition)
    {
            case YUP:
            enemyPosition = CGPointMake(getRandomNumberBetween(0, self.frame.size.width),
                                        self.frame.size.height + ENEMY_HEIGHT);
            break;
            
            case YDOWN:
            enemyPosition = CGPointMake(getRandomNumberBetween(0, self.frame.size.width),
                                        0 - ENEMY_HEIGHT);
            break;
            
            case XLEFT:
            enemyPosition = CGPointMake(0 - ENEMY_WIDTH,
                                        getRandomNumberBetween(0, self.frame.size.height));
            break;
            
            case XRIGHT:
            enemyPosition = CGPointMake(self.frame.size.width + ENEMY_WIDTH,
                                        getRandomNumberBetween(0, self.frame.size.height));
            break;
            
            default:
            break;
    }
    
    return enemyPosition;
}

- (CGSize)_playerStartSize
{
    return CGSizeMake(self.frame.size.width - GLACIER_MARGINS*2,
                      self.frame.size.height - GLACIER_MARGINS*2);
}





@end

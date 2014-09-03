//
//  MyScene.h
//  project glacier
//

//  Copyright (c) 2014 Bruce Rick. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene

@property (nonatomic, strong) SKSpriteNode *playButton;
@property (nonatomic, strong) SKSpriteNode *menuBackground;
@property (nonatomic, strong) SKSpriteNode *gameBackground;
@property (nonatomic, strong) SKSpriteNode *player;
@property (nonatomic, strong) NSMutableArray *enemies;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, strong) SKLabelNode *highScoreLabel;

@end

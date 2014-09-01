//
//  GameData.h
//  project glacier
//
//  Created by Bruce Rick on 2014-09-01.
//  Copyright (c) 2014 Bruce Rick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject <NSCoding>

@property (assign, nonatomic) long highScore;

+ (instancetype)sharedGameData;
- (void)save;

@end

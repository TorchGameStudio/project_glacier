//
//  GameData.m
//  project glacier
//
//  Created by Bruce Rick on 2014-09-01.
//  Copyright (c) 2014 Bruce Rick. All rights reserved.
//

#import "GameData.h"
#import "KeychainWrapper.h"

@implementation GameData

static NSString* const SSGameDataHighScoreKey = @"highScore";
static NSString* const SSGameDataChecksumKey = @"SSGameDataChecksumKey";

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self)
    {
        _highScore = [decoder decodeDoubleForKey: SSGameDataHighScoreKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.highScore forKey: SSGameDataHighScoreKey];
}

+ (instancetype)sharedGameData
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

+ (NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gamedata"];
    }
    return filePath;
}

+ (instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameData filePath]];
    if (decodedData) {
        //1
        NSString* checksumOfSavedFile = [KeychainWrapper computeSHA256DigestForData: decodedData];
        
        //2
        NSString* checksumInKeychain = [KeychainWrapper keychainStringFromMatchingIdentifier: SSGameDataChecksumKey];
        
        //3
        if ([checksumOfSavedFile isEqualToString: checksumInKeychain]) {
            GameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
            return gameData;
        }
        //4
    }
    
    return [[GameData alloc] init];
}

- (void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[GameData filePath] atomically:YES];
    
    NSString* checksum = [KeychainWrapper computeSHA256DigestForData: encodedData];
    
    if ([KeychainWrapper keychainStringFromMatchingIdentifier: SSGameDataChecksumKey]) {
        [KeychainWrapper updateKeychainValue:checksum forIdentifier:SSGameDataChecksumKey];
    } else {
        [KeychainWrapper createKeychainValue:checksum forIdentifier:SSGameDataChecksumKey];
    }
    
}

@end

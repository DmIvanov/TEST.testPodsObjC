//
//  TFLCLLogger.m
//  SayMeow
//
//  Created by DmIvanov on 27.10.15.
//  Copyright © 2015 Topface. All rights reserved.
//

#import "TFLCLLogger.h"

@implementation TFLCLLogger

static TFLCLLogLevel kTFLCLLogLevel = TFLCLLogLevelShort;

+ (void)setLogLevel:(TFLCLLogLevel)level {
    kTFLCLLogLevel = level;
}

+ (TFLCLLogLevel)currentLevel {
    return kTFLCLLogLevel;
}

+ (void)log:(NSString *)log withLevel:(TFLCLLogLevel)level {
    if (level <= kTFLCLLogLevel) {
        NSLog(@"%@", log);
    }
}

@end

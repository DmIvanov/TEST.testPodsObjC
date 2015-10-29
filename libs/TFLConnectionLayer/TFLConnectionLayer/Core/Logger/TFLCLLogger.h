//
//  TFLCLLogger.h
//  SayMeow
//
//  Created by DmIvanov on 27.10.15.
//  Copyright © 2015 Topface. All rights reserved.
//


typedef NS_ENUM(NSUInteger, TFLCLLogLevel) {
    TFLCLLogLevelSilent,
    TFLCLLogLevelShort,
    TFLCLLogLevelVerbose
};


@interface TFLCLLogger : NSObject

+ (void)setLogLevel:(TFLCLLogLevel)level;
+ (TFLCLLogLevel)currentLevel;

+ (void)log:(NSString *)log withLevel:(TFLCLLogLevel)level;

@end

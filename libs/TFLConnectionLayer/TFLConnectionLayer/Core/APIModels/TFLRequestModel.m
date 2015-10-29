//
//  TFLRequestModel.m
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 12.02.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "TFLRequestModel.h"

@implementation TFLRequestModel

#pragma mark - Setters & getters

+ (BOOL)cacheIsNecessary {
    return NO;
}

+ (BOOL)isAuthorized {
    return YES;
}

+ (NSString *)method {
    return nil;
}

+ (NSString *)errorNotificationName {
    return nil;
}

- (NSString *)jsonRepresentation {
    return nil;
}

- (NSString *)requestId {
    return [NSString stringWithFormat:@"%lX", (unsigned long)self.hash];
}

- (NSTimeInterval)timeoutInterval {
    return 10.0;
}

#pragma mark - Other methods

- (void)send {
    NSAssert(false, @"override this method");
}

@end

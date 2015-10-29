//
//  NSString+UnsignedLongLong.m
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 15.05.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "NSString+UnsignedLongLong.h"

@implementation NSString (UnsignedLongLong)

- (unsigned long long)unsignedLongLongValue {
    return self.longLongValue;
}

@end

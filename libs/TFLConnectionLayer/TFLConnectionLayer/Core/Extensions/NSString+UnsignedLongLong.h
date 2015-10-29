//
//  NSString+UnsignedLongLong.h
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 15.05.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

//  http://stackoverflow.com/questions/27725695/nsinvalidargumentexception-nscfstring-unsignedlonglongvalue-unrecognized-s

#import <Foundation/Foundation.h>

@interface NSString (UnsignedLongLong)

- (unsigned long long)unsignedLongLongValue;

@end

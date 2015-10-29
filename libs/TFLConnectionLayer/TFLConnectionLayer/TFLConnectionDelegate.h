//
//  TFConnectionDelegate.h
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 22.11.13.
//  Copyright (c) 2013 Topface. All rights reserved.
//

#import "TFLCLCustomTypes.h"


@protocol TFLConnectionDelegate <NSObject>

@required
- (void)processResponseJSON:(NSString *)json;
- (NSString *)urlStringForWSConnection;

@optional

/**
 key - HTTP-header
 value - header value
 */
- (NSDictionary *)headersForSocketOpenRequest;

@end

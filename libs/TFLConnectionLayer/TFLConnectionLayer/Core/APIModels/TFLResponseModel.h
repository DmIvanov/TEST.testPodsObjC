//
//  TFLResponseModel.h
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 12.02.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "JSONModel.h"
#import "TFLRequestModel.h"
#import "NSString+UnsignedLongLong.h"


@interface TFLResponseModel : JSONModel

@property (nonatomic, strong) TFLRequestModel<Ignore> *request;

/*!
@abstract
API-method name
*/
+ (NSString *)method;

+ (NSString *)notificationName;

+ (instancetype)objectFromCache;


@end

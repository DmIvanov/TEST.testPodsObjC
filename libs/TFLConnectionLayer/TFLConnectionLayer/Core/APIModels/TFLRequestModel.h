//
//  TFLRequestModel.h
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 12.02.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "JSONModel.h"
#import "NSString+UnsignedLongLong.h"

@interface TFLRequestModel : JSONModel

/*!
 @abstract
 Set YES if you want to check cache before sending the request
 */
@property (nonatomic, strong) NSValue<Ignore> *cacheChecking;

@property (nonatomic, strong) NSNumber<Ignore> *resendingCount;

/*!
 @abstract
 Default is NO, set YES if this model is supposed to cached.
 This value is checking for saving respons
 */
+ (BOOL)cacheIsNecessary;

/*!
 @abstract
 Default is YES, set NO if this request can be sent without server authorization.
 */
+ (BOOL)isAuthorized;

/*!
 @abstract
 API-method that will be used as part of request ID
 */
+ (NSString *)method;

+ (NSString *)errorNotificationName;

/*!
 @abstract
 Start requesting process
 */
- (void)send;

/*!
 @abstract
 JSON that will be sent by TFLConnection
 */
- (NSString *)jsonRepresentation;

- (NSString *)requestId;

- (NSTimeInterval)timeoutInterval;

@end

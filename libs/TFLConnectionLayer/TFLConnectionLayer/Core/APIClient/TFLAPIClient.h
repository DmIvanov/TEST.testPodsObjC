//
//  TFLAPIClient.h
//  TopfaceLib
//
//  Created by Andrei Valkovsky on 23/06/15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

@class TFLRequestModel;

@interface TFLAPIClient : NSObject

///
- (void)sendRequest:(TFLRequestModel *)request;


#pragma mark - Methods to override
///
- (void)processJSONSerializationError:(NSError *)error;

/// 
- (void)processRequestTimeoutError:(NSString *)requestId;

/// Provide mapping operation for mapping json
- (NSOperation *)mappingOperationForJSON:(NSDictionary *)jsonDictionary;


#pragma mark - Working with requests

/// Get request from requests mapping table
- (TFLRequestModel *)requestById:(NSString *)requestId;

/// Remove request from requests mapping table
- (TFLRequestModel *)removeRequestById:(NSString *)requestId;

/// Schedule resending request
- (void)resendRequestById:(NSString *)requestId;

@end

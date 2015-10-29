//
//  TFLOperationManager.h
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 12.02.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

@class TFLRequestModel;


@interface TFLOperationManager : NSObject

+ (instancetype)sharedInstance;

- (id)init __attribute__((unavailable("init is not available, use class methods sharedInstance instead!")));
- (id)new __attribute__((unavailable("new is not available, use class methods sharedInstance instead!")));
+ (id)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable("allocWithZone: is not available, use class methods sharedInstance instead!")));
+ (id)alloc __attribute__((unavailable("alloc is not available, use class methods sharedInstance instead!")));

- (void)addNonAuthorizedNetworkOperationToQueue:(NSOperation *)operation;
- (void)addNetworkOperationToQueue:(NSOperation *)operation;
- (void)addMappingOperationToQueue:(NSOperation *)operation;

/*
 - (void)addTimeoutOperationToQueue:(NSOperation *)operation;
- (void)cancelTimeoutOperationWithRequestId:(NSString *)requestId;
*/

@end

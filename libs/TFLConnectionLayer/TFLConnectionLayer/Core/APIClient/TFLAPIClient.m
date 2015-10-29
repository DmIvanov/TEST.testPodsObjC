//
//  TFLAPIClient.m
//  TopfaceLib
//
//  Created by Andrei Valkovsky on 23/06/15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "TFLAPIClient.h"

#import "TFLOperationManager.h"
#import "TFLConnectionManager.h"
#import "TFLWSConnection.h"
#import "TFLCLLogger.h"

#import "TFLRequestModel.h"
#import "TFLNetworkOperation.h"
#import "TFLProgressiveTimer.h"


@interface TFLAPIClient () <TFLConnectionDelegate>

@property (nonatomic, strong) NSMutableDictionary *requests;
@property (nonatomic, strong) NSMutableDictionary *timers;

@end


@implementation TFLAPIClient

#pragma mark - lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _requests = [NSMutableDictionary new];
        _timers = [NSMutableDictionary new];
        [TFLConnectionManager sharedInstance].delegate = self;
    }
    return self;
}

- (void)sendRequest:(TFLRequestModel *)model {
    if ([self addRequest:model]) {
        [self executeRequest:model];
    }
}

- (void)executeRequest:(TFLRequestModel *)request {
    [self executeNetworkOperationWithRequest:request];
}


#pragma mark - Methods to override

- (void)processJSONSerializationError:(NSError *)error {
    NSAssert(nil, @"override this method");
}

- (NSOperation *)mappingOperationForJSON:(NSDictionary *)jsonDictionary {
    NSAssert(nil, @"override this method");
    return nil;
}

- (void)processRequestTimeoutError:(NSString *)requestId {
    [self.requests removeObjectForKey:requestId];
}


#pragma mark - NetworkOperation

- (void)executeNetworkOperationWithRequest:(TFLRequestModel *)request {
    TFLNetworkOperation *requestOperation = [[TFLNetworkOperation alloc] initWithRequest:request];
    
    // set timeout error handling block
    requestOperation.timeoutBlock = ^{
        TFLRequestModel *pendingRequest = [self.requests objectForKey:request.requestId];
        if (pendingRequest) {
            [self processRequestTimeoutError:pendingRequest.requestId];
        }
    };
    
    if ([request.class isAuthorized]) {
        [[self operationManager] addNetworkOperationToQueue:requestOperation];
    }
    else {
        [[self operationManager] addNonAuthorizedNetworkOperationToQueue:requestOperation];
    }
}

#pragma mark - MappingOperation

- (void)executeMappingOperationWithJSON:(NSDictionary *)jsonDict {
    NSOperation *operation = [self mappingOperationForJSON:jsonDict];
    [[self operationManager] addMappingOperationToQueue:operation];
}

#pragma mark -

- (void)handleIncomingJSON:(NSString *)jsonString {
    NSData *receivedData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonSerializationError = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData
                                                               options:NSJSONReadingMutableLeaves
                                                                 error:&jsonSerializationError];
    if (!jsonObject) {
        NSString *message = [NSString stringWithFormat:@"%@", jsonSerializationError.localizedDescription];
        [TFLCLLogger log:message withLevel:TFLCLLogLevelShort];
        [self processJSONSerializationError:jsonSerializationError];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"INPUT %@", [self apiMethodFromJSONDict:jsonObject]];
    [TFLCLLogger log:message withLevel:TFLCLLogLevelShort];
    NSString *json = [NSString stringWithFormat:@"%@", jsonObject];
    [TFLCLLogger log:json withLevel:TFLCLLogLevelVerbose];
    
    [self executeMappingOperationWithJSON:jsonObject];
}

- (TFLOperationManager *)operationManager {
    return [TFLOperationManager sharedInstance];
}


#pragma mark -

- (BOOL)addRequest:(TFLRequestModel *)request {
    // TODO: check if we already have request
    self.requests[request.requestId] = request;
    return YES;
}

- (TFLRequestModel *)requestById:(NSString *)requestId {
    return self.requests[requestId];
}

- (TFLRequestModel *)removeRequestById:(NSString *)requestId {
    TFLProgressiveTimer *timer = self.timers[requestId];
    if (timer) {
        [timer stop];
    }
    
    TFLRequestModel *request = self.requests[requestId];
    [self.requests removeObjectForKey:requestId];
    return request;
}

- (void)resendRequestById:(NSString *)requestId {
    TFLProgressiveTimer *timer = self.timers[requestId];
    if (timer) {
        return;
    }
    timer = [TFLProgressiveTimer startTimerWithTarget:self selector:@selector(timerFired:)];
    self.timers[requestId] = timer;
}

- (void)timerFired:(TFLProgressiveTimer *)timer {
    NSString *requestId = [self.timers allKeysForObject:timer].lastObject;
    if (!requestId) {
        return;
    }
    
    TFLRequestModel *request = self.requests[requestId];
    [self executeRequest:request];
}

- (NSString *)apiMethodFromJSONDict:(NSDictionary *)jsonDict {
    NSString *method = jsonDict[@"method"];
    return method ? method : @"";
}


#pragma mark - TFLConnectionDelegate

- (void)processResponseJSON:(NSString *)json {
    [self handleIncomingJSON:json];
}

- (NSString *)urlStringForWSConnection {
    NSAssert(nil, @"override this method");
    return nil;
}

@end

//
//  TFLOperationManager.m
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 12.02.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "TFLOperationManager.h"
#import "TFLConnectionManager.h"
#import "TFLNetworkOperation.h"
#import "TFLRequestModel.h"

@interface TFLOperationManager ()
@property (nonatomic, strong) NSOperationQueue *networkQueue;
@property (nonatomic, strong) NSOperationQueue *nonAuthorizedNetworkQueue;
@property (nonatomic, strong) NSOperationQueue *mappingQueue;
/*
@property (nonatomic, strong) NSOperationQueue *timeoutQueue;
 */
@end


@implementation TFLOperationManager

#pragma mark - Lifecycle

+ (instancetype)sharedInstance {
    static TFLOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initUniqueInstance];
        sharedInstance.networkQueue = [NSOperationQueue new];
        [sharedInstance stopNetworkQueue];    //app is not authorized on server
        sharedInstance.nonAuthorizedNetworkQueue = [NSOperationQueue new];
        [sharedInstance stopNonAuthorizedNetworkQueue];   //socket is closed now
        sharedInstance.mappingQueue = [NSOperationQueue new];
        /*
        sharedInstance.timeoutQueue = [NSOperationQueue new];
         */
    });
    return sharedInstance;
}

- (instancetype) initUniqueInstance {
    return [super init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Operations interaction

- (void)addNetworkOperationToQueue:(NSOperation *)operation {
    [self.networkQueue addOperation:operation];
}

- (void)addNonAuthorizedNetworkOperationToQueue:(NSOperation *)operation {
    [self.nonAuthorizedNetworkQueue addOperation:operation];
}

- (void)addMappingOperationToQueue:(NSOperation *)operation {
    [self.mappingQueue addOperation:operation];
}

/*
- (void)addTimeoutOperationToQueue:(NSOperation *)operation {
    [self.timeoutQueue addOperation:operation];
}
 */

/*
- (void)cancelTimeoutOperationWithRequestId:(NSString *)requestId {
    NSArray *operations = [self.timeoutQueue operations];
    for (TFLRequestTimeoutOperation *operation in operations) {
        if ([operation.requestId isEqualToString:requestId]) {
            [operation cancel];
            break;
        }
    }
}
 */

- (void)socketDidOpen {
    [self startNonAuthorizedNetworkQueue];
}

- (void)socketDidClose {
    [self stopNonAuthorizedNetworkQueue];
}


#pragma mark - Start/Stop queues


- (void)startNonAuthorizedNetworkQueue {
    self.nonAuthorizedNetworkQueue.suspended = NO;
}

- (void)stopNonAuthorizedNetworkQueue {
    self.nonAuthorizedNetworkQueue.suspended = YES;
}

- (void)startNetworkQueue {
    self.networkQueue.suspended = NO;
}

- (void)stopNetworkQueue {
    self.networkQueue.suspended = YES;
}

@end

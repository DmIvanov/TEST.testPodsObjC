//
//  TFLNetworkOperation.m
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 16.02.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "TFLNetworkOperation.h"
#import "TFLRequestModel.h"
#import "TFLConnectionManager.h"
#import "TFLWSConnection.h"
#import "TFLHTTPConnection.h"


@interface TFLNetworkOperation()

@property (nonatomic, strong) TFLRequestModel *request;

@end


@implementation TFLNetworkOperation

#pragma mark - Lifecycle

- (instancetype)initWithRequest:(TFLRequestModel *)request {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.request = request;
    return self;
}

- (id)init {
    self = [self initWithRequest:nil];
    return self;
}


#pragma mark - NSOperation methots

- (void)main {
    switch (self.forcedConnection) {
        case TFLConnectionTypeNone:
            [[TFLConnectionManager sharedInstance].currentConnection executeRequest:self.request];
            break;
        case TFLConnectionTypeWS:
            [[TFLConnectionManager sharedInstance].wsConnection executeRequest:self.request];
            break;
        case TFLConnectionTypeHTTP:
            [[TFLConnectionManager sharedInstance].httpConnection executeRequest:self.request];
            break;
        default:
            break;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self.request timeoutInterval] * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   self.timeoutBlock);
}

@end

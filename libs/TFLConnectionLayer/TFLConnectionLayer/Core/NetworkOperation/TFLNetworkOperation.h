//
//  TFLNetworkOperation.h
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 16.02.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "TFLCLCustomTypes.h"

@class TFLRequestModel;


@interface TFLNetworkOperation : NSOperation

/**
 For performing an operation not in TFLConnectionManager->currentConnection
 */
@property (nonatomic) TFLConnectionType forcedConnection;

@property (nonatomic, copy) dispatch_block_t timeoutBlock;

- (instancetype)initWithRequest:(TFLRequestModel *)request;

@end

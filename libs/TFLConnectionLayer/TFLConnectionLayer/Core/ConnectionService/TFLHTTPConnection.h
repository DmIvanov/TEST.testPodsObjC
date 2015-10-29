//
//  TFLHTTPConnection.h
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 01.04.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "TFLConnectionProtocol.h"

@protocol TFLHTTPConnectionDelegate;


@interface TFLHTTPConnection : NSObject <TFLConnectionProtocol>
@property (nonatomic, weak) id<TFLHTTPConnectionDelegate> delegate;
- (void)executeRequest:(NSURLRequest *)request;
- (void)stop;
@end


@protocol TFLHTTPConnectionDelegate <NSObject>
- (void)connectionDidReceiveResponse:(id)response;
- (void)connectionDidFailed;
@optional
- (void)updateProgress:(CGFloat)progress;
@end

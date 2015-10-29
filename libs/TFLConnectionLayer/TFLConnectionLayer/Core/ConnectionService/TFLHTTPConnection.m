//
//  TFLHTTPConnection.m
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 01.04.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "TFLHTTPConnection.h"
#import "TFLCLLogger.h"

@interface TFLHTTPConnection () <NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) long long totalResponseLength;
@end


@implementation TFLHTTPConnection

#pragma mark - TFLConnectionProtocol methods

- (void)executeRequest:(NSURLRequest *)request {
    self.connection = [[NSURLConnection alloc] initWithRequest:request
                                                      delegate:self
                                              startImmediately:YES];
}

- (void)stop {
    [self.connection cancel];
    self.connection = nil;
    [self.responseData setLength:0.0];
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection connectionDidReceiveResponse:(NSHTTPURLResponse *)response {
    self.totalResponseLength = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    if (self.totalResponseLength > 0) {
        [self.delegate updateProgress:(1.0 * self.responseData.length/self.totalResponseLength)];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.responseData.length == 0 && self.totalResponseLength != 0) {
        [self stop];
        [self.delegate connectionDidFailed];
        return;
    }
    
    NSData *response = [self.responseData copy];
    [self stop];
    [self.delegate connectionDidReceiveResponse:response];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@", [error localizedDescription]];
    [TFLCLLogger log:message withLevel:TFLCLLogLevelShort];
    [self stop];
    [self.delegate connectionDidFailed];
}


#pragma mark - Setters & getters

- (TFLConnectionType)connectionType {
    return TFLConnectionTypeHTTP;
}

@end

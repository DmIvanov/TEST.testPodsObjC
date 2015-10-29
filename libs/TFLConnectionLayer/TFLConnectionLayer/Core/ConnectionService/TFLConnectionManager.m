//
//  TFLConnectionManager.m
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 01.04.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "TFLConnectionManager.h"
#import "TFLWSConnection.h"
#import "TFLHTTPConnection.h"
#import "TFLCLNotifications.h"


@interface TFLConnectionManager ()
@property (nonatomic, weak) id<TFLConnectionProtocol> currentConnection;
@property (nonatomic, strong) TFLWSConnection *wsConnection;
@property (nonatomic, strong) TFLHTTPConnection *httpConnection;
@end


@implementation TFLConnectionManager

#pragma mark - Lyfecycle

+ (instancetype)sharedInstance {
    static TFLConnectionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] init];
        [sharedInstance adjustNotificationSubscriptions];
    });
    return sharedInstance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters & getters

- (TFLWSConnection *)wsConnection {
    if (!_wsConnection) {
        _wsConnection = [[TFLWSConnection alloc] init];
    }
    return _wsConnection;
}

- (TFLHTTPConnection *)httpConnection {
    if (!_httpConnection) {
        _httpConnection = [[TFLHTTPConnection alloc] init];
    }
    return _httpConnection;
}


#pragma mark - Application State Notifications

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (self.currentConnection == self.wsConnection) {
        [self.wsConnection closeConnectionIfNeeded];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (self.currentConnection == self.wsConnection) {
        [self.wsConnection openConnectionIfNeeded];
    }
}


#pragma mark - Connection service related methods

- (void)setHTTPAsCurrentConnection {
    self.currentConnection = self.httpConnection;
    [self.wsConnection closeConnectionIfNeeded];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kTFLConnectionManagerDidSwitchConnectionNotification
                                                            object:nil
                                                          userInfo:@{@"connection": @"http"}];
    });
}

- (void)setWSAsCurrentConnection {
    self.currentConnection = self.wsConnection;
    [self.wsConnection openConnectionIfNeeded];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kTFLConnectionManagerDidSwitchConnectionNotification
                                                            object:nil
                                                          userInfo:@{@"connection": @"ws"}];
    });
}


#pragma mark - Other methods

- (void)adjustNotificationSubscriptions {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillEnterForeground:)
                               name:UIApplicationWillEnterForegroundNotification
                             object:nil];
}

- (void)connectionDidReceiveMessage:(NSString *)incomingMessage {
    [self.delegate processResponseJSON:incomingMessage];
}

- (void)openSocketConnection {
    if (self.currentConnection == self.wsConnection) {
        [self.wsConnection openConnectionIfNeeded];
    }
}


@end

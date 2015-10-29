//
//  TFLWSConnection.m
//  TopFaceApp
//
//  Created by Andrei Valkovsky on 15/01/15.
//
//

#import "TFLWSConnection.h"

#import "SRWebSocket.h"
#import "TFLRequestModel.h"
#import "TFLOperationManager.h"
#import "TFLConnectionManager.h"
#import "Reachability.h"
#import "TFLCLLogger.h"


@interface TFLWSConnection () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) TFLRequestModel *currentRequest;
@property (nonatomic, strong) Reachability *internetReachability;

@end


@interface TFLOperationManager (TFLWSConnection)
- (void)socketDidOpen;
- (void)socketDidClose;
@end


@implementation TFLWSConnection

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self adjustNotifications];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - WebSocket interactions

- (void)openConnectionIfNeeded {
    if (self.socket.readyState != SR_OPEN) {
        [self connect];
    }
}

- (void)closeConnectionIfNeeded {
    if (self.socket.readyState == SR_OPEN) {
        [self disconnect];
    }
}

- (void)connect {
    [self.socket open];
}

- (void)disconnect {
    self.socket.delegate = nil;
    [self.socket close];
    self.socket = nil;
    [self socketDidClose];
}

- (void)reconnect {
    [self disconnect];
    [self connect];
}


#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    // TODO: handle scruffy id
    if (![message isKindOfClass:NSString.class]) {
        return;
    }
    [[TFLConnectionManager sharedInstance] connectionDidReceiveMessage:message];
    self.currentRequest = nil;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSString *message = [NSString stringWithFormat:@"WebSocket connected: %@", webSocket];
    [TFLCLLogger log:message withLevel:TFLCLLogLevelVerbose];
    [[TFLOperationManager sharedInstance] socketDidOpen];
    if (self.currentRequest) {
        [self.currentRequest send];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"Web socket failed: %@", error.localizedDescription];
    [TFLCLLogger log:message withLevel:TFLCLLogLevelShort];
    if (error) {
        self.socket.delegate = nil;
        self.socket = nil;
        //[self.delegate connectionDidFailed];
    }
    [self socketDidClose];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSString *message = [NSString stringWithFormat:@"Web socket disconnected: %@", reason];
    [TFLCLLogger log:message withLevel:TFLCLLogLevelShort];
    [self socketDidClose];
    [self reconnect];
}

- (void)socketDidClose {
    [[TFLOperationManager sharedInstance] socketDidClose];
}


#pragma mark - TFLConnectionProtocol methods

- (void)executeRequest:(TFLRequestModel *)request {
    self.currentRequest = request;
    [self executeCurrentRequest];
}


#pragma mark - Other methods

- (void)executeCurrentRequest {
    TFLRequestModel *requestModel = self.currentRequest;
    NSString *jsonString = requestModel.jsonRepresentation;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonSerializationError = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableLeaves
                                                                 error:&jsonSerializationError];
    if (jsonSerializationError) {
        NSString *message = [NSString stringWithFormat:@"%@\n %@", [requestModel.class method], jsonSerializationError.localizedDescription];
        [TFLCLLogger log:message withLevel:TFLCLLogLevelShort];
    }
    if (self.socket.readyState == SR_OPEN) {
        [self.socket send:jsonString];
        NSString *message = [NSString stringWithFormat:@"OUTPUT %@ [%@]", [requestModel.class method], self.urlString];
        [TFLCLLogger log:message withLevel:TFLCLLogLevelShort];
        NSString *json = [NSString stringWithFormat:@"%@", jsonObject];
        [TFLCLLogger log:json withLevel:TFLCLLogLevelVerbose];
    } else {
        NSString *message = [NSString stringWithFormat:@"OUTPUT FAILED\n %@", jsonObject];
        [TFLCLLogger log:message withLevel:TFLCLLogLevelShort];
    }
}

- (void)adjustNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(reachabilityChanged:)
                               name:kReachabilityChangedNotification
                             object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
}


#pragma mark - Internet Reachability

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *newReachability = note.object;
    switch (newReachability.currentReachabilityStatus) {
        case ReachableViaWiFi:
        case ReachableViaWWAN:
            [self internetDidBecomeReachable];
            break;
        case NotReachable:
            [self internetDidBecomeNotReachable];
            break;
        default:
            break;
    }
}

- (void)internetDidBecomeReachable {
    [self openConnectionIfNeeded];
}

- (void)internetDidBecomeNotReachable {
    //have nothing to do: socket will close and send bad news instead of this
}


#pragma mark - Setters & Getters

- (SRWebSocket *)socket {
    if (!_socket) {
        _socket = [[SRWebSocket alloc] initWithURLRequest:[self openSocketRequest]];
        _socket.delegate = self;
    }
    return _socket;
}

- (NSURLRequest *)openSocketRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.serverURL];
    NSDictionary *headers = [[TFLConnectionManager sharedInstance].delegate headersForSocketOpenRequest];
    for (NSString *header in headers.allKeys) {
        [request setValue:headers[header] forHTTPHeaderField:header];
    }
    return request;
}

- (NSURL *)serverURL {
    return [NSURL URLWithString:[self urlString]];
}

- (NSString *)urlString {
    NSString *url = [[TFLConnectionManager sharedInstance].delegate urlStringForWSConnection];
    return url;
}

- (TFLConnectionType)connectionType {
    return TFLConnectionTypeWS;
}

@end

//
//  TFLConnectionManager.h
//  TopfaceLib
//
//  Created by Dmitry Ivanov on 01.04.15.
//  Copyright (c) 2015 Topface. All rights reserved.
//

#import "TFLConnectionDelegate.h"
#import "TFLConnectionProtocol.h"

@class TFLWSConnection;
@class TFLHTTPConnection;
@protocol TFLConnectionManagerDelegate;

@interface TFLConnectionManager : NSObject

@property (nonatomic, readonly, weak) id<TFLConnectionProtocol> currentConnection;
@property (nonatomic, weak) id<TFLConnectionDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)setHTTPAsCurrentConnection;
- (void)setWSAsCurrentConnection;
- (TFLWSConnection *)wsConnection;
- (TFLHTTPConnection *)httpConnection;

- (void)connectionDidReceiveMessage:(NSString *)incomingMessage;

#warning Dirty hack. 
/* Методу тут не место, откровенный костыль для продолжения авторизации, если она проходит через вэб-вью. Открытие сокета в каком-то обработчике смены статуса авторизации ведёт к проблемам при открытии-закрытии сокета при уходе в бэкграунд (там сейчас так же статус перекидываетс в socialNetworkAuthorized). Так что добавил этот метод, чтоб открывать сокет напрямую из менеджера соцсети - что выглядит архитектурно неправильным. Метод открытия сокета не должен быть публичным.
 */
- (void)openSocketConnection;

@end

//
//  TFLWSConnection.h
//  
//
//  Created by Andrei Valkovsky on 15/01/15.
//
//

#import "TFLConnectionProtocol.h"

@interface TFLWSConnection : NSObject <TFLConnectionProtocol>

- (void)openConnectionIfNeeded;
- (void)closeConnectionIfNeeded;

- (void)executeRequest:(TFLRequestModel *)request;

@end

//
//  TFLConnectionProtocol.h
//  
//
//  Created by Andrei Valkovsky on 21/01/15.
//
//

#import "TFLCLCustomTypes.h"

@class TFLRequestModel;


@protocol TFLConnectionProtocol <NSObject>

- (TFLConnectionType)connectionType;
- (void)executeRequest:(TFLRequestModel *)request;

@end

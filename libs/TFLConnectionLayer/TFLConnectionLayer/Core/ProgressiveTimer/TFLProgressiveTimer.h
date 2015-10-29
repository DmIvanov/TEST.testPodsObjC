//
//  TFLProgressiveTimer.h
//
//  Created by Dmitry Ivanov on 06.06.15.
//
//

typedef NSUInteger (^ProgressFunction)(NSUInteger counter);


@interface TFLProgressiveTimer : NSObject

/**
 *  Init and start
 *
 *  @param aTarget   The object to which to send the message specified by aSelector when the timer fires. The timer maintains a weak reference to target.
 *  @param aSelector The message to send to target when the timer fires.
 *  @param function  function that takes fire times counter and returns timeout
                        EXAMPLE:
                            ProgressFunction function = ^ NSUInteger(NSUInteger counter) {
                                return counter*2;
                            };
 *
 *  @return A new TFLProgressiveTimer object, configured according to the specified parameters
 */
+ (instancetype)startTimerWithTarget:(id)aTarget selector:(SEL)aSelector progressFunction:(ProgressFunction)function;


/**
 *  Init and start timer with default function `time = counter * 2`
 *
 *  @param aTarget   The object to which to send the message specified by aSelector when the timer fires. The timer maintains a weak reference to target.
 *  @param aSelector The message to send to target when the timer fires.
 *
 *  @return A new TFLProgressiveTimer object, configured according to the specified parameters
 */
+ (instancetype)startTimerWithTarget:(id)aTarget selector:(SEL)aSelector;


/**
 * @abstract
 * Stop and deallocate timer. Call it when one of the attempts anded successfully, and there is no more necessity of the timer
 * 
 * @warning
 * Timer will be retained and call [target selector:] till you don't call this method
 *
 */
- (void)stop;

@end

//
//  TFLProgressiveTimer.m
//
//  Created by Dmitry Ivanov on 06.06.15.
//
//

#import "TFLProgressiveTimer.h"


@interface TFLProgressiveTimer() {

}
@property (nonatomic, strong) ProgressFunction progressFunction;
@property (nonatomic,) SEL selector;
@property (nonatomic, weak) id target;
@property (nonatomic) NSUInteger counter;
@property (nonatomic, strong) dispatch_source_t currentTimer;
@end


@implementation TFLProgressiveTimer

+ (instancetype)startTimerWithTarget:(id)aTarget selector:(SEL)aSelector {
    ProgressFunction defaultFunction = ^ NSUInteger(NSUInteger counter) {
        return counter*2;
    };
    return [TFLProgressiveTimer startTimerWithTarget:aTarget
                                            selector:aSelector
                                    progressFunction:defaultFunction];
}

+ (instancetype)startTimerWithTarget:(id)aTarget selector:(SEL)aSelector progressFunction:(ProgressFunction)function {
    TFLProgressiveTimer *timer = [[self alloc] init];
    timer.progressFunction = function;
    timer.target = aTarget;
    timer.selector = aSelector;
    timer.counter = 0;
    [timer startNewTimer];
    return timer;
}

- (void)timerFired {
    if (!_target) {
        [self stop];
        return;
    }
    [self startNewTimer];
    [self doAction];
}

- (void)doAction {
    IMP imp = [_target methodForSelector:_selector];
    void (*func)(id, SEL, id) = (void *)imp;
    func(_target, _selector, self);
}

- (void)startNewTimer {
    if (self.currentTimer) {
        [self stop];
    }
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, dispatch_get_main_queue());
    if (!timer) {
        return;
    }
    
    self.currentTimer = timer;
    
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, [self nextDelay] * NSEC_PER_SEC);
    uint64_t interval = 0;
    uint64_t leeway = 1 * NSEC_PER_SEC;
    
    dispatch_source_set_timer(timer, start, interval, leeway);
    dispatch_source_set_event_handler(timer, ^{ [self timerFired]; });

    dispatch_resume(timer);
}

- (NSUInteger)nextDelay {
    _counter++;
    return _progressFunction(_counter);
}

- (void)stop {
    dispatch_source_cancel(self.currentTimer);
    self.currentTimer = nil;
}

- (void)dealloc {
    if (self.currentTimer) {
        [self stop];
    }
}

@end

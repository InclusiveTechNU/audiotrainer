//
//  ATApplicationTimeline.m
//  ATApplicationTimeline
//
//  Created by Tommy McHugh on 10/9/21.
//

#import "ATApplicationTimeline.h"

@implementation ATApplicationTimeline

@synthesize events = _events;

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _startTime = NSProcessInfo.processInfo.systemUptime;
        _events = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)popEvent
{
    [_events removeLastObject];
}

- (void)addEvent:(ATApplicationEvent *)event
{
    double eventTime = NSProcessInfo.processInfo.systemUptime - _startTime;
    event.time = eventTime;
    [_events addObject:event];
}

@end

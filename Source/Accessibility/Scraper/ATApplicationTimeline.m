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
        _startTime = CFAbsoluteTimeGetCurrent();
        _events = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addEvent:(ATApplicationEvent *)event
{
    [_events addObject:event];
}

@end

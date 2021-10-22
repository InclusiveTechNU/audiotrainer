//
//  ATApplicationPlayerBase.m
//  ATApplicationPlayerBase
//
//  Created by Tommy McHugh on 10/21/21.
//

#import "ATApplicationPlayerBase.h"
#import "ATRecording.h"
#import "ATElement.h"
#import "ATApplicationElement.h"
#import "ATWindowElement.h"
#import "ATCachedElement.h"

@implementation ATApplicationPlayerBase

+ (BOOL)isEventCompleted:(ATApplicationEvent *)event inWindow:(ATWindowElement *)window
{
    ATElement *element = [window elementAtLocation:event.location];
    ATCachedElement *cachedElement = [event.userInfo objectForKey:@"element"];
    return [cachedElement isEqualToElement:element];
}

+ (BOOL)areEventsCompleted:(NSArray<ATApplicationEvent *> *)events
             inApplication:(ATApplicationElement *)application
{
    @autoreleasepool {
        // TODO: Maybe have a better way of determining which window it is
        NSMutableSet<NSNumber *> *completedIndexes = [[NSMutableSet alloc] init];
        for (ATWindowElement *window in application.windows)
        {
            for (NSUInteger i = 0; i < events.count; i++)
            {
                
                NSNumber *numIndex = [NSNumber numberWithUnsignedInteger:i];
                if ([completedIndexes containsObject:numIndex])
                {
                    continue;
                }
                ATApplicationEvent *event = [events objectAtIndex:i];
                // TODO: figure out how to do deletres
                if (event.type == kATApplicationEventDeletionEvent)
                {
                    [completedIndexes addObject:numIndex];
                    continue;
                }
                if ([ATApplicationPlayerBase isEventCompleted:event inWindow:window])
                {
                    [completedIndexes addObject:numIndex];
                }
            }
        }
        return completedIndexes.count == events.count;
    }
}

- (instancetype)initWithRecording:(ATRecording *)recording
{
    self = [super init];
    if (self != nil)
    {
        _recording = recording;
        _isPlaying = NO;
    }
    return self;
}

- (void)play
{
    _isPlaying = YES;
    
}

- (void)waitForSectionWithTimeout:(NSTimeInterval)timeout completionHandler:(void(^)(void))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ATApplicationElement *application = [ATApplicationElement applicationWithName:@"GarageBand"];
        for (ATRecordingSection *section in self.recording.sections)
        {
            NSLog(@"Starting new section");
            while (![ATApplicationPlayerBase areEventsCompleted:section.events inApplication:application]) {}
            NSLog(@"Completed Section");
        }
        handler();
    });
}

@end

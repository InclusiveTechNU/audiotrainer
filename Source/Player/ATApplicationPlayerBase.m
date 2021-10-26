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
        _isReadyToPlay = NO;
        _engine = [[AVAudioEngine alloc] init];
        _playerNode = [[AVAudioPlayerNode alloc] init];
        [self setupPlayerNode];
    }
    return self;
}

- (void)setupPlayerNode
{
    if (self.isReadyToPlay)
    {
        return;
    }

    [_engine attachNode:_playerNode];
    [_engine connect:_playerNode to:_engine.mainMixerNode format:self.recording.audioBuffer.format];
    
    NSError *engineError = nil;
    [_engine startAndReturnError:&engineError];
    if (engineError == nil)
    {
        _isReadyToPlay = YES;
    }
}

- (void)playRecordingAtTime:(NSTimeInterval)startTime until:(NSTimeInterval)endTime completionHandler:(void (^)(void))handler
{
    [_playerNode stop];
    AVAudioFrameCount startFrame = startTime * self.recording.audioBuffer.format.sampleRate;
    AVAudioFrameCount frames;
    if (endTime == -1.0)
    {
        frames = self.recording.audioBuffer.frameLength - startFrame;
    }
    else
    {
        NSTimeInterval secondsNeeded = endTime - startTime;
        frames = secondsNeeded * self.recording.audioBuffer.format.sampleRate;
    }
    AVAudioPCMBuffer *sectionBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:self.recording.audioBuffer.format
                                                                    frameCapacity:frames];
    sectionBuffer.frameLength = frames;
    size_t bytesPerFrame = self.recording.audioBuffer.format.streamDescription->mBytesPerFrame;
    size_t bufferSize = bytesPerFrame * sectionBuffer.frameLength;
    for (NSUInteger channel = 0; channel < self.recording.audioBuffer.format.channelCount; channel++)
    {
        memcpy(sectionBuffer.floatChannelData[channel],
               self.recording.audioBuffer.floatChannelData[channel]+startFrame,
               bufferSize);
    }

    __weak ATApplicationPlayerBase *weakSelf = self;
    [_playerNode scheduleBuffer:sectionBuffer completionHandler:^{
        ATApplicationPlayerBase *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_isPlaying = NO;
        }
        handler();
    }];
    [_playerNode play];
    _isPlaying = YES;
}

- (void)playRecordingAtTime:(NSTimeInterval)time completionHandler:(void (^)(void))handler
{
    [self playRecordingAtTime:time until:-1.0 completionHandler:handler];
}

- (void)playSectionAtIndex:(NSUInteger)index
                   timeout:(NSTimeInterval)timeout
         completionHandler:(void (^)(BOOL))handler
{
    if (index >= self.recording.sections.count || !self.isReadyToPlay)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            handler(NO);
        });
        return;
    }

    ATRecordingSection *section = [self.recording.sections objectAtIndex:index];
    NSTimeInterval startTime = 0.0;
    NSTimeInterval pauseTime = section.pauseTime;
    if (index != 0)
    {
        ATRecordingSection *prevSection = [self.recording.sections objectAtIndex:index - 1];
        startTime = prevSection.resumeTime;
    }

    [self playRecordingAtTime:startTime until:pauseTime completionHandler:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            ATApplicationElement *application = [ATApplicationElement applicationWithName:@"GarageBand"];
            while (![ATApplicationPlayerBase areEventsCompleted:section.events inApplication:application]) {};
            handler(YES);
        });
    }];
}

- (void)playEndingWithCompletionHandler:(void(^)(BOOL))handler
{
    NSTimeInterval startTime = 0.0;
    if (self.recording.sections.count > 0)
    {
        ATRecordingSection *endSection = [self.recording.sections objectAtIndex:self.recording.sections.count - 1];
        startTime = endSection.resumeTime;
    }

    [self playRecordingAtTime:startTime completionHandler:^{
        handler(YES);
    }];
}

@end

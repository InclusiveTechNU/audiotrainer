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
#import "ATUnimplementedError.h"

@implementation ATApplicationPlayerBase

@synthesize playing;
@synthesize paused;

- (instancetype)initWithRecording:(ATRecording *)recording
{
    self = [super init];
    if (self != nil)
    {
        playing = NO;
        _recording = recording;
        _isReadyToPlay = NO;
        _engine = [[AVAudioEngine alloc] init];
        _playerNode = [[AVAudioPlayerNode alloc] init];
        [self _setupPlayerNode];
    }
    return self;
}

- (nonnull NSString *)applicationName
{
    @throw [ATUnimplementedError errorWithSelector:_cmd sourceClass:[self class]];
}

- (void)pause {
    // TODO: Implement
}


- (void)restart {
    // TODO: Implement
}


- (void)stop {
    // TODO: Implement
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

    [self _playRecordingAtTime:startTime until:pauseTime completionHandler:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableArray *uncompletedEvents = [NSMutableArray arrayWithArray:section.events];
            ATApplicationElement *application = [ATApplicationElement applicationWithName:@"GarageBand"];
            while(uncompletedEvents.count > 0)
            {
                @autoreleasepool {
                    ATApplicationEvent *event = [uncompletedEvents firstObject];
                    if ([event isCompletedInApplication:application])
                    {
                        [uncompletedEvents removeObjectAtIndex:0];
                    }
                }
            }
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

    [self _playRecordingAtTime:startTime completionHandler:^{
        handler(YES);
    }];
}

- (void)playSectionAtIndex:(NSUInteger)index completionHandler:(nonnull void (^)(BOOL))handler {
    // TODO: Implement
}


- (void)playWithSectionCompletionHandler:(nonnull void (^)(BOOL))handler {
    // TODO: Implement
}


- (void)playWithTimeout:(NSTimeInterval)timeout sectionCompletionHandler:(nonnull void (^)(BOOL))handler {
    // TODO: Implement
}

- (void)_setupPlayerNode
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

- (void)_playRecordingAtTime:(NSTimeInterval)startTime until:(NSTimeInterval)endTime completionHandler:(void (^)(void))handler
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
            strongSelf->playing = NO;
        }
        handler();
    }];
    [_playerNode play];
    playing = YES;
}

- (void)_playRecordingAtTime:(NSTimeInterval)time completionHandler:(void (^)(void))handler
{
    [self _playRecordingAtTime:time until:-1.0 completionHandler:handler];
}

@end

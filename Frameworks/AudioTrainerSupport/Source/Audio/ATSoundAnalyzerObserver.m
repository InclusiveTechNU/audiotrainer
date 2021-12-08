//
//  ATSoundAnalyzerObserver.m
//  Audio Trainer
//
//  Created by Tommy McHugh on 11/17/21.
//

#import "ATSoundAnalyzerObserver.h"

@implementation ATSoundAnalyzerObserver

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _isComplete = NO;
        _ranges = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)request:(id<SNRequest>)request didProduceResult:(id<SNResult>)result
{
    SNClassificationResult *soundResult = result;
    BOOL isSpeaking = NO;
    if ([soundResult.classifications[0].identifier isEqualToString:@"speaking"])
    {
        isSpeaking = YES;
    }
    [_ranges addObject:@{
        @"speaking": @(isSpeaking),
        @"startTime": @(CMTimeGetSeconds(soundResult.timeRange.start)),
        @"duration": @(CMTimeGetSeconds(soundResult.timeRange.duration)),
    }];
}

- (void)request:(id<SNRequest>)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed! %@", error);
}

- (void)requestDidComplete:(id<SNRequest>)request
{
    _isComplete = YES;
    if (_recordingSemaphore != nil)
    {
        dispatch_semaphore_signal(_recordingSemaphore);
    }
}

- (void)createRecordingWithAudioBuffer:(AVAudioPCMBuffer *)buffer completionHandler:(void (^)(ATSpeechRecording *recording))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!_isComplete)
        {
            _recordingSemaphore = dispatch_semaphore_create(0);
            dispatch_semaphore_wait(_recordingSemaphore, DISPATCH_TIME_FOREVER);
        }
        handler([[ATSpeechRecording alloc] initWithSoundAnalysis:_ranges audioBuffer:buffer]);
    });
}

@end

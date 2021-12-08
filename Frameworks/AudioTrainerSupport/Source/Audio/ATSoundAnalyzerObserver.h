//
//  ATSoundAnalyzerObserver.h
//  Audio Trainer
//
//  Created by Tommy McHugh on 11/17/21.
//

#import <Cocoa/Cocoa.h>
#import <SoundAnalysis/SoundAnalysis.h>
#import "ATSpeechRecording.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATSoundAnalyzerObserver : NSObject <SNResultsObserving> {
    BOOL _isComplete;
    NSMutableArray *_ranges;
    dispatch_semaphore_t _Nullable _recordingSemaphore;
}

- (void)createRecordingWithAudioBuffer:(AVAudioPCMBuffer *)buffer completionHandler:(void (^)(ATSpeechRecording *recording))handler;

@end

NS_ASSUME_NONNULL_END

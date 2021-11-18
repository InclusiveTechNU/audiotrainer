//
//  ATSoundAnalyzer.h
//  Audio Trainer
//
//  Created by Tommy McHugh on 11/17/21.
//

#import <Foundation/Foundation.h>
#import <SoundAnalysis/SoundAnalysis.h>
#import "ATAudioRecorder.h"
#import "ATSpeechRecognizerDelegate.h"
#import "ATSpeechRecording.h"
#import "ATSoundAnalyzerObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATSoundAnalyzer : NSObject <ATAudioRecorderDelegate> {
    SNAudioStreamAnalyzer *_streamAnalyzer;
    ATSoundAnalyzerObserver *_observer;
    ATAudioRecorder *_audioRecorder;
    AVAudioPCMBuffer * _Nullable _currentRecording;
    NSTimeInterval _currentRecordingTime;
}

@property (nonatomic, weak, nullable) id<ATSpeechRecognizerDelegate> delegate;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, assign) BOOL isRecording;

- (BOOL)startRecording;
- (void)stopRecording;

@end

NS_ASSUME_NONNULL_END

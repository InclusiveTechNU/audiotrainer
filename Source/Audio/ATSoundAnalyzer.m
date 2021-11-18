//
//  ATSoundAnalyzer.m
//  Audio Trainer
//
//  Created by Tommy McHugh on 11/17/21.
//

#import "ATSoundAnalyzer.h"
#import "BaseSound.h"

@implementation ATSoundAnalyzer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _isRecording = NO;
        _isProcessing = NO;
        _audioRecorder = [[ATAudioRecorder alloc] init];
        _audioRecorder.delegate = self;
        _observer = [[ATSoundAnalyzerObserver alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if (self.isRecording)
    {
        [self stopRecording];
    }
}

- (BOOL)startRecording
{
    if (!ATAudioRecorder.hasPermission)
    {
        // TODO: Create NSError and pass to delegate
        return NO;
    }
    
    _currentRecordingTime = 0.0;
    
    BOOL audioRecording = [_audioRecorder startRecording];
    if (!audioRecording)
    {
        [self _stopRecording];
        return NO;
    }
    _isRecording = YES;

    // TODO: Handle errors
    BaseSound *baseSound = [[BaseSound alloc] init];
    SNClassifySoundRequest *request = [[SNClassifySoundRequest alloc] initWithMLModel:baseSound.model error:nil];
    _streamAnalyzer = [[SNAudioStreamAnalyzer alloc] initWithFormat:_audioRecorder.format];
    [_streamAnalyzer addRequest:request withObserver:_observer error:nil];
    return YES;
}

- (void)stopRecording
{
    if (!self.isRecording)
    {
        return;
    }
    [self _stopRecording];
}

- (void)_stopRecording
{
    [_audioRecorder stopRecordingWithCompletionHandler:^(AVAudioPCMBuffer * _Nullable recording) {
        [self _stopRecognizingWithRecording:recording];
    }];
}

- (void)_stopRecognizingWithRecording:(AVAudioPCMBuffer * _Nullable)recording
{
    _currentRecording = recording;
    _isRecording = NO;
    [_streamAnalyzer completeAnalysis];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self _processRecording];
    });
}

- (void)_processRecording
{
    _isProcessing = YES;
    [_observer createRecordingWithAudioBuffer:_currentRecording completionHandler:^(ATSpeechRecording * _Nonnull recording) {
        _isProcessing = NO;
        [self.delegate speechRecognizer:self didFinishRecognizingSpeech:recording];
    }];
}

- (void)audioRecorder:(ATAudioRecorder *)recorder didCaptureBuffer:(AVAudioPCMBuffer *)buffer atTime:(AVAudioTime *)time
{
    if (!self.isRecording)
    {
        return;
    }
    
    if (_isRecording)
    {
        [_streamAnalyzer analyzeAudioBuffer:buffer atAudioFramePosition:time.sampleTime];
    }
}

- (void)audioRecorder:(ATAudioRecorder *)recorder didFailToRecordWithError:(NSError *)error
{
    NSLog(@"Audio Recording Error: %@", error);
    if (!self.isRecording)
    {
        return;
    }
    [self _stopRecording];
    // TODO: Call to delegate that we failed to begin recording
}

@end

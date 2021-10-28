//
//  ATSpeechRecognizer.m
//  ATSpeechRecognizer
//
//  Created by Tommy McHugh on 10/15/21.
//

#import "ATSpeechRecognizer.h"

@implementation ATSpeechRecognizer

+ (BOOL)hasPermission
{
    return ATSpeechRecognizer.permissionStatus == kATSpeechRecognizerPermissionAuthorized;
}

+ (ATSpeechRecognizerPermissionStatus)permissionStatus
{
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    return [ATSpeechRecognizer _convertPermissionStatus:status];
}

+ (void)requestPermissionWithCompletionHandler:(void (^)(ATSpeechRecognizerPermissionStatus status))handler
{
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        handler([ATSpeechRecognizer _convertPermissionStatus:status]);
    }];
}

+ (ATSpeechRecognizerPermissionStatus)_convertPermissionStatus:(SFSpeechRecognizerAuthorizationStatus)status
{
    if (status == SFSpeechRecognizerAuthorizationStatusAuthorized)
    {
        return kATSpeechRecognizerPermissionAuthorized;
    }
    else if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined)
    {
        return kATSpeechRecognizerPermissionUndetermined;
    }
    return kATSpeechRecognizerPermissionDenied;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _isRecording = NO;
        _isProcessing = NO;
        _recognizer = [[SFSpeechRecognizer alloc] init];
        _recognizer.defaultTaskHint = SFSpeechRecognitionTaskHintDictation;
        _audioRecorder = [[ATAudioRecorder alloc] init];
        _audioRecorder.delegate = self;
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

    if (!ATSpeechRecognizer.hasPermission)
    {
        // TODO: Create NSError and pass to delegate
        return NO;
    }
    
    _currentRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    _currentRequest.shouldReportPartialResults = NO;
    _currentTask = [_recognizer recognitionTaskWithRequest:_currentRequest delegate:self];
    
    BOOL audioRecording = [_audioRecorder startRecording];
    if (!audioRecording)
    {
        [self _stopRecording];
        return NO;
    }
    _isRecording = YES;
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
        self->_currentRecording = recording;
        [self->_currentTask finish];
        self->_isRecording = NO;
        self->_isProcessing = YES;
    }];
}

- (void)audioRecorder:(ATAudioRecorder *)recorder didCaptureBuffer:(AVAudioPCMBuffer *)buffer atTime:(AVAudioTime *)time
{
    if (!self.isRecording)
    {
        return;
    }
    [_currentRequest appendAudioPCMBuffer:buffer];
}

- (void)audioRecorder:(ATAudioRecorder *)recorder didFailToRecordWithError:(NSError *)error
{
    NSLog(@"%@", error);
    if (!self.isRecording)
    {
        return;
    }
    [self _stopRecording];
    // TODO: Call to delegate that we failed to begin recording
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult
{
    ATSpeechRecording *speechRecording = [[ATSpeechRecording alloc] initWithSpeechResult:recognitionResult
                                                                             audioBuffer:_currentRecording];
    _currentResult = nil;
    _currentTask = nil;
    _currentRequest = nil;
    _currentRecording = nil;
    _isProcessing = NO;
    [self.delegate speechRecognizer:self didFinishRecognizingSpeech:speechRecording];
}

@end

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
        _recordingSemaphore = nil;
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
    
    _currentRecordingTime = 0.0;
    _acceptingBuffers = YES;
    _isReady = NO;
    _currentResult = nil;
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
        [self _stopRecognizingWithRecording:recording];
    }];
}

- (void)_stopRecognizingWithRecording:(AVAudioPCMBuffer * _Nullable)recording
{
    _currentRecording = recording;
    _isRecording = NO;
    if (_acceptingBuffers)
    {
        [_currentTask finish];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self _processRecording];
    });
}

- (void)_processRecording
{
    _isProcessing = YES;
    if (!_isReady)
    {
        _recordingSemaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_wait(_recordingSemaphore, DISPATCH_TIME_FOREVER);
    }
    
    double segmentsLength = _currentRecording.format.sampleRate * 2;

    // Calculate minimum speech threshold
    float minimumRMS = 0.0;
    if (_currentResult != nil)
    {
        for (SFTranscriptionSegment *segment in _currentResult.bestTranscription.segments)
        {
            AVAudioFrameCount startFrame = segment.timestamp * _currentRecording.format.sampleRate;
            AVAudioFrameCount frameAmount = segment.duration * _currentRecording.format.sampleRate;
            AVAudioFrameCount endFrame = startFrame + frameAmount;
            double segmentsCount = ceil((endFrame - startFrame) / segmentsLength);
            for (NSUInteger i = 0; i < (NSUInteger) segmentsCount; i++)
            {
                AVAudioFrameCount segmentStartFrame = startFrame + (segmentsLength * i);
                AVAudioFrameCount endFrameCount;
                if (i == segmentsCount - 1)
                {
                    endFrameCount = endFrame - segmentStartFrame;
                }
                else
                {
                    endFrameCount = frameAmount;
                }

                float sampleSum = 0.0;
                for (NSUInteger frame = 0; frame < endFrameCount; frame++)
                {
                    sampleSum += pow(_currentRecording.floatChannelData[0][segmentStartFrame + frame], 2);
                }
                float sampleRMS = sqrt(sampleSum / endFrameCount);
                if (sampleRMS < minimumRMS || minimumRMS == 0.0)
                {
                    minimumRMS = sampleRMS;
                }
            }
        }
    }
    else
    {
        minimumRMS = 0.0095;
    }

    // TODO: Decide whether we should allow the last segment to be the start point for RMS comparison
    NSMutableArray *segments = [[NSMutableArray alloc] init];
    NSTimeInterval segmentsStartTime = 0; //lastSegment.timestamp + lastSegment.duration;
    AVAudioFrameCount segmentsStartFrame = segmentsStartTime * _currentRecording.format.sampleRate;
    if (segmentsStartFrame < _currentRecording.frameLength)
    {
        double segmentsCount = ceil((_currentRecording.frameLength - segmentsStartFrame) / segmentsLength);
        BOOL inSpeech = NO;
        double startSpeechTime = 0.0;
        double endSpeechTime = 0.0;
        for (NSUInteger i = 0; i < (NSUInteger) segmentsCount; i++)
        {
            AVAudioFrameCount segmentStartFrame = segmentsStartFrame + (segmentsLength * i);
            AVAudioFrameCount endFrameCount;
            if (i == segmentsCount - 1)
            {
                endFrameCount = _currentRecording.frameLength - segmentStartFrame;
            }
            else
            {
                endFrameCount = segmentsLength;
            }
            
            float sampleSum = 0.0;
            for (NSUInteger frame = 0; frame < endFrameCount; frame++)
            {
                sampleSum += pow(_currentRecording.floatChannelData[0][segmentStartFrame + frame], 2);
            }
            float sampleRMS = sqrt(sampleSum / endFrameCount);
            if (sampleRMS >= minimumRMS)
            {
                if (!inSpeech)
                {
                    inSpeech = YES;
                    AVAudioFrameCount startFrame;
                    if (((double) segmentStartFrame) - _currentRecording.format.sampleRate < 0)
                    {
                        startFrame = 0;
                    }
                    else
                    {
                        startFrame = segmentStartFrame - _currentRecording.format.sampleRate;
                    }
                    startSpeechTime = segmentStartFrame / _currentRecording.format.sampleRate;
                }
            }
            else if (inSpeech)
            {
                inSpeech = NO;
                AVAudioFrameCount endFrame = segmentStartFrame + _currentRecording.format.sampleRate;
                if (endFrame > _currentRecording.frameLength)
                {
                    endFrame = _currentRecording.frameLength;
                }
                endSpeechTime = endFrame / _currentRecording.format.sampleRate;
                [segments addObject:@{
                    @"start": @(startSpeechTime),
                    @"end": @(endSpeechTime)
                }];
            }
        }
    }
    ATSpeechRecording *speechRecording = [[ATSpeechRecording alloc] initWithSpeechMarkers:segments
                                                                              audioBuffer:_currentRecording];
    _isProcessing = NO;
    [self.delegate speechRecognizer:self didFinishRecognizingSpeech:speechRecording];
}

- (void)audioRecorder:(ATAudioRecorder *)recorder didCaptureBuffer:(AVAudioPCMBuffer *)buffer atTime:(AVAudioTime *)time
{
    if (!self.isRecording)
    {
        return;
    }
    
    if (_isRecording && _acceptingBuffers)
    {
        _currentRecordingTime += buffer.frameLength / buffer.format.sampleRate;
        [_currentRequest appendAudioPCMBuffer:buffer];
        if (_currentRecordingTime >= 40)
        {
            [_currentTask finish];
            _acceptingBuffers = NO;
        }
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

- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task
{
    /*_isReady = YES;
    if (_recordingSemaphore != nil)
    {
        dispatch_semaphore_signal(_recordingSemaphore);
    }*/
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully
{
    /*NSLog(@"Finished!");
    if (!successfully)
    {
        _isReady = YES;
        if (_recordingSemaphore != nil)
        {
            dispatch_semaphore_signal(_recordingSemaphore);
        }
    }*/
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult
{
    /*_isReady = YES;
    _currentResult = recognitionResult;
    if (_recordingSemaphore != nil)
    {
        dispatch_semaphore_signal(_recordingSemaphore);
    }*/
}

@end

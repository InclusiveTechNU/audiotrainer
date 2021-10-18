//
//  ATAudioRecorder.m
//  ATAudioRecorder
//
//  Created by Tommy McHugh on 10/15/21.
//

#import "ATAudioRecorder.h"
#import "AVAudioPCMBuffer+Append.h"

static const int kATAudioRecorderBus = 0;
static const int kATAudioRecorderBufferSize = 1024;

@implementation ATAudioRecorder

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _engine = [[AVAudioEngine alloc] init];
        _isRecording = NO;
    }
    return self;
}

- (void)dealloc
{
    if (self.isRecording)
    {
        [self stopRecordingWithCompletionHandler:nil];
    }
}

+ (BOOL)hasPermission
{
    return ATAudioRecorder.permissionStatus == kATAudioRecorderPermissionAuthorized;
}

+ (ATAudioRecorderPermissionStatus)permissionStatus
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusAuthorized)
    {
        return kATAudioRecorderPermissionAuthorized;
    }
    else if (status == AVAuthorizationStatusNotDetermined)
    {
        return kATAudioRecorderPermissionUndetermined;
    }
    return kATAudioRecorderPermissionDenied;
}

+ (void)requestPermissionWithCompletionHandler:(void (^)(ATAudioRecorderPermissionStatus status))handler
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        ATAudioRecorderPermissionStatus status;
        if (granted)
        {
            status = kATAudioRecorderPermissionAuthorized;
        }
        else
        {
            status = kATAudioRecorderPermissionDenied;
        }
        handler(status);
    }];
}

- (BOOL)startRecording
{
    if (!ATAudioRecorder.hasPermission)
    {
        // TODO: Create NSError and pass to delegate
        return NO;
    }

    AVAudioInputNode * _Nullable inputNode = _engine.inputNode;
    if (inputNode == nil)
    {
        return NO;
    }
    [inputNode installTapOnBus:kATAudioRecorderBus
                    bufferSize:kATAudioRecorderBufferSize
                        format:[inputNode outputFormatForBus:kATAudioRecorderBus]
                         block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self->_currentRecording addObject:buffer];
        [self.delegate audioRecorder:self didCaptureBuffer:buffer atTime:when];
    }];
    _currentRecording = [[NSMutableArray alloc] init];
    NSError *recordingError = nil;
    [_engine startAndReturnError:&recordingError];
    if (recordingError != nil)
    {
        _currentRecording = nil;
        [self.delegate audioRecorder:self didFailToRecordWithError:recordingError];
        return NO;
    }

    _isRecording = YES;
    return YES;
}

- (void)stopRecordingWithCompletionHandler:(nullable void (^)(AVAudioPCMBuffer * _Nullable))handler
{
    if (!self.isRecording)
    {
        if (handler != nil)
        {
            handler(nil);
        }
        return;
    }

    [_engine stop];

    AVAudioPCMBuffer * _Nullable outputBuffer = [AVAudioPCMBuffer combineBuffers:_currentRecording];
    _isRecording = NO;
    if (handler != nil)
    {
        handler(outputBuffer);
    }
    _currentRecording = nil;
}

@end

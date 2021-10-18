//
//  ATSpeechRecognizer.h
//  ATSpeechRecognizer
//
//  Created by Tommy McHugh on 10/15/21.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>
#import "ATAudioRecorder.h"
#import "ATSpeechRecognizerDelegate.h"
#import "ATSpeechRecording.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    kATSpeechRecognizerPermissionAuthorized,
    kATSpeechRecognizerPermissionUndetermined,
    kATSpeechRecognizerPermissionDenied
} ATSpeechRecognizerPermissionStatus;

@interface ATSpeechRecognizer : NSObject <ATAudioRecorderDelegate, SFSpeechRecognitionTaskDelegate> {
    SFSpeechRecognizer *_recognizer;
    ATAudioRecorder *_audioRecorder;

    SFSpeechAudioBufferRecognitionRequest * _Nullable _currentRequest;
    SFSpeechRecognitionTask * _Nullable _currentTask;
    SFSpeechRecognitionResult * _Nullable _currentResult;
    AVAudioPCMBuffer * _Nullable _currentRecording;
}

@property (nonatomic, weak, nullable) id<ATSpeechRecognizerDelegate> delegate;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, assign) BOOL isRecording;

+ (BOOL)hasPermission;
+ (ATSpeechRecognizerPermissionStatus)permissionStatus;
+ (void)requestPermissionWithCompletionHandler:(void (^)(ATSpeechRecognizerPermissionStatus status))handler;

- (BOOL)startRecording;
- (void)stopRecording;

@end

NS_ASSUME_NONNULL_END

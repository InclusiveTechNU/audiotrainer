//
//  ATAudioRecorder.h
//  ATAudioRecorder
//
//  Created by Tommy McHugh on 10/15/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ATAudioRecorderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    kATAudioRecorderPermissionAuthorized,
    kATAudioRecorderPermissionUndetermined,
    kATAudioRecorderPermissionDenied
} ATAudioRecorderPermissionStatus;

@interface ATAudioRecorder : NSObject {
    AVAudioEngine *_engine;
    NSMutableArray<AVAudioPCMBuffer *> * _Nullable _currentRecording;
}

@property (nonatomic, weak, nullable) id<ATAudioRecorderDelegate> delegate;
@property (nonatomic, assign) BOOL isRecording;

+ (BOOL)hasPermission;
+ (ATAudioRecorderPermissionStatus)permissionStatus;
+ (void)requestPermissionWithCompletionHandler:(void (^)(ATAudioRecorderPermissionStatus status))handler;

- (BOOL)startRecording;

// TODO: Add NSError
- (void)stopRecordingWithCompletionHandler:(nullable void (^)(AVAudioPCMBuffer* _Nullable recording))handler;

@end

NS_ASSUME_NONNULL_END

//
//  ATAudioRecorderDelegate.h
//  ATAudioRecorderDelegate
//
//  Created by Tommy McHugh on 10/15/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ATAudioRecorder;

@protocol ATAudioRecorderDelegate <NSObject>

@optional

- (void)audioRecorder:(ATAudioRecorder *)recorder didCaptureBuffer:(AVAudioPCMBuffer *)buffer atTime:(AVAudioTime *)time;
- (void)audioRecorder:(ATAudioRecorder *)recorder didFailToRecordWithError:(NSError *)error;


@end

NS_ASSUME_NONNULL_END

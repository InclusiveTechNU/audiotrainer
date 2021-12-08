//
//  ATApplicationRecorder.h
//  ATApplicationRecorder
//
//  Created by Tommy McHugh on 9/28/21.
//

#import <Foundation/Foundation.h>
#import <AudioTrainerSupport/AudioTrainerSupport.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ATApplicationRecorder

- (NSString *)applicationName;
- (BOOL)isRecording;
- (void)startRecording;
- (void)stopRecording:(void (^)(ATRecording * _Nullable))handler;

@optional

- (NSString *)applicationIdentifier;

@end
NS_ASSUME_NONNULL_END

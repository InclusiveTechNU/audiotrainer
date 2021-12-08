//
//  ATRecording.h
//  ATRecording
//
//  Created by Tommy McHugh on 9/28/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>
#import <AudioTrainerSupport/ATApplicationTimeline.h>
#import <AudioTrainerSupport/ATSpeechRecording.h>
#import <AudioTrainerSupport/ATRecordingSection.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATRecording : NSObject <NSSecureCoding>

@property (nonatomic, strong, readonly) AVAudioPCMBuffer *audioBuffer;
@property (nonatomic, strong, readonly) NSArray<ATRecordingSection *> *sections;

+ (instancetype)recordingWithTimeline:(ATApplicationTimeline *)timeline
                            voiceover:(ATSpeechRecording *)recording;

- (void)exportRecordingWithName:(NSString *)name window:(NSWindow *)window;
- (void)exportRecordingToPath:(NSURL *)url;
- (void)replaceAudioBuffer:(AVAudioPCMBuffer *)audioBuffer;
- (void)updateSectionsWithBreakpoints:(NSArray<NSArray<NSNumber *> *> *)breakpoints;
- (void)updateSectionsBreakpointsWithBreakpoints:(NSArray<NSArray<NSNumber *> *> *)breakpoints;

@end

NS_ASSUME_NONNULL_END

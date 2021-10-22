//
//  ATRecording.h
//  ATRecording
//
//  Created by Tommy McHugh on 9/28/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>
#import "ATApplicationTimeline.h"
#import "ATSpeechRecording.h"
#import "ATRecordingSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATRecording : NSObject <NSSecureCoding>

@property (nonatomic, strong, readonly) AVAudioPCMBuffer *audioBuffer;
@property (nonatomic, strong, readonly) NSArray<ATRecordingSection *> *sections;

+ (instancetype)recordingWithTimeline:(ATApplicationTimeline *)timeline
                            voiceover:(ATSpeechRecording *)recording;

- (void)exportRecordingWithName:(NSString *)name window:(NSWindow *)window;

@end

NS_ASSUME_NONNULL_END

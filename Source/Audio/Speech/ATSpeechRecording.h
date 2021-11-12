//
//  ATSpeechRecording.h
//  ATSpeechRecording
//
//  Created by Tommy McHugh on 10/15/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>
#import "ATSpeechBreak.h"
#import "ATSpeechRecognitionResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATSpeechRecording : NSObject

@property (nonatomic, strong, readonly) NSString *formattedSpeech;
@property (nonatomic, strong, readonly) NSArray<ATSpeechBreak *> *breaks;
@property (nonatomic, strong, readonly) AVAudioPCMBuffer *audio;

- (instancetype)initWithSpeechMarkers:(NSArray<NSDictionary *> *)result audioBuffer:(AVAudioPCMBuffer *)buffer;
- (instancetype)initWithSpeechResults:(NSArray<ATSpeechRecognitionResult *> *)results audioBuffer:(AVAudioPCMBuffer *)buffer;
- (instancetype)initWithSpeechResult:(SFSpeechRecognitionResult *)result audioBuffer:(AVAudioPCMBuffer *)buffer;

@end

NS_ASSUME_NONNULL_END

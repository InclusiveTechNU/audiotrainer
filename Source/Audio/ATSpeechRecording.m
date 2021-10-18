//
//  ATSpeechRecording.m
//  ATSpeechRecording
//
//  Created by Tommy McHugh on 10/15/21.
//

#import "ATSpeechRecording.h"

@implementation ATSpeechRecording

- (instancetype)initWithSpeechResult:(SFSpeechRecognitionResult *)result audioBuffer:(AVAudioPCMBuffer *)buffer
{
    self = [super init];
    if (self != nil)
    {
        _audio = buffer;
        _formattedSpeech = result.bestTranscription.formattedString;
        _breaks = [ATSpeechBreak breaksFromSpeechResult:result];
    }
    return self;
}

@end

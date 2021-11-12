//
//  ATSpeechRecording.m
//  ATSpeechRecording
//
//  Created by Tommy McHugh on 10/15/21.
//

#import "ATSpeechRecording.h"

@implementation ATSpeechRecording

- (instancetype)initWithSpeechResults:(NSArray<ATSpeechRecognitionResult *> *)results audioBuffer:(AVAudioPCMBuffer *)buffer
{
    self = [super init];
    if (self != nil)
    {
        NSMutableArray *strings = [[NSMutableArray alloc] initWithCapacity:results.count];
        for (ATSpeechRecognitionResult *result in results)
        {
            [strings addObject:result.result.bestTranscription.formattedString];
        }
        _audio = buffer;
        _formattedSpeech = [strings componentsJoinedByString:@" "];
        _breaks = [ATSpeechBreak breaksFromSpeechResults:results];
    }
    return self;
}

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

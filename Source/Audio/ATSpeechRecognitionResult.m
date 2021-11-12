//
//  ATSpeechRecognitionResult.m
//  Audio Trainer
//
//  Created by Tommy McHugh on 11/11/21.
//

#import "ATSpeechRecognitionResult.h"

@implementation ATSpeechRecognitionResult

- (instancetype)initWithResult:(SFSpeechRecognitionResult *)result length:(NSTimeInterval)length
{
    self = [super init];
    if (self != nil)
    {
        _result = result;
        _length = length;
    }
    return self;
}

@end

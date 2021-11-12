//
//  ATAudioThresholdRecognizer.m
//  Audio Trainer
//
//  Created by Tommy McHugh on 11/11/21.
//

#import "ATAudioThresholdRecognizer.h"

@implementation ATAudioThresholdRecognizer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _threshold = 0.0;
    }
    return self;
}

@end

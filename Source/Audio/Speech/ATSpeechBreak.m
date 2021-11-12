//
//  ATSpeechBreak.m
//  ATSpeechBreak
//
//  Created by Tommy McHugh on 10/15/21.
//

#import "ATSpeechBreak.h"

static const NSTimeInterval kATSpeechBreakMinimumBreakTime = 2.0;

@implementation ATSpeechBreak

+ (NSArray<ATSpeechBreak *> *)breaksFromSpeechMarkers:(NSArray<NSDictionary *> *)result
{
    NSMutableArray<ATSpeechBreak *> *breaks = [[NSMutableArray alloc] init];
    NSTimeInterval lastEndTime = -1.0;
    for (NSDictionary *segment in result)
    {
        NSNumber *startNum = segment[@"start"];
        NSTimeInterval startTime = startNum.doubleValue;
        if (lastEndTime != -1.0 && (startTime - lastEndTime) >= kATSpeechBreakMinimumBreakTime)
        {
            [breaks addObject:[[ATSpeechBreak alloc] initWithStartTime:lastEndTime
                                                               endTime:startTime]];
        }
        NSNumber *endNum = segment[@"end"];
        lastEndTime = endNum.doubleValue;
    }
    return breaks;
}

+ (NSArray<ATSpeechBreak *> *)breaksFromSpeechResults:(NSArray<ATSpeechRecognitionResult *> *)results
{
    NSMutableArray<ATSpeechBreak *> *breaks = [[NSMutableArray alloc] init];
    NSTimeInterval lastEndTime = -1.0;
    NSTimeInterval bufferStartTime = 0.0;
    for (ATSpeechRecognitionResult *result in results)
    {
        for (SFTranscriptionSegment *segment in result.result.bestTranscription.segments)
        {
            NSTimeInterval startTime = bufferStartTime + segment.timestamp;
            if (lastEndTime != -1.0 && (startTime - lastEndTime) >= kATSpeechBreakMinimumBreakTime)
            {
                [breaks addObject:[[ATSpeechBreak alloc] initWithStartTime:lastEndTime
                                                                   endTime:startTime]];
            }
            lastEndTime = startTime + segment.duration;
        }
        bufferStartTime += result.length;
    }
    return breaks;
}

+ (NSArray<ATSpeechBreak *> *)breaksFromSpeechResult:(SFSpeechRecognitionResult *)result
{
    NSMutableArray<ATSpeechBreak *> *breaks = [[NSMutableArray alloc] init];
    NSTimeInterval lastEndTime = -1.0;
    for (SFTranscriptionSegment *segment in result.bestTranscription.segments)
    {
        NSTimeInterval startTime = segment.timestamp;
        if (lastEndTime != -1.0 && (startTime - lastEndTime) >= kATSpeechBreakMinimumBreakTime)
        {
            [breaks addObject:[[ATSpeechBreak alloc] initWithStartTime:lastEndTime
                                                               endTime:startTime]];
        }
        lastEndTime = startTime + segment.duration;
    }
    return breaks;
}

- (instancetype) initWithStartTime:(double)startTime endTime:(double)endTime
{
    self = [super init];
    if (self != nil)
    {
        _startTime = startTime;
        _endTime = endTime;
    }
    return self;
}

@end

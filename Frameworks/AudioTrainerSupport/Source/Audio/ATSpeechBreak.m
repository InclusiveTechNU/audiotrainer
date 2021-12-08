//
//  ATSpeechBreak.m
//  ATSpeechBreak
//
//  Created by Tommy McHugh on 10/15/21.
//

#import "ATSpeechBreak.h"

static const NSTimeInterval kATSpeechBreakMinimumBreakTime = 1.0;

@implementation ATSpeechBreak

+ (NSArray<ATSpeechBreak *> *)breaksFromSoundAnalysis:(NSArray<NSDictionary *> *)result
{
    NSMutableArray<ATSpeechBreak *> *breaks = [[NSMutableArray alloc] init];
    BOOL hasSpoken = NO;
    BOOL inBreak = NO;
    NSTimeInterval startTime = 0.0;
    for (NSDictionary *segment in result)
    {
        BOOL isSpeaking = ((NSNumber *) segment[@"speaking"]).boolValue;
        if (!hasSpoken && isSpeaking)
        {
            hasSpoken = YES;
            continue;
        }
        
        if (hasSpoken && !isSpeaking && !inBreak)
        {
            inBreak = YES;
            startTime = ((NSNumber *) segment[@"startTime"]).doubleValue + 1.0;
        }
        else if (inBreak && isSpeaking)
        {
            inBreak = NO;
            NSTimeInterval segmentStartTime = ((NSNumber *) segment[@"startTime"]).doubleValue;
            NSTimeInterval segmentDuration = ((NSNumber *) segment[@"duration"]).doubleValue;
            [breaks addObject:[[ATSpeechBreak alloc] initWithStartTime:startTime
                                                               endTime:segmentStartTime + segmentDuration - 1.0]];
        }
    }
    return breaks;
}

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

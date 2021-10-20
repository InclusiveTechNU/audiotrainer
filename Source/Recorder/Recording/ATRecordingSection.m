//
//  ATRecordingSection.m
//  ATRecordingSection
//
//  Created by Tommy McHugh on 10/19/21.
//

#import "ATRecordingSection.h"

@implementation ATRecordingSection

- (instancetype)initWithPauseTime:(double)pauseTime
                       resumeTime:(double)resumeTime
                           events:(NSArray<ATApplicationEvent *> *)events
{
    self = [super init];
    if (self != nil)
    {
        _pauseTime = pauseTime;
        _resumeTime = resumeTime;
        _events = events;
    }
    return self;
}

@end

//
//  ATRecordingSection.m
//  ATRecordingSection
//
//  Created by Tommy McHugh on 10/19/21.
//

#import "ATRecordingSection.h"

@implementation ATRecordingSection

+ (BOOL)supportsSecureCoding
{
    return YES;
}

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

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeDouble:self.pauseTime forKey:@"pauseTime"];
    [coder encodeDouble:self.resumeTime forKey:@"resumeTime"];
    [coder encodeObject:self.events forKey:@"events"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self != nil)
    {
        _pauseTime = [coder decodeDoubleForKey:@"pauseTime"];
        _resumeTime = [coder decodeDoubleForKey:@"resumeTime"];
        _events = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [ATApplicationEvent class], nil]
                                        forKey:@"events"];
    }
    return self;
}

- (void)updatePauseTime:(double)pauseTime
{
    _pauseTime = pauseTime;
}

- (void)updateResumeTime:(double)resumeTime
{
    _resumeTime = resumeTime;
}

@end

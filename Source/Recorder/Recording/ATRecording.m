//
//  ATRecording.m
//  ATRecording
//
//  Created by Tommy McHugh on 9/28/21.
//

#import "ATRecording.h"

@implementation ATRecording

+ (instancetype)recordingWithTimeline:(ATApplicationTimeline *)timeline
                            voiceover:(ATSpeechRecording *)recording
{
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    if (recording.breaks.count == 0)
    {
        ATRecordingSection *section = [[ATRecordingSection alloc] initWithPauseTime:-1.0
                                                                         resumeTime:-1.0
                                                                             events:[NSArray arrayWithArray:timeline.events]];
        [sections addObject:section];
    }
    else
    {
        NSUInteger lastStoppedIndex = 0;
        double lastEndTime = 0.0;
        for (ATSpeechBreak *speechBreak in recording.breaks)
        {
            double newEndTime = speechBreak.endTime;
            NSMutableArray *events = [[NSMutableArray alloc] init];
            for (NSUInteger i = lastStoppedIndex; i < timeline.events.count; i++)
            {
                ATApplicationEvent *event = [timeline.events objectAtIndex:i];
                NSLog(@"Event: %f, %f, %f", event.time, lastEndTime, newEndTime);
                if (event.time >= lastEndTime && event.time <= newEndTime)
                {
                    [events addObject:event];
                }
                else
                {
                    lastStoppedIndex = i;
                    break;
                }
            }
            ATRecordingSection *section = [[ATRecordingSection alloc] initWithPauseTime:speechBreak.startTime
                                                                             resumeTime:speechBreak.endTime
                                                                                 events:events];
            if (section.events.count > 0)
            {
                [sections addObject:section];
            }
            lastEndTime = newEndTime;
        }
    }
    for (ATRecordingSection *section in sections)
    {
        NSLog(@"\nSection: pause at - %f, resuming at - %f", section.pauseTime, section.resumeTime);
        NSLog(@"%@", section.events);
        NSLog(@"End Section\n");
    }
    return [[ATRecording alloc] initWithAudio:recording.audio sections:sections];
}

- (instancetype)initWithAudio:(AVAudioPCMBuffer *)audioBuffer sections:(NSArray<ATRecordingSection *> *)sections
{
    self = [super init];
    if (self != nil)
    {
        _audioBuffer = audioBuffer;
        _sections = sections;
    }
    return self;
}

- (void)saveToPath:(NSURL *)url
{
    
}

@end

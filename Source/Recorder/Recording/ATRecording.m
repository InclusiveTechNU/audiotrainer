//
//  ATRecording.m
//  ATRecording
//
//  Created by Tommy McHugh on 9/28/21.
//

#import "ATRecording.h"
#import "AVAudioPCMBuffer+Data.h"

@implementation ATRecording

+ (BOOL)supportsSecureCoding
{
    return YES;
}

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

- (NSData * _Nullable)data
{
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:NO error:&error];
    return data;
}

- (void)exportRecordingWithName:(NSString *)name window:(NSWindow *)window
{
    // TODO: Manage alert for failed to save
    NSData *recordingData = self.data;
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.nameFieldStringValue = [name stringByAppendingPathExtension:@"tutorial"];
    [savePanel beginSheetModalForWindow:window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK && savePanel.URL != nil && recordingData != nil)
        {
            NSURL *fileURL = savePanel.URL;
            [recordingData writeToURL:fileURL atomically:NO];
        }
    }];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.sections forKey:@"sections"];
    [coder encodeObject:self.audioBuffer.data forKey:@"audioBuffer"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self != nil)
    {
        _sections = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [ATRecordingSection class], nil]
                                          forKey:@"sections"];
        NSData *audioData = [coder decodeObjectOfClass:[NSData class] forKey:@"audioBuffer"];
        _audioBuffer = [AVAudioPCMBuffer fromData:audioData];
    }
    return self;
}

@end

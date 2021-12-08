//
//  ATApplicationRecorderBase.m
//  ATApplicationRecorderBase
//
//  Created by Tommy McHugh on 9/28/21.
//

#import "ATApplicationRecorderBase.h"
#import "ATUnimplementedError.h"
#import "ATKeyboardRecordingMarker.h"
#import "ATVoiceOverRecordingMarker.h"

@implementation ATApplicationRecorderBase

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _scraper = [ATApplicationScraper scraperForApplication:self.applicationName];
        [_scraper blockLabel:@"Playhead thumb"];
        [_scraper enableTopLevelGroup:@"Control Bar"];
        [_scraper enableTopLevelGroup:@"Tracks"];
        [_scraper enableTopLevelGroup:@"Smart Controls"];

        _recognizer = [[ATSoundAnalyzer alloc] init];
        _recognizer.delegate = self;
    }
    return self;
}

- (nonnull NSString *)applicationName
{
    @throw [ATUnimplementedError errorWithSelector:_cmd sourceClass:[self class]];
}

- (BOOL)isRecording
{
    return _recording;
}

- (void)startRecording
{
    if (self.isRecording)
    {
        return;
    }
    
    [_recognizer startRecording];
    _recording = YES;
    [_scraper scrapeWithHandler:^(NSError * _Nullable error, ATApplicationTimeline * _Nullable timeline) {
        // TODO: Check event types
        // TODO: Figure out where to release these objects
        ATVoiceOverRecordingMarker *voiceoverMarker = [ATVoiceOverRecordingMarker markerWithEventType:kATVoiceOverKeyDownEvent];
        ATKeyboardRecordingMarker *keyboardMarker = [ATKeyboardRecordingMarker globalMarkerWithEventType:kATKeyboardKeyDownEvent];
        voiceoverMarker.delegate = self;
        keyboardMarker.delegate = self;
        [_markers addObject:voiceoverMarker];
        [_markers addObject:keyboardMarker];
    }];
}

- (void)stopRecording:(nonnull void (^)(ATRecording * _Nullable))handler
{
    if (!self.isRecording)
    {
        handler(nil);
        return;
    }

    [_scraper updateWindowsWithHandler:^(NSError * _Nullable error, ATApplicationTimeline * _Nullable timeline) {
        self->_recording = NO;
        for (id <ATRecordingMarker> marker in self->_markers)
        {
            [marker disable];
        }
        
        // Wait until the speech recognizer is available
        self->_recordingSemaphore = dispatch_semaphore_create(0);
        [self->_recognizer stopRecording];
        dispatch_semaphore_wait(self->_recordingSemaphore, DISPATCH_TIME_FOREVER);
        self->_recordingSemaphore = nil;
        handler([ATRecording recordingWithTimeline:timeline voiceover:self->_currentRecording]);
    }];
}

- (void)speechRecognizer:(ATSpeechRecognizer *)recognizer didFinishRecognizingSpeech:(ATSpeechRecording *)recording
{
    _currentRecording = recording;
    if (_recordingSemaphore != nil)
    {
        dispatch_semaphore_signal(_recordingSemaphore);
    }
}

- (void)marker:(nonnull id<ATRecordingMarker>)marker didFireWithUserInfo:(nonnull ATRecordingMarkerUserInfo)userInfo {
    if (!self.isRecording)
    {
        return;
    }
    [_scraper updateWindowsWithHandler:nil];
}

@end

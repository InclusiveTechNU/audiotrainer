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
        _recognizer = [[ATSpeechRecognizer alloc] init];
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

    [ATAudioRecorder requestPermissionWithCompletionHandler:^(ATAudioRecorderPermissionStatus status) {
        [ATSpeechRecognizer requestPermissionWithCompletionHandler:^(ATSpeechRecognizerPermissionStatus status) {
            [_recognizer startRecording];
        }];
    }];
    
    _recording = YES;
    [_scraper scrapeWithHandler:^(NSError * _Nullable error,
                                  ATApplicationTimeline * _Nullable timeline) {
        __weak ATApplicationRecorderBase *weakSelf = self;
        ATApplicationRecorderBase *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            // TODO: Check event types
            // TODO: Figure out where to release these objects
            ATVoiceOverRecordingMarker *voiceoverMarker = [ATVoiceOverRecordingMarker markerWithEventType:kATVoiceOverKeyDownEvent];
            ATKeyboardRecordingMarker *keyboardMarker = [ATKeyboardRecordingMarker globalMarkerWithEventType:kATKeyboardKeyDownEvent];
            voiceoverMarker.delegate = strongSelf;
            keyboardMarker.delegate = strongSelf;
            [strongSelf->_markers addObject:voiceoverMarker];
            [strongSelf->_markers addObject:keyboardMarker];
        }
    }];
}

- (void)stopRecording:(nonnull void (^)(ATRecording * _Nullable))handler
{
    if (!self.isRecording)
    {
        handler(nil);
        return;
    }

    [_recognizer stopRecording];

    [_scraper updateWithHandler:^(NSError * _Nullable error, ATApplicationTimeline * _Nullable timeline) {
        self->_recording = NO;
        for (id <ATRecordingMarker> marker in self->_markers)
        {
            [marker disable];
        }
        
        //ATRecording *recording = [ATRecording recordingWithTimeline:timeline instructions:nil];
        handler(nil);
    }];
}

- (void)marker:(nonnull id<ATRecordingMarker>)marker didFireWithUserInfo:(nonnull ATRecordingMarkerUserInfo)userInfo {
    if (!self.isRecording)
    {
        return;
    }
    [_scraper updateWindowsWithHandler:nil];
}

@end

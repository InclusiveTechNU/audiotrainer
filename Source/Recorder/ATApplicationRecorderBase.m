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
    _recording = YES;
    [_scraper scrapeWithHandler:^(NSError * _Nullable error,
                                  ATApplicationTimeline * _Nullable __weak timeline) {
        __weak ATApplicationRecorderBase *weakSelf = self;
        ATApplicationRecorderBase *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            // TODO: Check event types
            ATVoiceOverRecordingMarker *voiceoverMarker = [ATVoiceOverRecordingMarker markerWithEventType:kATVoiceOverKeyDownEvent];
            ATKeyboardRecordingMarker *keyboardMarker = [ATKeyboardRecordingMarker globalMarkerWithEventType:kATKeyboardKeyDownEvent];
            voiceoverMarker.delegate = strongSelf;
            keyboardMarker.delegate = strongSelf;
            [strongSelf->_markers addObject:voiceoverMarker];
            [strongSelf->_markers addObject:keyboardMarker];
        }
    }];
    // Capture the entire accessibility tree
    // Register focus, value, destruction based observers
    // Register keyboard calls to update
    
}

- (void)stopRecording:(nonnull void (^)(ATRecording * _Nullable))handler
{
    if (!self.isRecording)
    {
        handler(nil);
        return;
    }

    _recording = NO;
    handler(nil);
}

- (void)marker:(nonnull id<ATRecordingMarker>)marker didFireWithUserInfo:(nonnull ATRecordingMarkerUserInfo)userInfo {
    if (!self.isRecording)
    {
        return;
    }
    NSLog(@"Fire");
    // TODO: Determine whether mainWindow is fine.
    [_scraper updateWithHandler:nil];
}

@end

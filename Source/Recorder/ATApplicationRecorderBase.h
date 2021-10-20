//
//  ATApplicationRecorderBase.h
//  ATApplicationRecorderBase
//
//  Created by Tommy McHugh on 9/28/21.
//

#import <Foundation/Foundation.h>
#import "ATApplicationRecorder.h"
#import "ATApplicationScraper.h"
#import "ATRecordingMarker.h"
#import "ATRecordingMarkerDelegate.h"
#import "ATSpeechRecognizer.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATApplicationRecorderBase : NSObject <ATApplicationRecorder, ATRecordingMarkerDelegate, ATSpeechRecognizerDelegate>
{
    NSMutableArray<id<ATRecordingMarker>> *_markers;
    ATApplicationScraper *_scraper;
    ATSpeechRecognizer *_recognizer;
    BOOL _recording;
    ATSpeechRecording * _Nullable _currentRecording;
    dispatch_semaphore_t _Nullable _recordingSemaphore;
}

@end

NS_ASSUME_NONNULL_END

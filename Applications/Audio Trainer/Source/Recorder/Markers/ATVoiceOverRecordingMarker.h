//
//  ATVoiceOverRecordingMarker.h
//  ATVoiceOverRecordingMarker
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>
#import "ATRecordingMarker.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    kATVoiceOverKeyDownEvent,
    kATVoiceOverKeyUpEvent,
    kATVoiceOverAllKeyEvents
} ATVoiceOverEventType;

@interface ATVoiceOverRecordingMarker : NSObject <ATRecordingMarker> {
    CFMachPortRef _eventListenerPort;
}

+ (instancetype)markerWithEventType:(ATVoiceOverEventType)type;

@end

NS_ASSUME_NONNULL_END

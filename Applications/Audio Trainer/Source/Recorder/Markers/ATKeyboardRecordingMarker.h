//
//  ATKeyboardRecordingMarker.h
//  ATKeyboardRecordingMarker
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>
#import <AudioTrainerSupport/AudioTrainerSupport.h>
#import "ATRecordingMarker.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    kATKeyboardKeyDownEvent,
    kATKeyboardKeyUpEvent,
    kATKeyboardAllKeyEvents
} ATKeyboardEventType;

@interface ATKeyboardRecordingMarker : NSObject <ATRecordingMarker> {
    CFMachPortRef _eventListenerPort;
}

+ (instancetype)globalMarkerWithEventType:(ATKeyboardEventType)type;
+ (instancetype)markerForApplication:(ATApplicationElement *)application withEventType:(ATKeyboardEventType)type;

@end

NS_ASSUME_NONNULL_END

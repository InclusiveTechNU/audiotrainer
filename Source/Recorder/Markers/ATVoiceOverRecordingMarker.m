//
//  ATVoiceOverRecordingMarker.m
//  ATVoiceOverRecordingMarker
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <CoreGraphics/CoreGraphics.h>
#import "ATVoiceOverRecordingMarker.h"

static CGEventRef ATVoiceOverRecordingMarkerEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    CGEventFlags flags = CGEventGetFlags(event);
    CGEventFlags modifierFlags = kCGEventFlagMaskControl | kCGEventFlagMaskAlternate;
    // TODO: Check for caps lock or ctrl + option modifier not going down to application layer.
    BOOL didPressModifier = (flags & modifierFlags) == modifierFlags;
    if (didPressModifier)
    {
        // TODO: Check for a better way that event follows responder chain to application
        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
            // TODO: Fill this in with keyboard info
            ATVoiceOverRecordingMarker *marker = (__bridge ATVoiceOverRecordingMarker *) refcon;
            [marker.delegate marker:marker didFireWithUserInfo:@{}];
        }];
    }
    return event;
}


@implementation ATVoiceOverRecordingMarker

@synthesize delegate = _delegate;

+ (instancetype)markerWithEventType:(ATVoiceOverEventType)type
{
    CGEventMask eventMask = [ATVoiceOverRecordingMarker maskForEventType:type];
    return [[ATVoiceOverRecordingMarker alloc] initWithEventMask:eventMask];
}

+ (CGEventMask)maskForEventType:(ATVoiceOverEventType)type
{
    if (type == kATVoiceOverKeyUpEvent)
    {
        return CGEventMaskBit(kCGEventKeyUp);
    }
    else if (type == kATVoiceOverKeyDownEvent)
    {
        return CGEventMaskBit(kCGEventKeyDown);
    }
    // type == kATVoiceOverAllKeyEvents
    return CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp);
}

- (instancetype)initWithEventMask:(CGEventMask)mask
{
    self = [super init];
    if (self != nil)
    {
        [self createKeyboardListenerWithEventMask:mask];
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_eventListenerPort);
}

- (void)createKeyboardListenerWithEventMask:(CGEventMask)mask
{
    if (_eventListenerPort != nil)
    {
        CFRelease(_eventListenerPort);
    }

    CGEventTapLocation location = kCGHIDEventTap;
    CGEventTapPlacement placement = kCGHeadInsertEventTap; // TODO: Look into this
    CGEventTapOptions options = kCGEventTapOptionListenOnly;
    CGEventTapCallBack callback = ATVoiceOverRecordingMarkerEventCallback;
    void * _Nullable userInfo = (__bridge_retained void*) self;
    _eventListenerPort = CGEventTapCreate(location, placement, options, mask, callback, userInfo);
    CFRunLoopSourceRef eventListenerLoop = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, _eventListenerPort, 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), eventListenerLoop, kCFRunLoopDefaultMode);
}

- (void)enable
{
    if (self.isEnabled)
    {
        return;
    }
    CGEventTapEnable(_eventListenerPort, true);
}

- (void)disable
{
    if (!self.isEnabled)
    {
        return;
    }
    CGEventTapEnable(_eventListenerPort, false);
}

- (BOOL)isEnabled
{
    return CGEventTapIsEnabled(_eventListenerPort);
}

@end

//
//  ATKeyboardRecordingMarker.m
//  ATKeyboardRecordingMarker
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <CoreGraphics/CoreGraphics.h>
#import "ATKeyboardRecordingMarker.h"

static const pid_t kATGlobalApplicationProcessIdentifier = -1;

static CGEventRef ATKeyboardRecordingMarkerEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    ATKeyboardRecordingMarker *marker = (__bridge ATKeyboardRecordingMarker *) refcon;
    // TODO: Fill this in with keyboard info
    [marker.delegate marker:marker didFireWithUserInfo:@{}];
    return event;
}

@implementation ATKeyboardRecordingMarker

@synthesize delegate = _delegate;

+ (instancetype)globalMarkerWithEventType:(ATKeyboardEventType)type
{
    CGEventMask eventMask = [ATKeyboardRecordingMarker maskForEventType:type];
    return [[ATKeyboardRecordingMarker alloc] initWithProcess:kATGlobalApplicationProcessIdentifier
                                                    eventMask:eventMask];
}

+ (instancetype)markerForApplication:(ATApplicationElement *)application withEventType:(ATKeyboardEventType)type
{
    CGEventMask eventMask = [ATKeyboardRecordingMarker maskForEventType:type];
    pid_t appProcess = application.processIdentifier;
    return [[ATKeyboardRecordingMarker alloc] initWithProcess:appProcess eventMask:eventMask];
}

+ (CGEventMask)maskForEventType:(ATKeyboardEventType)type
{
    if (type == kATKeyboardKeyUpEvent)
    {
        return CGEventMaskBit(kCGEventKeyUp);
    }
    else if (type == kATKeyboardKeyDownEvent)
    {
        return CGEventMaskBit(kCGEventKeyDown);
    }
    // type == kATKeyboardAllKeyEvents
    return CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp);
}

- (instancetype)initWithProcess:(pid_t)process eventMask:(CGEventMask)mask
{
    self = [super init];
    if (self != nil)
    {
        [self createKeyboardListenerWithProcess:process eventMask:mask];
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_eventListenerPort);
}

- (void)createKeyboardListenerWithProcess:(pid_t)process eventMask:(CGEventMask)mask
{
    if (_eventListenerPort != nil)
    {
        CFRelease(_eventListenerPort);
    }
    CGEventTapPlacement placement = kCGHeadInsertEventTap; // TODO: Look into this
    CGEventTapOptions options = kCGEventTapOptionListenOnly;
    CGEventTapCallBack callback = ATKeyboardRecordingMarkerEventCallback;
    void * _Nullable userInfo = (__bridge void*) self;
    if (process == kATGlobalApplicationProcessIdentifier)
    {
        CGEventTapLocation location = kCGAnnotatedSessionEventTap;
        _eventListenerPort = CGEventTapCreate(location, placement, options, mask, callback, userInfo);
    }
    else
    {
        _eventListenerPort = CGEventTapCreateForPid(process, placement, options, mask, callback, userInfo);
    }
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

//
//  ATRecorderViewController.m
//  ATRecorderViewController
//
//  Created by Tommy McHugh on 10/6/21.
//

#import <Carbon/Carbon.h>
#import <AudioTrainerSupport/AudioTrainerSupport.h>
#import "ATRecorderViewController.h"
#import "ATLogicRecorder.h"
#import "ATGarageBandRecorder.h"
#import "ATApplicationRecorderUtilities.h"

static CGEventRef ATVoiceOverRecordingMarkerEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    CGEventFlags flags = CGEventGetFlags(event);
    CGEventFlags modifierFlags = kCGEventFlagMaskControl | kCGEventFlagMaskCommand;
    BOOL didPressModifier = (flags & modifierFlags) == modifierFlags;
    if (didPressModifier)
    {
        CGKeyCode key = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
        if (key == kVK_ANSI_R) {
            ATRecorderViewController *viewController = (__bridge ATRecorderViewController *) refcon;
            [viewController recordButtonOnPress:viewController];
        }
    }
    return event;
}

@interface ATRecorderViewController ()

@end

@implementation ATRecorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    if (self.applicationPickerButton != nil)
    {
        NSArray<id <ATApplicationRecorder>> *recorders = @[[[ATGarageBandRecorder alloc] init], [[ATLogicRecorder alloc] init]];
        [self.applicationPickerButton addRecorders:recorders];
    }
    
    accessibilityPermissionTimer = [ATAccessibilityPermission waitForPermissionWithCompletionHandler:^{
        CGEventTapLocation location = kCGHIDEventTap;
        CGEventTapPlacement placement = kCGHeadInsertEventTap; // TODO: Look into this
        CGEventTapOptions options = kCGEventTapOptionListenOnly;
        CGEventTapCallBack callback = ATVoiceOverRecordingMarkerEventCallback;
        void * _Nullable userInfo = (__bridge_retained void*) self;
        self->_eventListenerPort = CGEventTapCreate(location, placement, options, CGEventMaskBit(kCGEventKeyDown), callback, userInfo);
        CFRunLoopSourceRef eventListenerLoop = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, self->_eventListenerPort, 0);
        CFRunLoopAddSource(CFRunLoopGetMain(), eventListenerLoop, kCFRunLoopDefaultMode);
    }];
}

- (BOOL)isRecording
{
    return _activeRecorder != nil && _activeRecorder.isRecording;
}

- (IBAction)recordButtonOnPress:(id)sender
{
    if (self.isRecording)
    {
        if (_activeRecorder.isRecording)
        {
            [self.recordingButton setTitle:@"Record"];
            self.recordingButton.enabled = NO;
            NSString *soundFilePath = [NSString stringWithFormat:@"%@/state-change_confirm-down.wav", [[NSBundle mainBundle] resourcePath]];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
            [_player play];
            NSAccessibilityPostNotificationWithUserInfo(NSApp.mainWindow,
                                                        NSAccessibilityAnnouncementRequestedNotification,
                                                        @{ NSAccessibilityAnnouncementKey: @"Processing recording",
                                                           NSAccessibilityPriorityKey: @(NSAccessibilityPriorityHigh)
                                                        });
            [_activeRecorder stopRecording:^(ATRecording * _Nullable recording) {
                NSLog(@"Received Recording");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Exporting Recording");
                    [recording exportRecordingWithName:@"Untitled" window:self.view.window];
                    self.recordingButton.enabled = YES;
                });
            }];
        }
    }
    else if (self.applicationPickerButton.selectedRecorder != nil)
    {
        _activeRecorder = self.applicationPickerButton.selectedRecorder;
        if (!_activeRecorder.isRecording)
        {
            [self.recordingButton setTitle:@"Stop Recording"];
            [_activeRecorder startRecording];
            NSString *soundFilePath = [NSString stringWithFormat:@"%@/state-change_confirm-up.wav", [[NSBundle mainBundle] resourcePath]];
            NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
            [_player play];
        }
    }
    else
    {
        // TODO: Add error for no available recordings
    }
}

@end

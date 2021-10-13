//
//  ATRecorderViewController.m
//  ATRecorderViewController
//
//  Created by Tommy McHugh on 10/6/21.
//

#import "ATRecorderViewController.h"
#import "ATLogicRecorder.h"
#import "ATGarageBandRecorder.h"
#import "ATApplicationRecorderUtilities.h"
#import "ATApplicationElement.h"

CGEventRef eventTapFunction(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    NSLog(@"Pressed");
    CGEventFlags flags = CGEventGetFlags(event);
    BOOL didPressVOModifier = (flags & (kCGEventFlagMaskControl | kCGEventFlagMaskAlternate)) == (kCGEventFlagMaskControl | kCGEventFlagMaskAlternate);
    if (didPressVOModifier)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [(__bridge ATApplicationScraper *) refcon updateWithHandler:^(NSError * _Nullable error, ATApplicationTimeline * _Nullable __weak timeline) {
            }];
        }];
    }
    else
    {
        [(__bridge ATApplicationScraper *) refcon updateWithHandler:^(NSError * _Nullable error, ATApplicationTimeline * _Nullable __weak timeline) {
        }];
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
    scraper = [ATApplicationScraper scraperForApplication:@"GarageBand"];
    [scraper blockLabel:@"Apple Loops"];
    [scraper blockLabel:@"Playhead thumb"];
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
            [scraper updateWithHandler:^(NSError * _Nullable error, ATApplicationTimeline * _Nullable __weak timeline) {
                NSLog(@"%@", error);
            }];
            [_activeRecorder stopRecording:^(ATRecording * _Nullable recording) {
                NSLog(@"Finished recording!");
                self->_activeRecorder = nil;
            }];
        }
    }
    else if (self.applicationPickerButton.selectedRecorder != nil)
    {
        CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
        [scraper scrapeWithHandler:^(NSError * _Nullable error, ATApplicationTimeline * _Nullable __weak timeline) {
            NSLog(@"%f", CFAbsoluteTimeGetCurrent() - time);
            CGEventMask keyboardMask = CGEventMaskBit(kCGEventKeyDown);
            CFMachPortRef mMachPortRef =  CGEventTapCreate(kCGAnnotatedSessionEventTap,
                                                           kCGHeadInsertEventTap,
                                                           kCGEventTapOptionListenOnly,
                                                           keyboardMask,
                                                           (CGEventTapCallBack) eventTapFunction,
                                                           (__bridge void * _Nullable)(self->scraper) );
            CFRunLoopSourceRef mKeyboardEventSrc = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mMachPortRef, 0);
            CFRunLoopRef runLoop = CFRunLoopGetMain();
            CFRunLoopAddSource(runLoop,  mKeyboardEventSrc, kCFRunLoopDefaultMode);
            CGEventTapEnable(mMachPortRef, true);
        }];
        _activeRecorder = self.applicationPickerButton.selectedRecorder;
        if (!_activeRecorder.isRecording)
        {
            [_activeRecorder startRecording];
        }
    }
    else
    {
        // TODO: Add error for no available recordings
    }
}

@end

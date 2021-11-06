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
            NSAccessibilityPostNotificationWithUserInfo(NSApp.mainWindow,
                                                        NSAccessibilityAnnouncementRequestedNotification,
                                                        @{ NSAccessibilityAnnouncementKey: @"Processing recording",
                                                           NSAccessibilityPriorityKey: @(NSAccessibilityPriorityHigh)
                                                        });
            [_activeRecorder stopRecording:^(ATRecording * _Nullable recording) {
                self->_activeRecorder = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
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
        }
    }
    else
    {
        // TODO: Add error for no available recordings
    }
}

@end

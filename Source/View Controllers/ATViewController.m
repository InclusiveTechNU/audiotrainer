//
//  ATViewController.m
//  AudioTrainer
//
//  Created by Tommy McHugh on 9/28/21.
//

#import "ATViewController.h"
#import "ATAccessibilityPermission.h"
#import "ATAudioRecorder.h"
#import "ATSpeechRecognizer.h"

@implementation ATViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    accessibilityPermissionTimer = [ATAccessibilityPermission waitForPermissionWithCompletionHandler:^{
        self->accessibilityPermissionTimer = nil;
        NSLog(@"Approved Accessibility");
        [ATAudioRecorder requestPermissionWithCompletionHandler:^(ATAudioRecorderPermissionStatus status) {
            NSLog(@"Approved Audio Recording");
            [ATSpeechRecognizer requestPermissionWithCompletionHandler:^(ATSpeechRecognizerPermissionStatus status) {
                NSLog(@"Approved Speech Recognizer");
            }];
        }];
    }];
}

- (void)dealloc
{
    [accessibilityPermissionTimer invalidate];
}

- (IBAction)exitButtonOnPress:(id)sender {
    [NSApplication.sharedApplication terminate:nil];
}

@end

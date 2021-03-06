//
//  ATRecorderViewController.h
//  ATRecorderViewController
//
//  Created by Tommy McHugh on 10/6/21.
//

#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ATApplicationRecorder.h"
#import "ATApplicationPopUpButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATRecorderViewController : NSViewController {
    __weak id <ATApplicationRecorder> _activeRecorder;
    ATApplicationScraper *scraper;
    CFMachPortRef _eventListenerPort;
    NSTimer * _Nullable accessibilityPermissionTimer;
    AVAudioPlayer * _player;
}

@property (weak, nullable) IBOutlet NSButton *recordingButton;
@property (weak, nullable) IBOutlet ATApplicationPopUpButton *applicationPickerButton;

- (IBAction)recordButtonOnPress:(id)sender;
- (BOOL)isRecording;

@end

NS_ASSUME_NONNULL_END

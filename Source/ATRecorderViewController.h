//
//  ATRecorderViewController.h
//  ATRecorderViewController
//
//  Created by Tommy McHugh on 10/6/21.
//

#import <Cocoa/Cocoa.h>
#import "ATApplicationRecorder.h"
#import "ATApplicationPopUpButton.h"
#import "ATApplicationScraper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATRecorderViewController : NSViewController {
    __weak id <ATApplicationRecorder> _activeRecorder;
    ATApplicationScraper *scraper;
}

@property (weak, nullable) IBOutlet NSButton *recordingButton;
@property (weak, nullable) IBOutlet ATApplicationPopUpButton *applicationPickerButton;

- (BOOL)isRecording;

@end

NS_ASSUME_NONNULL_END

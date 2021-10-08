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
    scraper = [ATApplicationScraper scraperForApplication:@"GarageBand"];
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
            [scraper update];
            [_activeRecorder stopRecording:^(ATRecording * _Nullable recording) {
                NSLog(@"Finished recording!");
                self->_activeRecorder = nil;
            }];
        }
    }
    else if (self.applicationPickerButton.selectedRecorder != nil)
    {
        CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
        [scraper scrapeWithHandler:^{
            NSLog(@"%f", CFAbsoluteTimeGetCurrent() - time);
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

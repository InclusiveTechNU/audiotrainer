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

- (long)scrapeWithElement:(ATElement *)element
{
    NSUInteger count = 0;
    if (element.visibileChildrenCount > 0)
    {
        NSArray *children = element.visibileChildren;
        count += children.count;
        for (ATElement *child in children)
        {
            count += [self scrapeWithElement:child];
        }
    }
    else
    {
        if (element.childrenCount > 500)
        {
            NSArray *children = [element childrenAtIndex:0 maxValues:500];
            count += 500;
            for (ATElement *child in children)
            {
                count += [self scrapeWithElement:child];
            }
        }
        else
        {
            NSArray *children = element.children;
            count += children.count;
            for (ATElement *child in children)
            {
                count += [self scrapeWithElement:child];
            }
        }
    }
    return count;
}

- (IBAction)recordButtonOnPress:(id)sender
{
    ATApplicationElement *garageband = [ATApplicationElement applicationWithName:@"GarageBand"];
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    NSLog(@"%ld, %f", [self scrapeWithElement:garageband.windows[1]], CFAbsoluteTimeGetCurrent() - time);

    if (self.isRecording)
    {
        if (_activeRecorder.isRecording)
        {
            [_activeRecorder stopRecording:^(ATRecording * _Nullable recording) {
                NSLog(@"Finished recording!");
                self->_activeRecorder = nil;
            }];
        }
    }
    else if (self.applicationPickerButton.selectedRecorder != nil)
    {
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

//
//  ATPlayerViewController.m
//  ATPlayerViewController
//
//  Created by Tommy McHugh on 10/6/21.
//

#import <AudioTrainerSupport/AudioTrainerSupport.h>
#import "ATPlayerViewController.h"

@interface ATPlayerViewController ()

@end

@implementation ATPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)filePickerButtonOnPress:(id)sender {
    // TODO: Limit to 1 file count and give error on failed
    // TODO: Move picker into its own class
    NSOpenPanel *openPanel = NSOpenPanel.openPanel;
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK && openPanel.URLs.count == 1)
        {
            // TODO: Move unarchiving into its own class
            NSURL *tutorialPath = [openPanel.URLs objectAtIndex:0];
            NSData *tutorialData = [NSData dataWithContentsOfURL:tutorialPath];
            NSError *error = nil;
            ATRecording *tutorialRecording = [NSKeyedUnarchiver unarchivedObjectOfClass:ATRecording.class
                                                                               fromData:tutorialData
                                                                                  error:&error];
            _player = [[ATApplicationPlayerBase alloc] initWithRecording:tutorialRecording];
            [self playStartingAtIndex:0];
        }
    }];
}

- (void)playStartingAtIndex:(NSUInteger)index
{
    [_player playSectionAtIndex:index timeout:0 completionHandler:^(BOOL completed) {
        if (index < _player.recording.sections.count)
        {
            [self playStartingAtIndex:index+1];
        }
        else
        {
            [_player playEndingWithCompletionHandler:^(BOOL completed) {
            }];
        }
    }];
}

@end

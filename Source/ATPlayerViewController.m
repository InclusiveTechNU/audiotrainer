//
//  ATPlayerViewController.m
//  ATPlayerViewController
//
//  Created by Tommy McHugh on 10/6/21.
//

#import "ATPlayerViewController.h"
#import "ATRecording.h"

@interface ATPlayerViewController ()

@end

@implementation ATPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _engine = [[AVAudioEngine alloc] init];
    _playerNode = [[AVAudioPlayerNode alloc] init];
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
            [_engine attachNode:_playerNode];
            [_engine connect:_playerNode to:_engine.mainMixerNode format:tutorialRecording.audioBuffer.format];
            
            // Play the buffer
            [_playerNode scheduleBuffer:tutorialRecording.audioBuffer completionHandler:nil];
            [_engine startAndReturnError:nil];
            [_playerNode play];
            
            
            _player = [[ATApplicationPlayerBase alloc] initWithRecording:tutorialRecording];
            
            [_player waitForSection:[tutorialRecording.sections objectAtIndex:0] withTimeout:0 completionHandler:^{
                NSLog(@"hi");
            }];
        }
    }];
}

@end

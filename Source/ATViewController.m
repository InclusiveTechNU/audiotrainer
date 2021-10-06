//
//  ATViewController.m
//  AudioTrainer
//
//  Created by Tommy McHugh on 9/28/21.
//

#import "ATViewController.h"

@implementation ATViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)exitButtonOnPress:(id)sender {
    [NSApplication.sharedApplication terminate:nil];
}

@end

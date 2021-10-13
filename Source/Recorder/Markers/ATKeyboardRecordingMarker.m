//
//  ATKeyboardRecordingMarker.m
//  ATKeyboardRecordingMarker
//
//  Created by Tommy McHugh on 10/7/21.
//

#import "ATKeyboardRecordingMarker.h"

@implementation ATKeyboardRecordingMarker

@synthesize delegate = _delegate;

+ (CFMachPortRef)createKeyboardListener
{
    return nil;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _delegate = nil;
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)fire
{
    
}

@end

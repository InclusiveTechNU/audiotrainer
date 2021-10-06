//
//  ATApplicationRecorderBase.m
//  ATApplicationRecorderBase
//
//  Created by Tommy McHugh on 9/28/21.
//

#import "ATApplicationRecorderBase.h"
#import "ATUnimplementedError.h"

@implementation ATApplicationRecorderBase

- (nonnull NSString *)applicationName
{
    @throw [ATUnimplementedError errorWithSelector:_cmd sourceClass:[self class]];
}

- (BOOL)isRecording
{
    return _recording;
}

- (void)startRecording
{
    if (self.isRecording)
    {
        return;
    }
    _recording = YES;
    // Capture the entire accessibility tree
    // Register focus, value, destruction based observers
    // Register keyboard calls to update
    
}

- (void)stopRecording:(nonnull void (^)(ATRecording * _Nullable))handler
{
    if (!self.isRecording)
    {
        handler(nil);
        return;
    }

    _recording = NO;
    handler(nil);
}

@end

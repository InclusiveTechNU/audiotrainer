//
//  AVAudioPCMBuffer+Append.m
//  AVAudioPCMBuffer+Append
//
//  Created by Tommy McHugh on 10/15/21.
//

#import "AVAudioPCMBuffer+Append.h"

@implementation AVAudioPCMBuffer (Append)

+ (AVAudioPCMBuffer * _Nullable)combineBuffers:(NSArray<AVAudioPCMBuffer *> *)buffers
{
    if (buffers.count == 0)
    {
        return nil;
    }
    AVAudioFrameCount frameCapacity = [buffers objectAtIndex:0].frameCapacity * (uint) buffers.count;
    AVAudioFormat *pcmFormat = [buffers objectAtIndex:0].format;
    AVAudioPCMBuffer * _Nullable buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:pcmFormat
                                                                        frameCapacity:frameCapacity];
    if (buffer == nil)
    {
        return nil;
    }
    
    if (
    
    for (NSUInteger i = 0; i < buffers.count; i++)
    {
        
    }
    return buffer;
}

@end

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

    AVAudioFrameCount frames = [buffers objectAtIndex:0].frameCapacity * (uint) buffers.count;
    AVAudioFrameCount length = [buffers objectAtIndex:0].frameLength * (uint) buffers.count;
    AVAudioFormat *pcmFormat = [buffers objectAtIndex:0].format;
    AVAudioPCMBuffer * _Nullable buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:pcmFormat
                                                                        frameCapacity:frames];
    buffer.frameLength = length;
    if (buffer == nil)
    {
        return nil;
    }

    for (NSUInteger i = 0; i < buffers.count; i++)
    {
        AVAudioPCMBuffer *bufferSegment = [buffers objectAtIndex:i];
        size_t bufferSize = bufferSegment.format.streamDescription->mBytesPerFrame * bufferSegment.frameLength;
        for (NSUInteger channel = 0; channel < buffer.format.channelCount; channel++)
        {
            memcpy(buffer.floatChannelData[channel]+(bufferSegment.frameLength * i),
                   bufferSegment.floatChannelData[channel],
                   bufferSize);
        }
    }
    return buffer;
}

- (NSArray<AVAudioPCMBuffer *> *)splitByTimeInterval:(NSTimeInterval)time;
{
    AVAudioFrameCount maxFrames = self.format.sampleRate * time;
    double segments = ceil((double) self.frameLength / (double) maxFrames);
    NSMutableArray<AVAudioPCMBuffer *> *buffers = [[NSMutableArray alloc] initWithCapacity:segments];
    
    AVAudioFrameCount framesLeft = self.frameLength;
    for (unsigned int i = 0; i < (unsigned int) segments; i++)
    {
        AVAudioFrameCount startFrame = maxFrames * i;
        AVAudioFrameCount frames;
        if (framesLeft >= maxFrames)
        {
            frames = maxFrames;
        }
        else
        {
            frames = framesLeft;
        }
        framesLeft -= frames;
        AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:self.format
                                                                 frameCapacity:frames];
        buffer.frameLength = frames;
        size_t bytesPerFrame = self.format.streamDescription->mBytesPerFrame;
        size_t bufferSize = bytesPerFrame * buffer.frameLength;
        for (NSUInteger channel = 0; channel < self.format.channelCount; channel++)
        {
            memcpy(buffer.floatChannelData[channel],
                   self.floatChannelData[channel]+startFrame,
                   bufferSize);
        }
        [buffers addObject:buffer];
    }
    return buffers;
}

@end

//
//  AVAudioPCMBuffer+Data.m
//  AVAudioPCMBuffer+Data
//
//  Created by Tommy McHugh on 10/21/21.
//

#import "AVAudioPCMBuffer+Data.h"

@implementation AVAudioPCMBuffer (Data)

+ (instancetype)fromData:(NSData *)data
{
    // TODO: Deal with nullable
    NSSet *allowedClasses = [NSSet setWithObjects:[NSDictionary class],
                                                  [NSString class],
                                                  [AVAudioFormat class],
                                                  [NSNumber class],
                                                  [NSArray class],
                                                  [NSMutableArray class],
                                                  [NSData class], nil];
    NSDictionary *dataDictionary = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses
                                                                       fromData:data
                                                                          error:nil];
    AVAudioFormat *format = [dataDictionary objectForKey:@"bufferFormat"];
    AVAudioFrameCount count = ((NSNumber *)[dataDictionary objectForKey:@"bufferCapacity"]).intValue;
    AVAudioFrameCount length = ((NSNumber *)[dataDictionary objectForKey:@"bufferLength"]).intValue;
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format
                                                             frameCapacity:count];
    buffer.frameLength = length;
    
    NSArray *bufferChannelData = (NSArray *)[dataDictionary objectForKey:@"bufferData"];
    size_t bufferSize = buffer.format.streamDescription->mBytesPerFrame * buffer.frameLength;
    for (NSUInteger channel = 0; channel < bufferChannelData.count; channel++)
    {
        NSData *channelData = [bufferChannelData objectAtIndex:channel];
        memcpy(buffer.floatChannelData[channel], channelData.bytes, bufferSize);
    }
    return buffer;
}

- (NSData *)data
{
    NSMutableArray *bufferChannelData = [[NSMutableArray alloc] init];
    size_t bufferSize = self.format.streamDescription->mBytesPerFrame * self.frameLength;
    for (NSUInteger channel = 0; channel < self.format.channelCount; channel++)
    {
        NSData *bufferData = [[NSData alloc] initWithBytes:self.floatChannelData[channel]
                                                    length:bufferSize];
        [bufferChannelData addObject:bufferData];
    }
    NSDictionary *dataDictionary = @{
        @"bufferCapacity": [NSNumber numberWithInt:self.frameCapacity],
        @"bufferLength": [NSNumber numberWithInt:self.frameLength],
        @"bufferFormat": self.format,
        @"bufferData": bufferChannelData
    };
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataDictionary
                                         requiringSecureCoding:NO
                                                         error:&error];
    NSLog(@"%@", error);
    return data;
}

@end

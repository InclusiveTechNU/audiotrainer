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
    NSSet *allowedClasses = [NSSet setWithObjects:[NSDictionary class],
                                                  [NSString class],
                                                  [AVAudioFormat class],
                                                  [NSNumber class],
                                                  [NSData class], nil];
    NSDictionary *dataDictionary = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses
                                                                       fromData:data
                                                                          error:nil];
    AVAudioFormat *format = [dataDictionary objectForKey:@"bufferFormat"];
    AVAudioFrameCount count = ((NSNumber *)[dataDictionary objectForKey:@"bufferCapacity"]).intValue;
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format
                                                             frameCapacity:count];
    // TODO: Copy memory to buffer
    return buffer;
}

- (NSData *)data
{
    NSData *bufferData = [[NSData alloc] initWithBytes:self.audioBufferList->mBuffers->mData
                                                length:self.audioBufferList->mBuffers->mDataByteSize];
    NSDictionary *dataDictionary = @{
        @"bufferCapacity": [NSNumber numberWithInt:self.frameCapacity],
        @"bufferFormat": self.format,
        @"bufferData": bufferData
    };
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataDictionary
                                         requiringSecureCoding:NO
                                                         error:&error];
    NSLog(@"%@", error);
    return data;
}

@end

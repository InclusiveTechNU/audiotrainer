//
//  AVAudioPCMBuffer+Append.h
//  AVAudioPCMBuffer+Append
//
//  Created by Tommy McHugh on 10/15/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioPCMBuffer (Append)

+ (AVAudioPCMBuffer * _Nullable)combineBuffers:(NSArray<AVAudioPCMBuffer *> *)buffers;

@end

NS_ASSUME_NONNULL_END

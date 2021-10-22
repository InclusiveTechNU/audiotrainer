//
//  AVAudioPCMBuffer+Data.h
//  AVAudioPCMBuffer+Data
//
//  Created by Tommy McHugh on 10/21/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioPCMBuffer (Data)

+ (instancetype _Nullable)fromData:(NSData *)data;
- (NSData * _Nullable)data;

@end

NS_ASSUME_NONNULL_END

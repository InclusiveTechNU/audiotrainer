//
//  ATApplicationPlayerBase.h
//  ATApplicationPlayerBase
//
//  Created by Tommy McHugh on 10/21/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ATRecording.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATApplicationPlayerBase : NSObject {
    NSTimer * _Nullable _pauseTimer;
    AVAudioEngine *_engine;
    AVAudioPlayerNode *_playerNode;
}

@property (nonatomic, strong, readonly) ATRecording *recording;
@property (nonatomic, assign, readonly) BOOL isReadyToPlay;
@property (nonatomic, assign, readonly) BOOL isPlaying;

- (instancetype)initWithRecording:(ATRecording *)recording;
- (void)playSectionAtIndex:(NSUInteger)index
                   timeout:(NSTimeInterval)timeout
         completionHandler:(void(^)(BOOL))handler;
- (void)playEndingWithCompletionHandler:(void(^)(BOOL))handler;

@end

NS_ASSUME_NONNULL_END
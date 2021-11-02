//
//  ATApplicationPlayer.h
//  Audio Trainer
//
//  Created by Tommy McHugh on 10/31/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ATApplicationPlayer

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, readonly, getter=isPaused) BOOL paused;

- (NSString *)applicationName;
- (void)pause;
- (void)restart;
- (void)stop;

- (void)playWithSectionCompletionHandler:(void(^)(BOOL))handler;
- (void)playWithTimeout:(NSTimeInterval)timeout sectionCompletionHandler:(void(^)(BOOL))handler;
- (void)playSectionAtIndex:(NSUInteger)index
         completionHandler:(void(^)(BOOL))handler;
- (void)playSectionAtIndex:(NSUInteger)index
                   timeout:(NSTimeInterval)timeout
         completionHandler:(void(^)(BOOL))handler;
- (void)playEndingWithCompletionHandler:(void(^)(BOOL))handler;

@optional

- (NSString *)applicationIdentifier;

@end
NS_ASSUME_NONNULL_END

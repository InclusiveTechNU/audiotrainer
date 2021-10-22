//
//  ATApplicationPlayerBase.h
//  ATApplicationPlayerBase
//
//  Created by Tommy McHugh on 10/21/21.
//

#import <Foundation/Foundation.h>
#import "ATRecording.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATApplicationPlayerBase : NSObject

@property (nonatomic, strong, readonly) ATRecording *recording;
@property (nonatomic, assign, readonly) BOOL isPlaying;

- (instancetype)initWithRecording:(ATRecording *)recording;
- (void)play;
- (void)waitForSectionWithTimeout:(NSTimeInterval)timeout completionHandler:(void(^)(void))handler;

@end

NS_ASSUME_NONNULL_END

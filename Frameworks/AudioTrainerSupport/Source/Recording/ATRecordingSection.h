//
//  ATRecordingSection.h
//  ATRecordingSection
//
//  Created by Tommy McHugh on 10/19/21.
//

#import <Foundation/Foundation.h>
#import "ATApplicationEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATRecordingSection : NSObject <NSSecureCoding>

@property (nonatomic, assign, readonly) double pauseTime;
@property (nonatomic, assign, readonly) double resumeTime;
@property (nonatomic, strong, readonly) NSArray<ATApplicationEvent *> *events;

- (instancetype)initWithPauseTime:(double)pauseTime
                       resumeTime:(double)resumeTime
                           events:(NSArray<ATApplicationEvent *> *)events;

- (void)updatePauseTime:(double)pauseTime;
- (void)updateResumeTime:(double)resumeTime;

@end

NS_ASSUME_NONNULL_END

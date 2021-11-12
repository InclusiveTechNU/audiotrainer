//
//  ATSpeechBreak.h
//  ATSpeechBreak
//
//  Created by Tommy McHugh on 10/15/21.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>
#import "ATSpeechRecognitionResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATSpeechBreak : NSObject

@property (nonatomic, assign, readonly) double startTime;
@property (nonatomic, assign, readonly) double endTime;

+ (NSArray<ATSpeechBreak *> *)breaksFromSpeechResults:(NSArray<ATSpeechRecognitionResult *> *)results;
+ (NSArray<ATSpeechBreak *> *)breaksFromSpeechResult:(SFSpeechRecognitionResult *)result;
- (instancetype)initWithStartTime:(double)startTime endTime:(double)endTime;

@end

NS_ASSUME_NONNULL_END

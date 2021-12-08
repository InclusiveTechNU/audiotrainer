//
//  ATSpeechRecognitionResult.h
//  Audio Trainer
//
//  Created by Tommy McHugh on 11/11/21.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATSpeechRecognitionResult : NSObject

@property (nonatomic, assign, readonly) NSTimeInterval length;
@property (nonatomic, strong, readonly) SFSpeechRecognitionResult *result;

- (instancetype)initWithResult:(SFSpeechRecognitionResult *)result length:(NSTimeInterval)length;

@end

NS_ASSUME_NONNULL_END

//
//  ATSpeechRecognizerDelegate.h
//  ATSpeechRecognizerDelegate
//
//  Created by Tommy McHugh on 10/15/21.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>
#import "ATSpeechRecording.h"

NS_ASSUME_NONNULL_BEGIN

@class ATSpeechRecognizer;

@protocol ATSpeechRecognizerDelegate <NSObject>

@optional

- (void)speechRecognizer:(ATSpeechRecognizer *)recognizer didFinishRecognizingSpeech:(ATSpeechRecording *)recording;
- (void)speechRecognizer:(ATSpeechRecognizer *)recognizer didFailToRecordWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END

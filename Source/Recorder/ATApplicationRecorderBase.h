//
//  ATApplicationRecorderBase.h
//  ATApplicationRecorderBase
//
//  Created by Tommy McHugh on 9/28/21.
//

#import <Foundation/Foundation.h>
#import "ATApplicationRecorder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATApplicationRecorderBase : NSObject <ATApplicationRecorder>
{
    BOOL _recording;
}

@end

NS_ASSUME_NONNULL_END

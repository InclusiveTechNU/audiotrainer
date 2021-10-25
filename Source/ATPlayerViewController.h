//
//  ATPlayerViewController.h
//  ATPlayerViewController
//
//  Created by Tommy McHugh on 10/6/21.
//

#import <Cocoa/Cocoa.h>
#import "ATApplicationPlayerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATPlayerViewController : NSViewController {
    ATApplicationPlayerBase * _Nullable _player;
    AVAudioEngine *_engine;
    AVAudioPlayerNode *_playerNode;
}

@end

NS_ASSUME_NONNULL_END

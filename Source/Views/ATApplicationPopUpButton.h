//
//  ATApplicationPopUpButton.h
//  ATApplicationPopUpButton
//
//  Created by Tommy McHugh on 9/28/21.
//

#import <Cocoa/Cocoa.h>
#import "ATApplicationRecorder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATApplicationPopUpButton : NSPopUpButton {
    NSMutableArray<id <ATApplicationRecorder>> *_recorders;
    __weak id <ATApplicationRecorder> _Nullable _selectedRecorder;
}

- (id <ATApplicationRecorder>)selectedRecorder;
- (NSArray<id <ATApplicationRecorder>> *)recorders;
- (void)addRecorders:(NSArray<id <ATApplicationRecorder>> *)recorders;

@end

NS_ASSUME_NONNULL_END

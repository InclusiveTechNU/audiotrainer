//
//  ATKeyboardShortcutManager.m
//  Audio Trainer
//
//  Created by Tommy McHugh on 11/13/21.
//

#import "ATKeyboardShortcutManager.h"

static CGEventRef ATKeyboardShortcutManagerEventCallback(CGEventTapProxy proxy,
                                                         CGEventType type,
                                                         CGEventRef event,
                                                         void *refcon)
{
    return event;
}

@implementation ATKeyboardShortcutManager

@end

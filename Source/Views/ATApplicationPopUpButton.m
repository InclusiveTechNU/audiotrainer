//
//  ATApplicationPopUpButton.m
//  ATApplicationPopUpButton
//
//  Created by Tommy McHugh on 9/28/21.
//

#import "ATApplicationPopUpButton.h"
#import "ATApplicationRecorderUtilities.h"

@implementation ATApplicationPopUpButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self removeAllItems];
    _recorders = [[NSMutableArray alloc] init];
    _selectedRecorder = nil;
}

- (id <ATApplicationRecorder>)selectedRecorder
{
    return _selectedRecorder;
}

- (NSArray<id <ATApplicationRecorder>> *)recorders
{
    return _recorders;
}

- (void)addRecorders:(NSArray<id <ATApplicationRecorder>> *)recorders
{
    NSArray<NSString *> *titles = [ATApplicationRecorderUtilities applicationTitlesForRecorders:recorders];
    [_recorders addObjectsFromArray:recorders];
    if (_recorders.count > 0)
    {
        _selectedRecorder = [_recorders objectAtIndex:0];
    }
    [self addItemsWithTitles:titles];
}

@end

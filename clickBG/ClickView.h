/* ClickView */

#import <Cocoa/Cocoa.h>
#import "ClickAction.h"

@interface ClickView : NSView
{
    ClickAction *myAction;
    NSImage *drawed;
    BOOL selected;
    int corner;
}

- (id)initWithFrame:(NSRect)frameRect action:(ClickAction *)anAction corner:(int)theCorner;

- (void) drawBuf: (NSRect) rect;
- (void) setSelected: (BOOL) selected;
@end

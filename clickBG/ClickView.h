/* ClickView */

#import <Cocoa/Cocoa.h>
#import "ClickAction.h"

@interface ClickView : NSView
{
    Clicker *myClicker;
    NSArray *myActions;
	NSArray *actionsGroups;
    NSImage *drawed;
    NSTrackingRectTag trackTag;
    BOOL selected;
    NSInteger corner;
}


- (id)initWithFrame:(NSRect)frameRect actions:(NSArray *)actions corner:(NSInteger) theCorner clicker:(Clicker *)clicker;

- (void) drawBuf: (NSRect) rect;
- (void) setSelected: (BOOL) selected;
//- (ClickAction *) clickAction;
//- (void) setClickAction: (ClickAction *) action;
- (NSArray *) clickActions;
- (void) setClickActions: (NSArray *) actions;
- (ClickAction *) clickActionForModifierFlags: (NSUInteger)modifiers;
- (NSArray *) clickActionsForModifierFlags:(NSUInteger) modifiers;
- (NSArray *) clickActionsForModifierFlags:(NSUInteger) modifiers
								andTrigger:(NSInteger) trigger;

- (NSArray *) hoverActionsForModifierFlags:(NSUInteger) modifiers;
- (void) setTrackingRectTag:(NSTrackingRectTag) tag;
- (NSTrackingRectTag) trackingRectTag;
- (NSArray *) actionsGroups;
- (NSArray *) actionsGroupsForModifiers:(NSInteger) mods;
@end

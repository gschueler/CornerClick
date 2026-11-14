/*
 Copyright 2003-2010 Greg Schueler
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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

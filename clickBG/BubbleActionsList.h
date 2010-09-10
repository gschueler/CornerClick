//
//  BubbleActionsList.h
//  CornerClick
//
//  Created by Greg Schueler on Fri Apr 30 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BubbleAction.h"
#import "ClickAction.h"

@interface BubbleActionsList : NSObject 
{
	NSMutableArray *bubbleActions;
	CGFloat spacingSize;
	NSSize detSize;
	NSColor *highlightColor;
	NSInteger selected;
	NSInteger lastSelected;
	NSInteger steps;
	NSInteger curStep;
    NSInteger theCorner;
    BOOL showAllModifiers;
}
- (id) initWithSpacing: (CGFloat) spacing
			   andActions: (NSArray *) actions
			 itemSelected: (NSInteger) theSelected
		andHighlightColor:(NSColor *) theColor
                forCorner:(NSInteger) corner;
- (NSInteger) selectedItem;
- (NSInteger) selectedModifiers;
- (NSInteger) selectedTrigger;
- (BOOL) selectedHoverTriggerDelayed;
- (ClickAction *) selectedClickAction;
- (void) updateSelected: (NSInteger) selectedMod; 
- (NSRect) drawingRectForAction: (NSInteger)act isSelected: (BOOL) isSelected inRect:(NSRect) rect;

- (void) setSpacingSize: (CGFloat) size;
- (void) drawInRect:(NSRect) rect;

- (void) calcPreferredSize;
- (void) calcPreferredSize:(BOOL) recalc;
- (NSSize) preferredSize;
- (BOOL) showAllModifiers;
- (void) setShowAllModifiers: (BOOL)show;

- (NSInteger) corner;


@end

//
//  BubbleActionsList.h
//  CornerClick
//
//  Created by Greg Schueler on Fri Apr 30 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BubbleAction.h"


@interface BubbleActionsList : NSObject 
{
	NSMutableArray *bubbleActions;
	float spacingSize;
	NSDictionary *attributes;
	NSDictionary *smallTextAttributes;
	NSSize detSize;
	NSColor *highlightColor;
	int selected;
	int lastSelected;
	int steps;
	int curStep;
    int theCorner;
    BOOL showAllModifiers;
}
- (id) initWithAttributes: (NSDictionary *) attrs
      smallTextAttributes: (NSDictionary *) sattrs
			   andSpacing: (float) spacing
			   andActions: (NSArray *) actions
			 itemSelected: (int) theSelected
		andHighlightColor:(NSColor *) theColor
                forCorner:(int) corner;
- (int) selectedItem;
- (int) selectedModifiers;
- (int) selectedTrigger;
- (void) updateSelected: (int) selectedMod; 
- (NSRect) drawingRectForAction: (int)act isSelected: (BOOL) isSelected inRect:(NSRect) rect;
- (void) setSpacingSize: (float) size;
- (void) drawInRect:(NSRect) rect;
- (NSSize) preferredSize;
- (BOOL) showAllModifiers;
- (void) setShowAllModifiers: (BOOL)show;

- (int) corner;


@end

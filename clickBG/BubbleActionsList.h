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
	NSSize detSize;
	NSColor *highlightColor;
	int selected;
	int destSelected;
	int steps;
	int curStep;
}
- (id) initWithAttributes: (NSDictionary *) attrs
			   andSpacing: (float) spacing
			   andActions: (NSArray *) actions
			 itemSelected: (int) theSelected
		andHighlightColor:(NSColor *) theColor;
- (int) selectedItem;
- (int) selectedModifiers;
- (int) selectedTrigger;
- (void) setSpacingSize: (float) size;
- (void) drawInRect:(NSRect) rect;
- (NSSize) preferredSize;
- (id) initWithAttributes: (NSDictionary *) attrs
			   andSpacing: (float) spacing
			   andActions: (NSArray *) actions;



@end

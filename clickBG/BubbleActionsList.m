//
//  BubbleActionsList.m
//  CornerClick
//
//  Created by Greg Schueler on Fri Apr 30 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "BubbleActionsList.h"


@implementation BubbleActionsList

- (id) initWithAttributes: (NSDictionary *) attrs
			   andSpacing: (float) spacing
			   andActions: (NSArray *) actions
			 itemSelected: (int) theSelected
		andHighlightColor:(NSColor *) theColor
{
	if(DEBUG_ON)NSLog(@"init bubbleActionsList, actions class: %@",[actions class]);
	int i;
    if(self=[super init]){
		spacingSize=spacing;
		selected = theSelected;
		attributes = [[NSDictionary alloc] initWithDictionary:attrs];
		bubbleActions = nil;
		if(theColor != nil){
			highlightColor = [theColor copy];			
		}else{
			highlightColor = [[NSColor selectedControlColor] copy];
		}
		detSize = NSMakeSize(0,0);
		if(actions != nil){
			bubbleActions = [[NSMutableArray alloc] initWithCapacity:[actions count]];
			for(i=0; i<[actions count];i++){
				BubbleAction *ba = (BubbleAction *)[actions objectAtIndex:i];
				NSSize actSz = [ba preferredSize];
				detSize.height+=actSz.height;
				if(i>0){
					detSize.height+=spacingSize;
				}
				if(actSz.width > detSize.width){
					detSize.width=actSz.width;
				}
				[bubbleActions addObject:ba];
			}
			[self calcPreferredSize];

		}
	}
	return self;
}

- (void) calcPreferredSize
{
	int i;
	NSSize sz = NSMakeSize(0,0);
	for(i=0; i<[bubbleActions count];i++){
		BubbleAction *ba = (BubbleAction *)[bubbleActions objectAtIndex:i];
		NSSize actSz = [ba preferredSize];
		sz.height+=actSz.height;
		if(i>0){
			sz.height+=spacingSize;
		}
		if(actSz.width > sz.width){
			sz.width=actSz.width;
		}
	}
	detSize=sz;
}


- (NSSize) preferredSize
{
	return detSize;
}

- (void) setSpacingSize: (float) size
{
	spacingSize=size;
	[self setSpacings];
	[self calcPreferredSize];
}


- (void) setSpacings
{
	int i;
	for(i=0;i<[bubbleActions count];i++){
		[(BubbleAction *)[bubbleActions objectAtIndex:i] setSpacingSize: spacingSize];
	}
}


- (int) selectedModifiers
{
	if(selected < 0)
		return -1;
	BubbleAction *ba = (BubbleAction *)[bubbleActions objectAtIndex: selected];
	NSArray *actions = [ba actions];
	if(actions !=nil && [actions count]>0){
		ClickAction *act = (ClickAction *)[actions objectAtIndex:0];
		
		return [act modifiers];
	}else{
		return -1;
	}
}
- (int) selectedTrigger
{
	if(selected < 0)
		return -1;
	BubbleAction *ba = (BubbleAction *)[bubbleActions objectAtIndex: selected];
	NSArray *actions = [ba actions];
	if(actions !=nil && [actions count]>0){
		ClickAction *act = (ClickAction *)[actions objectAtIndex:0];
		
		return [act trigger];
	}else{
		return -1;
	}
}

- (int) selectedItem
{
	return selected;
}

- (NSPoint) originForBubbleAction:(int) ndx
{
	float sum=0;
	int i;
	for(i=0;i<[bubbleActions count];i++){
		NSSize s = [(BubbleAction *)[bubbleActions objectAtIndex:i] preferredSize];
		sum+=s.height;
	}
	return NSMakePoint(0,detSize.height-sum);
}

- (void) drawInRect:(NSRect) rect
{
	int i,ox,oy;
	float ht=spacingSize/2;
	float cur = rect.size.height;
	
	for(i=0; i< [bubbleActions count];i++){
		ox=0;
		oy=0;
		BubbleAction *ba = (BubbleAction *)[bubbleActions objectAtIndex:i];
		NSSize sz = [ba preferredSize];
		cur = cur - sz.height;
		if(i>0){
			cur-=spacingSize;
		}
		if(i==selected){
			
			[self drawSelectedInFrame: NSMakeRect(rect.origin.x-ht,rect.origin.y+cur-ht,rect.size.width+spacingSize,sz.height+spacingSize)];
		}
		NSRect fr = NSMakeRect(rect.origin.x + ox,rect.origin.y+cur + oy,sz.width,sz.height);
		[ba drawInRect:fr];
		
	}
}

- (void) drawSelectedInFrame:(NSRect) rect
{
	NSBezierPath *nbp = [BubbleView roundedRect:rect rounding:16];
	//[[NSColor clearColor] set];
	//[nbp fill];
	[[highlightColor colorWithAlphaComponent:0.50] set];
	[nbp fill];
	[[NSColor whiteColor] set];
	[nbp setLineJoinStyle:NSRoundLineJoinStyle];
	[nbp setLineWidth:3];
	[nbp stroke];
}

- (void)dealloc
{
	[highlightColor release];
	[attributes release];
	[bubbleActions release];
}

@end

//
//  BubbleView.h
//  CornerClick
//
//  Created by Greg Schueler on Fri Apr 30 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BubbleAction.h"
#import "BubbleActionsList.h"

@class BubbleAction;

@interface BubbleView : NSView {
    NSColor *fadeFromColor;
    NSColor *fadeToColor;
    NSImage *textArea;
    NSDictionary *stringAttrs;
    NSDictionary *shadowAttrs;
	BubbleActionsList *drawingObject;
	
	NSArray *images;
    float fadeAlpha;
    float roundingSize;
    float insetSize;
    int pointCorner;
    BOOL dirty;
    int tailLen;
    BOOL drawHilite;
	BOOL showModifierTitle;
	NSRect prefFrame;
}

- (id) initWithFrame: (NSRect) frame
		   andDrawingObject: (BubbleActionsList *)obj;

- (id) initWithFrame: (NSRect) frame 
	andDrawingObject: (BubbleActionsList *)obj
            fadeFrom: (NSColor *)fromCol
			  fadeTo: (NSColor *) toCol
		  cornerSize: (float) cornerSize
         pointCorner: (int) pCorner;

- (void) setFadeFromColor: (NSColor *)color;
- (void) setFadeToColor: (NSColor *) color;
- (void) setPointCorner: (int) pCorner;
- (void) setDrawingObject: (BubbleActionsList *) obj;
- (void) drawFadeFrame: (NSRect)rect;
- (void) drawGradient: (NSRect) therect fromColor:(NSColor *) from toColor:(NSColor *) to
            direction: (int) dir;
- (void) setDrawFont:(NSFont *) font color:(NSColor *) color;
- (void) setDrawHilite:(BOOL)draw;
- (BOOL) drawHilite;
- (void) setInsetSize:(float) size;
- (float) insetSize;
- (void) recalcSize;
- (NSRect) preferredFrame;
- (void) calcPreferredFrame;
- (BubbleActionsList *) bubbleActionsList: (NSArray *)actions selected:(int) sel;
- (BubbleAction *) bubbleAction: (NSArray *)actions;
+ (NSBezierPath *)roundedRect: (NSRect)rect rounding: (float) theRounding;
@end

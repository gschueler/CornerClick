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
    //NSImage *textArea;
    NSImage *fadedFrame;
    NSDictionary *stringAttrs;
    NSDictionary *shadowAttrs;
    NSDictionary *smallTextAttributes;
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
- (BubbleActionsList *) drawingObject;
- (void) drawFadeFrame: (NSRect)rect;
- (void) drawGradient: (NSRect) therect fromColor:(NSColor *) from toColor:(NSColor *) to
            direction: (int) dir;
- (void) setDrawFont:(NSFont *) font color:(NSColor *) color;
- (void) setDrawHilite:(BOOL)draw;
- (BOOL) drawHilite;
- (float) roundingSize;
- (void) setInsetSize:(float) size;
- (float) insetSize;
- (void) recalcSize;
- (NSRect) preferredFrame;
- (void) calcPreferredFrame;
- (BubbleActionsList *) bubbleActionsList: (NSArray *)actions 
                                forCorner: (int) corn
                                 selected: (int) sel
						andHighlightColor: (NSColor *) theColor;
- (BubbleAction *) bubbleAction: (NSArray *)actions;
- (void) newSelectedMod: (int) ndx;
+ (NSBezierPath *) roundedRect: (NSRect)rect rounding: (float) theRounding;
+ (NSBezierPath *) roundedRect: (NSRect)rect roundingTopLeft: (float) roundTL roundingTopRight: (float) roundTR
           roundingBottomLeft: (float)roundBL roundingBottomRight: (float) roundBR;
+ (NSDictionary *) normalTextAttrs;
+ (NSDictionary *) smallTextAttrs;

//Utility drawing functions

/**
 * Draw a round rectangle with depth
 */
+ (void) drawRoundedBezel: (NSRect) rect 
                 rounding:(float) theRounding
                    depth:(float) depth;
+ (void) drawRoundedBezel: (NSRect) rect 
                 rounding:(float) theRounding
                    depth:(float) depth
                  bgColor:(NSColor *)bgcol 
              shadowColor:(NSColor *)shadow
               shineColor:(NSColor *)shine;

    /**
    * add depth and shadow to any path
     */
+ (void) addShadow: (NSBezierPath *)path 
             depth:(float) depth;

+ (void) addShadow: (NSBezierPath *)path 
             depth:(float) depth
           bgColor:(NSColor *)bgcol 
       shadowColor:(NSColor *)shadow
        shineColor:(NSColor *)shine;
@end

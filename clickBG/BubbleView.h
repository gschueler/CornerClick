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
    CGFloat fadeAlpha;
    CGFloat roundingSize;
    CGFloat insetSize;
    NSInteger pointCorner;
    BOOL dirty;
    NSInteger tailLen;
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
		  cornerSize: (CGFloat) cornerSize
         pointCorner: (NSInteger) pCorner;

- (void) setFadeFromColor: (NSColor *)color;
- (void) setFadeToColor: (NSColor *) color;
- (void) setPointCorner: (NSInteger) pCorner;
- (void) setDrawingObject: (BubbleActionsList *) obj;
- (BubbleActionsList *) drawingObject;
- (void) drawFadeFrame: (NSRect)rect;

- (void) setDrawFont:(NSFont *) font color:(NSColor *) color;
- (void) setDrawHilite:(BOOL)draw;
- (BOOL) drawHilite;
- (CGFloat) roundingSize;
- (void) setInsetSize:(CGFloat) size;
- (CGFloat) insetSize;
- (void) recalcSize;
- (NSRect) preferredFrame;
- (void) calcPreferredFrame;
- (void) calcPreferredFrame:(BOOL) recalc;
- (BubbleActionsList *) bubbleActionsList: (NSArray *)actions 
                                forCorner: (NSInteger) corn
                                 selected: (NSInteger) sel
						andHighlightColor: (NSColor *) theColor;
- (BubbleAction *) bubbleAction: (NSArray *)actions;
- (void) newSelectedMod: (NSInteger) ndx;

+ (void) addGlass:(NSRect) therect;
+ (void) addGlass:(NSRect) therect withColor: (NSColor *)thecolor withRounding: (CGFloat) rounding;
+ (void) addGlassBG:(NSRect) therect withColor: (NSColor *)thecolor withRounding: (CGFloat) rounding;
+ (void) addGlassFG:(NSRect) therect withColor: (NSColor *)thecolor withRounding: (CGFloat) rounding;
+ (void) drawGradient: (NSRect) therect fromColor:(NSColor *) from toColor:(NSColor *) tocol
            direction: (NSInteger) dir;

+ (void) drawGradient: (NSRect) therect fromColor:(NSColor *) fromCol toColor:(NSColor *) tocol  fromPoint: (NSPoint) sPoint toPoint: (NSPoint) ePoint;

+ (void) drawGradient:(NSRect) therect fromColor: (NSColor *) fromCol toColor:(NSColor *) tocol
            fromPoint:(NSPoint) sPoint toPoint: (NSPoint) ePoint extendBefore:(BOOL)ebefore extendAfter:(BOOL)eafter;

+ (NSBezierPath *) roundedRect: (NSRect)rect rounding: (CGFloat) theRounding;
+ (NSBezierPath *) roundedRect: (NSRect)rect roundingTopLeft: (CGFloat) roundTL roundingTopRight: (CGFloat) roundTR
           roundingBottomLeft: (CGFloat)roundBL roundingBottomRight: (CGFloat) roundBR;
+ (NSDictionary *) normalTextAttrs;
+ (NSDictionary *) smallTextAttrs;

//Utility drawing functions

/**
 * Draw a round rectangle with depth
 */
+ (void) drawRoundedBezel: (NSRect) rect 
                 rounding:(CGFloat) theRounding
                    depth:(CGFloat) depth;
+ (void) drawRoundedBezel: (NSRect) rect 
                 rounding:(CGFloat) theRounding
                    depth:(CGFloat) depth
                  bgColor:(NSColor *)bgcol 
              shadowColor:(NSColor *)shadow
               shineColor:(NSColor *)shine;

    /**
    * add depth and shadow to any path
     */
+ (void) addShadow: (NSBezierPath *)path 
             depth:(CGFloat) depth;

+ (void) addShadow: (NSBezierPath *)path 
             depth:(CGFloat) depth
           bgColor:(NSColor *)bgcol 
       shadowColor:(NSColor *)shadow
        shineColor:(NSColor *)shine;
@end

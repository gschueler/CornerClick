//
//  GrayView.h
//  TestBox
//
//  Created by Greg Schueler on Fri Jul 18 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GrayView : NSView {
    NSImage *iconImage;
    NSColor *fadeFromColor;
    NSColor *fadeToColor;
    NSImage *textArea;
    NSString *myString;
    NSDictionary *stringAttrs;
    NSDictionary *shadowAttrs;
	NSArray *actions;
	NSRect prefFrame;
    float fadeAlpha;
    float roundingSize;
    float insetSize;
    int pointCorner;
    BOOL dirty;
    int tailLen;
    BOOL drawHilite;
	BOOL showModifierTitle;
}

- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg andImage: (NSImage *) img;
- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg;
- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg andImage: (NSImage *) img
            fadeFrom: (NSColor *)fromCol fadeTo: (NSColor *) toCol cornerSize: (float) cornerSize
         pointCorner: (int) pCorner;
- (void) setFadeFromColor: (NSColor *)color;
- (void) setFadeToColor: (NSColor *) color;
- (void) setPointCorner: (int) pCorner;
- (void) setActions: (NSArray *) actions;
- (void) drawFadeFrame: (NSRect)rect;
- (void) drawGradient: (NSRect) therect fromColor:(NSColor *) from toColor:(NSColor *) to
            direction: (int) dir;
- (void) setDrawString: (NSString *) drawString;
- (void) setIcon: (NSImage *) icon;
- (void) setDrawFont:(NSFont *) font color:(NSColor *) color;
- (void) setDrawHilite:(BOOL)draw;
- (BOOL) drawHilite;
- (void) setInsetSize:(float) size;
- (void) setShowModifiersTitle: (BOOL) showTitle;
- (BOOL) showModifiersTitle;
- (float) insetSize;
- (void) recalcSize;
- (NSRect) preferredFrame;
- (NSRect) calcPreferredFrame;

@end

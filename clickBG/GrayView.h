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
    NSColor *fadeColor;
    NSImage *textArea;
    NSString *myString;
    NSDictionary *stringAttrs;
    NSDictionary *shadowAttrs;
    float fadeAlpha;
    float roundingSize;
    float insetSize;
    int pointCorner;
    BOOL dirty;
    int tailLen;
}

- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg andImage: (NSImage *) img;
- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg;
- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg andImage: (NSImage *) img
           fadeColor: (NSColor *)fadeCol fadeAlpha: (float)fAlpha cornerSize: (float) cornerSize
         pointCorner: (int) pCorner;
- (void) setFadeColor: (NSColor *)color;
- (void) setFadeAlpha: (float) fadeAlpha;
- (void) setPointCorner: (int) pCorner;
- (void) drawFadeFrame: (NSRect)rect;
- (void) setDrawString: (NSString *) drawString;
- (void) setIcon: (NSImage *) icon;
- (void) recalcSize;
- (NSRect) preferredFrame;

@end

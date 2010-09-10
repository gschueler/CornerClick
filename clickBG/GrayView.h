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
    CGFloat fadeAlpha;
    CGFloat roundingSize;
    CGFloat insetSize;
    NSInteger pointCorner;
    BOOL dirty;
    NSInteger tailLen;
    BOOL drawHilite;
	BOOL showModifierTitle;
}

- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg andImage: (NSImage *) img;
- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg;
- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg andImage: (NSImage *) img
            fadeFrom: (NSColor *)fromCol fadeTo: (NSColor *) toCol cornerSize: (CGFloat) cornerSize
         pointCorner: (NSInteger) pCorner;
- (void) setFadeFromColor: (NSColor *)color;
- (void) setFadeToColor: (NSColor *) color;
- (void) setPointCorner: (NSInteger) pCorner;
- (void) setActions: (NSArray *) actions;
- (void) drawFadeFrame: (NSRect)rect;
- (void) drawGradient: (NSRect) therect fromColor:(NSColor *) from toColor:(NSColor *) to
            direction: (NSInteger) dir;
- (void) setDrawString: (NSString *) drawString;
- (void) setIcon: (NSImage *) icon;
- (void) setDrawFont:(NSFont *) font color:(NSColor *) color;
- (void) setDrawHilite:(BOOL)draw;
- (BOOL) drawHilite;
- (void) setInsetSize:(CGFloat) size;
- (void) setShowModifiersTitle: (BOOL) showTitle;
- (BOOL) showModifiersTitle;
- (CGFloat) insetSize;
- (void) recalcSize;
- (NSRect) preferredFrame;
- (NSRect) calcPreferredFrame;

@end

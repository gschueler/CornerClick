//
//  BubbleAction.h
//  CornerClick
//
//  Created by Greg Schueler on Fri Apr 30 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BubbleAction : NSObject {
	NSArray *actions;
	CGFloat spacingSize;
	NSSize preferredSize;
}

+ (void) initialize;
+ (NSImage *) triangleImage;
- (id) initWithSpacing:(CGFloat) space;
- (id) initWithSpacing:(CGFloat) space
					 andActions:(NSArray *) theActions;
- (void) setSpacingSize: (CGFloat) size;
- (NSSize) preferredSize;
- (void) calcPreferredSize;
- (void) drawInRect: (NSRect) rect;
- (void) setActions:(NSArray *)theActions;
- (NSArray *)actions;
- (NSString *)modifiersLabel;
- (NSComparisonResult)triggerCompare:(BubbleAction *)anAction;

@end

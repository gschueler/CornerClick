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
	float spacingSize;
	NSSize preferredSize;
}

+ (void) initialize;
+ (NSImage *) triangleImage;
- (id) initWithSpacing:(float) space;
- (id) initWithSpacing:(float) space
					 andActions:(NSArray *) theActions;
- (void) setSpacingSize: (float) size;
- (NSSize) preferredSize;
- (void) calcPreferredSize;
- (void) drawInRect: (NSRect) rect;
- (void) setActions:(NSArray *)theActions;
- (NSArray *)actions;
- (NSString *)modifiersLabel;
- (NSComparisonResult)triggerCompare:(BubbleAction *)anAction;

@end

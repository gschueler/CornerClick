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
	NSDictionary *stringAttrs;
	float spacingSize;
	NSSize preferredSize;
}

- (id) initWithStringAttributes: (NSDictionary *) attrs
					 andSpacing:(float) space;
- (id) initWithStringAttributes: (NSDictionary *) attrs
					 andSpacing:(float) space
					 andActions:(NSArray *) theActions;
- (void) setSpacingSize: (float) size;
- (NSSize) preferredSize;
- (void) drawInRect: (NSRect) rect;
- (void) setActions:(NSArray *)theActions;
- (NSArray *)actions;

@end

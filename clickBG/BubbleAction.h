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
	NSDictionary *smallTextAttrs;
	float spacingSize;
	NSSize preferredSize;
}

+ (void) initialize;
+ (NSImage *) triangleImage;
- (id) initWithStringAttributes: (NSDictionary *) attrs
            smallTextAttributes: (NSDictionary *) sattrs
					 andSpacing:(float) space;
- (id) initWithStringAttributes: (NSDictionary *) attrs
            smallTextAttributes: (NSDictionary *) sattrs
					 andSpacing:(float) space
					 andActions:(NSArray *) theActions;
- (void) setSpacingSize: (float) size;
- (NSSize) preferredSize;
- (void) drawInRect: (NSRect) rect;
- (void) setActions:(NSArray *)theActions;
- (NSArray *)actions;
- (NSString *)modifiersLabel;
- (NSComparisonResult)triggerCompare:(BubbleAction *)anAction;

@end

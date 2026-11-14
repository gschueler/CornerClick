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

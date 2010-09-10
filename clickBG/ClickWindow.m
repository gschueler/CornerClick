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

#import "ClickWindow.h"

@implementation ClickWindow


// We override this initializer so we can set the NSBorderlessWindowMask styleMask, and set a few other important settings
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag corner: (NSInteger) myCorner 
{
    id win=[super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];    
    if(win){
        corner=myCorner;
    }
    return win;
}

-( BOOL) canBecomeKeyWindow
{
    return YES;
}
-( BOOL) canBecomeMainWindow
{
    return YES;
}

-(BOOL) acceptsFirstResponder
{
	return YES;
}

- (void) flagsChanged:(NSEvent *)theEvent
{
    if(DEBUG_ON)NSLog(@"flagsChanged in ClickWindow.m");
    [[NSApp delegate] flagsChanged:theEvent];
}

- (NSInteger) corner
{
    return corner;
}


- (void)scrollWheel: (NSEvent *)theEvent
{
	//if(DEBUG_ON)NSLog(@"scroll wheel motion in ClickWindow.m: %@", theEvent);
	[(Clicker *)[NSApp delegate] scrollWheel:theEvent atCorner:corner];
}

- (void)keyDown:(NSEvent *)theEvent
{
	if(DEBUG_ON)NSLog(@"key down event in ClickWindow.m");
	[[NSApp delegate] keyDown:theEvent];
	
}

@end


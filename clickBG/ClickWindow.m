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


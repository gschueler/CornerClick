#import "ClickWindow.h"

@implementation ClickWindow


// We override this initializer so we can set the NSBorderlessWindowMask styleMask, and set a few other important settings
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag corner: (int) myCorner 
{
    id win=[super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if(win){
        corner=myCorner;
    }
    return win;
}


- (int) corner
{
    return corner;
}
@end


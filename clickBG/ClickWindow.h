/* ClickWindow */

#import <Cocoa/Cocoa.h>

@interface ClickWindow : NSPanel
{
    int corner;
}
- (int) corner;
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag corner: (int) myCorner;
@end

/* ClickWindow */

#import <Cocoa/Cocoa.h>

@interface ClickWindow : NSPanel
{
    NSInteger corner;
}
- (NSInteger) corner;
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag corner: (NSInteger) myCorner;
@end

/* FileActionMenuItem */

#import <Cocoa/Cocoa.h>
#import "ClickBoxPref.h"
@class ClickBoxPref;

@interface FileActionMenuItem : NSMenuItem
{
    NSString *filePath;
    ClickBoxPref *myPref;
}
- (id) initWithFilePath: (NSString *) path andClickPref:(ClickBoxPref *) pref andTitle:(NSString *) title;
- (id) initWithFilePath: (NSString *) path andClickPref:(ClickBoxPref *) pref;
- (IBAction)doAction:(id)sender;
@end

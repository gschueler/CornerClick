/* ClickAction */

#import <Cocoa/Cocoa.h>

@interface ClickAction : NSObject
{
    NSString* myString;
    int theType;
    int theCorner;
    NSImage *myIcon;
    NSString *myLabel;
}

- (void)doAction:(NSEvent*)theEvent;
-(id)initWithType: (int) type andString: (NSString *)theString forCorner: (int) corner;
-(id)initWithType: (int) type andString: (NSString *)theString forCorner: (int) corner withLabel:(NSString *) label;
-(void)hideCurrentAction;
-(void)hideOthersAction;
-(int)type;
-(int)corner;
-(NSString *)string;
-(NSString *)label;
-(NSImage *)icon;
@end

/* ClickAction */

#import <Cocoa/Cocoa.h>

@interface ClickAction : NSObject
{
    NSString* myString;
    int theType;
}

- (void)doAction:(NSEvent*)theEvent;
-(id)initWithType: (int) type andString: (NSString *)theString;
-(void)hideCurrentAction;
-(void)hideOthersAction;
@end

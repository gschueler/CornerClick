/* ClickAction */

#import <Cocoa/Cocoa.h>
@class Clicker;

@interface ClickAction : NSObject
{
    NSString* myString;
    int theType;
    int theCorner;
    int theModifiers;
    NSImage *myIcon;
    NSString *myLabel;
    Clicker *myClicker;
}

- (void)doAction:(NSEvent*)theEvent;
-(id)initWithType: (int) type andModifiers: (int) modifiers andString: (NSString *)theString forCorner: (int) corner andClicker:(Clicker *) clicker;
-(id)initWithType: (int) type andModifiers: (int) modifiers andString: (NSString *)theString forCorner: (int) corner withLabel:(NSString *) label andClicker:(Clicker *) clicker;
-(void)hideCurrentAction;
-(void)hideOthersAction;
-(int)type;
-(int)corner;
-(int)modifiers;
-(NSString *)string;
-(NSString *)label;
-(NSImage *)icon;
-(void) setString: (NSString *) string;
-(void) setLabel: (NSString *) label;
-(void) setIcon: (NSImage *) icon;
-(void) setCorner: (int) corner;
-(void) setType: (int) type;
-(void) setModifiers: (int) modifiers;

-(void)setIconAndLabelUserProvided: (NSString *) label;
@end

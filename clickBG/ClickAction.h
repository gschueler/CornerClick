/* ClickAction */

#import <Cocoa/Cocoa.h>

@interface ClickAction : NSObject
{
    NSString* myString;
    int theType;
    int theCorner;
    int theModifiers;
    NSImage *myIcon;
    NSString *myLabel;
}

- (void)doAction:(NSEvent*)theEvent;
-(id)initWithType: (int) type andModifiers: (int) modifiers andString: (NSString *)theString forCorner: (int) corner;
-(id)initWithType: (int) type andModifiers: (int) modifiers andString: (NSString *)theString forCorner: (int) corner withLabel:(NSString *) label;
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

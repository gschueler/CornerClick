/* ClickAction */

#import <Cocoa/Cocoa.h>
@class Clicker;

@interface ClickAction : NSObject <NSCopying>
{
    NSString* myString;
    int theType;
    int theCorner;
    int theModifiers;
    NSImage *myIcon;
    NSString *myLabel;
    NSString *trueLabel;
    Clicker *myClicker;
    NSAppleScript *myScript;
    NSDate *scriptLastModified;
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
- (NSString *) labelSetting;
- (void) setLabelSetting:(NSString *) label;
-(void) setString: (NSString *) string;
-(void) setLabel: (NSString *) label;
-(void) setIcon: (NSImage *) icon;
-(void) setCorner: (int) corner;
-(void) setType: (int) type;
-(void) setModifiers: (int) modifiers;

-(void)setIconAndLabelUserProvided: (NSString *) label;
- (void) runAppleScriptAction;
- (BOOL) isValid;

//static
+ (void) logAppleScriptError:(NSDictionary *) err atStep:(NSString *)step;
+ (NSString *) stringNameForActionType: (int) type;
+ (NSString *) labelNameForActionType: (int) type;
+ (BOOL) validActionType: (int) type andString: (NSString *) action;


@end

#import "ClickAction.h"
#import <Carbon/Carbon.h>

@implementation ClickAction

-(id)initWithType: (int) type andModifiers: (int) modifiers andString: (NSString *)theString forCorner: (int)corner andClicker:(Clicker *) clicker
{
    return [self initWithType:type andModifiers:  modifiers andString:theString  forCorner: corner withLabel:nil andClicker:clicker];
    
}
-(id)initWithType: (int) type andModifiers: (int) modifiers andString: (NSString *)theString forCorner: (int)corner withLabel: (NSString *)label andClicker:(Clicker *) clicker
{
    if(self=[super init]){
        myIcon=nil;
        trueLabel=nil;
        myLabel=nil;
        theCorner=corner;
        theType=type;
        theModifiers=modifiers;
        myClicker=clicker;
        if(theString != nil){
            //myString = [[NSString stringWithString:theString] retain];
            myString = [theString copy];
        }
        [self setIconAndLabelUserProvided:label];
    }
    return self;
}

-(void)setIconAndLabelUserProvided: (NSString *) label
{
    if(myLabel!=nil)
        [myLabel release];
    if(myIcon!=nil){
        NSLog(@"releasing icon: %@ retain: %d",myIcon,[myIcon retainCount]);
        [myIcon release];
    }
    if(trueLabel!=nil)
        [trueLabel release];
    myLabel=nil;
    trueLabel=nil;
    myIcon=nil;
    if(label!=nil)
        trueLabel = [label copy];
    switch(theType){
        case 0:
            if([[myString lastPathComponent] hasSuffix:@".app"]){
                myLabel = [[[myString lastPathComponent] stringByDeletingPathExtension] retain];
            }else{
                myLabel =[[myString lastPathComponent] retain];
            }
            myIcon = [[[NSWorkspace sharedWorkspace] iconForFile: myString] retain];
            break;
        case 1:
            myLabel=[[NSString stringWithString:@"Hide Current Application"] retain];

            break;
        case 2:
            myLabel=[[NSString stringWithString:@"Hide Other Applications"] retain];
            break;
        case 3:
            if(label !=nil){
                myLabel = [label copy];
            }
            else if([myString length]> 30){
                myLabel=[[NSString stringWithFormat:@"%@É",[myString substringToIndex:30]] retain];
            }else{
                myLabel=[[NSString stringWithString:myString] retain];
            }
            myIcon = [[NSImage imageNamed:@"BookmarkPreferences"] retain];
            break;
        default:
            myLabel=[[NSString stringWithString:@"?!@#"] retain];

    }
    //DEBUG(@"setIcon return");
}

- (NSString *) labelSetting
{
    return trueLabel;
}

- (void) setLabelSetting: (NSString *) label
{
    [self setIconAndLabelUserProvided:label];
}

-(int)type
{
    return theType;
}
-(int)modifiers
{
    return theModifiers;
}

-(int)corner
{
    return theCorner;
}
-(NSString *)string
{
    return myString;
}
-(NSString *)label
{
    return myLabel;
}
-(NSImage *)icon
{
    return myIcon;
}


-(void) setString: (NSString *) string
{
    [myString release];
    myString=nil;
    if(string!=nil)
        myString=[string copy];
}
-(void) setLabel: (NSString *) label
{
    [myLabel release];
    myLabel=nil;
    if(label!=nil)
        myLabel=[label copy];
}
-(void) setIcon: (NSImage *) icon
{
    [icon retain];
    [myIcon release];
    myIcon=icon;
}
-(void) setCorner: (int) corner
{
    theCorner=corner;
}
-(void) setType: (int) type
{
    theType=type;
}
-(void) setModifiers: (int) modifiers
{
    theModifiers=modifiers;
}

- (void) dealloc
{
    [myString release];
    [myLabel release];
    [myIcon release];
    [trueLabel release];
}
- (void)doAction:(NSEvent*)theEvent
{
    //NSLog(@"Do Action: %d %s",theType,[myString UTF8String]);
    switch(theType){
        case 0:
            [[NSWorkspace sharedWorkspace] openFile:myString];
            break;
        case 1:
            [self hideCurrentAction];
            break;
        case 2:
            [self hideOthersAction];
            break;
        case 3:
            [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:myString]];
            break;
        default:
            break;
    }
}

- (void) hideCurrentAction
{
    ProcessSerialNumber psn;
    OSErr err;
    err=GetFrontProcess(&psn);
    if(err==0)
        ShowHideProcess(&psn,(Boolean)NO);
}

- (void) hideOthersAction
{
    OSErr err;
    ProcessSerialNumber psn;
    ProcessSerialNumber paramPsn;
    BOOL sameanswer;
    
    err =GetFrontProcess(&psn);
    paramPsn.highLongOfPSN=0;
    paramPsn.lowLongOfPSN=0;
    err =GetNextProcess(&paramPsn);
    while(err==0 ){
        SameProcess(&paramPsn,&psn,(Boolean *)&sameanswer);
        if(sameanswer){
            
        }else{
            ShowHideProcess(&paramPsn,(Boolean)NO);
        }
        err = GetNextProcess(&paramPsn);
    }
}


+ (NSString *) stringNameForActionType: (int) type
{
    switch(type){
        case 0: return @"chosenFilePath";
        case 3: return @"chosenURL";
        default: return nil;
    }
}

+ (NSString *) labelNameForActionType: (int) type
{
    switch(type){
        case 3: return @"urlDesc";
        default: return nil;
    }
}

+ (BOOL) validActionType: (int) type andString: (NSString *) action
{
    switch(type){
        case 0:
            if(action !=nil)
                return YES;
            break;
        case 1: return YES;
        case 2: return YES;
        case 3:
            if(action !=nil && [action length]>0)
                return YES;
            break;
        default:
            return NO;
    }
    return NO;
}

- (id) copyWithZone: (NSZone *) zone
{
    ClickAction *a = [[ClickAction allocWithZone:zone] initWithType: theType andModifiers:  theModifiers andString:[myString copy] forCorner: theCorner withLabel: [trueLabel copy] andClicker:myClicker];
    return a;
}

@end

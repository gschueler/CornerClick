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
        theCorner=corner;
        theType=type;
        theModifiers=modifiers;
        myClicker=clicker;
        if(theString != nil){
            myString = [[NSString stringWithString:theString] retain];
        }
        [self setIconAndLabelUserProvided:label];
    }
    return self;
}

-(void)setIconAndLabelUserProvided: (NSString *) label
{
    [myLabel release];
    [myIcon release];
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
                myLabel = [label retain];
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
    return [[myString copy] autorelease];
}
-(NSString *)label
{
    return [[myLabel copy] autorelease];
}
-(NSImage *)icon
{
    return [[myIcon copy] autorelease];
}


-(void) setString: (NSString *) string
{
    [string retain];
    [myString release];
    myString=string;
}
-(void) setLabel: (NSString *) label
{
    [label retain];
    [myLabel release];
    myLabel=label;
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


@end

#import "ClickAction.h"
#import <Carbon/Carbon.h>

@implementation ClickAction

-(id)initWithType: (int) type andString: (NSString *)theString forCorner: (int)corner
{
    return [self initWithType:type andString:theString  forCorner: corner withLabel:nil];
    
}
-(id)initWithType: (int) type andString: (NSString *)theString forCorner: (int)corner withLabel: (NSString *)label 
{
    id me=[super init];
    if(me){
        myIcon=nil;
        theCorner=corner;
        if(theString != nil)
            myString = [[NSString stringWithString:theString] retain];
        switch(type){
            case 0:
                if([[myString lastPathComponent] hasSuffix:@".app"]){
                   myLabel = [[[myString lastPathComponent] stringByDeletingPathExtension] retain];
                }else{
                    myLabel =[[myString lastPathComponent] retain];
                }
                myIcon = [[[NSWorkspace sharedWorkspace] iconForFile: myString] retain];
                /*
                NSLog(@"init NSFileWrapper");
                temp = [[NSFileWrapper alloc] initWithPath: myString];
                if(temp!=nil){

                    NSLog(@"NSFileWrapper not nil");
                    [temp autorelease];
                    myIcon=[[temp icon] copy];
                    NSLog(@"isDirectory: %d",[temp isDirectory]);
                    NSLog(@"isSymbolicLink: %d",[temp isSymbolicLink]);
                    NSLog(@"isRegularFile: %d",[temp isRegularFile]);
                }else{
                    NSLog(@"temp failed init");
                }
                 */
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
    theType=type;
    return me;
}

-(int)type
{
    return theType;
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
    OSErr err;
    ProcessSerialNumber psn;
    err =GetFrontProcess(&psn);

    ShowHideProcess(&psn,(Boolean)NO);
    //[[NSWorkspace sharedWorkspace] hideOtherApplications];
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
            //break;
        }else{
            ShowHideProcess(&paramPsn,(Boolean)NO);
        }
        err = GetNextProcess(&paramPsn);
    }

    //[[NSWorkspace sharedWorkspace] hideOtherApplications];
}


@end

#import "ClickAction.h"
#import <Carbon/Carbon.h>

@implementation ClickAction

-(id)initWithType: (int) type andString: (NSString *)theString
{
    id me=[super init];
    if(theString!=nil){
        myString = [[NSString stringWithString:theString] retain];
    }
    theType=type;
    return me;
}

- (void) dealloc
{
    [myString release];
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

#import "ClickAction.h"
#import <Carbon/Carbon.h>

@implementation ClickAction

/*-(id)initWithType: (int) type andModifiers: (int) modifiers andString: (NSString *)theString forCorner: (int)corner andClicker:(Clicker *) clicker
{
    return [self initWithType:type andModifiers:  modifiers andString:theString  forCorner: corner withLabel:nil andClicker:clicker];
    
}
-(id)initWithType: (int) type andModifiers: (int) modifiers andString: (NSString *)theString forCorner: (int)corner withLabel: (NSString *)label andClicker:(Clicker *) clicker
{
	NSLog(@"!!!!!!!!ACCCCKKKK");
	return [self initWithType:type andModifiers:modifiers andTrigger:0
					andString:theString forCorner:corner withLabel:label
				   andClicker:clicker];
}*/

-(id)initWithType: (int) type andModifiers: (int) modifiers andTrigger: (int) trigger andString: (NSString *)theString
		forCorner: (int)corner withLabel: (NSString *)label andClicker:(Clicker *) clicker
{
    if(self=[super init]){
        myIcon=nil;
        trueLabel=nil;
        myLabel=nil;
        theCorner=corner;
        theType=type;
        theModifiers=modifiers;
        myClicker=clicker;
		theTrigger=trigger;
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
        if(DEBUG_LEVEL>0)NSLog(@"releasing icon: %@ retain: %d",myIcon,[myIcon retainCount]);
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
        case ACT_FILE:
            if(myString!=nil){
                if([[myString lastPathComponent] hasSuffix:@".app"]){
                    myLabel = [[[myString lastPathComponent] stringByDeletingPathExtension] retain];
                }else{
                    myLabel =[[myString lastPathComponent] retain];
                }
                myIcon = [[[NSWorkspace sharedWorkspace] iconForFile: myString] retain];
            }else{
                myLabel=nil;
                myIcon=nil;
            }
            break;
        case ACT_HIDE:
            myLabel=[[NSString stringWithString: LOCALIZE([NSBundle mainBundle],@"Hide Current Application") ] retain];
			myIcon = nil;//[[NSImage imageNamed:@"HideAppIcon"] retain];
            break;
        case ACT_HIDO:
            myLabel=[[NSString stringWithString: LOCALIZE([NSBundle mainBundle],@"Hide Other Applications") ] retain];
			myIcon = nil;//[[NSImage imageNamed:@"HideOthersIcon"] retain];
            break;
        case ACT_URL:
            if(label !=nil){
                myLabel = [label copy];
            }else if(myString==nil){
                myLabel=nil;
            }else if([myString length]> 30){
                myLabel=[[NSString stringWithFormat:@"%@É",[myString substringToIndex:30]] retain];
            }else{
                myLabel=[[NSString stringWithString:myString] retain];
            }
            myIcon = [[NSImage imageNamed:@"BookmarkPreferences"] retain];
            break;
        case ACT_SCPT:
            if(label !=nil){
                myLabel = [label copy];
            }
            else if( myString !=nil){
                myLabel = [[[myString lastPathComponent] stringByDeletingPathExtension] retain];
            }
            else {
                myLabel=nil;
                myIcon=nil;
            }
            
            if( myString !=nil){
                myIcon = [[[NSWorkspace sharedWorkspace] iconForFile: myString] retain];
            }
            
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
-(int) trigger
{
	return theTrigger;
}

-(void) setTrigger: (int) trigger
{
	theTrigger=trigger;
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
    [myScript release];
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
        case 4:
            [self runAppleScriptAction];
            break;
        default:
            break;
    }
}

+ (void) logAppleScriptError:(NSDictionary *) err atStep:(NSString *)step
{
    NSLog(@"Error %@ AppleScript: Message: %@, Error Number: %@, AppName: %@, BriefMessage: %@, Range:%@",step,
          [err objectForKey:@"NSAppleScriptErrorMessage"],
          [err objectForKey:@"NSAppleScriptErrorNumber"],
          [err objectForKey:@"NSAppleScriptErrorAppName"],
          [err objectForKey:@"NSAppleScriptErrorBriefMessage"],
          NSStringFromRange([[err objectForKey:@"NSAppleScriptErrorRange"] rangeValue])
          );
          
    /*

     NSAppleScriptErrorMessage
     An NSString that supplies a detailed description of the error condition.

     NSAppleScriptErrorNumber
     An NSNumber that specifies the error number.

     NSAppleScriptErrorAppName
     An NSString that specifies the name of the application that generated the error.

     NSAppleScriptErrorBriefMessage
     An NSString that provides a brief description of the error.

     NSAppleScriptErrorRange
     */
    
}

- (void) runAppleScriptAction
{
    NSDictionary *err;
    NSAppleEventDescriptor *evt;
    NSDate *modified;
    if(myScript==nil){
        scriptLastModified = [[[NSFileManager defaultManager] fileAttributesAtPath:myString traverseLink:YES] fileModificationDate];
        if(scriptLastModified==nil){
            NSLog(@"AppleScript Action: No such file:%@",myString);
            return;
        }
        [scriptLastModified retain];
        //NSLog(@"first modification:  %@",scriptLastModified);
        myScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:myString] error:&err];
    }else{
        modified = [[[NSFileManager defaultManager] fileAttributesAtPath:myString traverseLink:YES] fileModificationDate];
        //NSLog(@"check modification:  %@",modified);
        if(![modified isEqualToDate: scriptLastModified]){
            //NSLog(@"modification later");
            [scriptLastModified release];
            scriptLastModified = [modified retain];
            //script has been modified
            [myScript release];
            myScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:myString] error:&err];
            
        }
    }

    if(myScript==nil){
        [ClickAction logAppleScriptError:err atStep:@"Loading"];
        return;
    }
    if(![myScript isCompiled]){
        if(![myScript compileAndReturnError:&err]){
            [ClickAction logAppleScriptError:err atStep:@"Compiling"];
            return;
        }
    }
    evt = [myScript executeAndReturnError:&err];
    if(evt==nil){
        [ClickAction logAppleScriptError:err atStep:@"Executing"];
        return;
    }
    else{
        DEBUG(@"Applescript executed.");
    }
}

- (void) hideCurrentAction
{
    ProcessSerialNumber psn;
//    ProcessSerialNumber paramPsn;
    OSErr err;
	//NSLog(@"myClicker class: %@",[myClicker class]);
	//psn = [myClicker lastActivePSN];
	psn.highLongOfPSN==0;
	psn.lowLongOfPSN== 0;
	err = GetFrontProcess(&psn);
    if(err==0){
	}else{
		NSLog(@"error after get front process");
	}

    err=ShowHideProcess(&psn, (Boolean)NO);
    if(err==0){
	}else{
		NSLog(@"error after get front process");
	}
	//[myClicker getNextPSN];
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

- (BOOL) isValid
{
    return [ClickAction validActionType: theType andString:myString];
}


+ (NSString *) stringNameForActionType: (int) type
{
    switch(type){
        case 4:
        case 0: return @"chosenFilePath";
        case 3: return @"chosenURL";

        default: return nil;
    }
}

+ (NSString *) labelNameForActionType: (int) type
{
    switch(type){
        case 3: return @"urlDesc";
        case 4: return @"scriptDesc";
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
        case 4:
            if(action !=nil)
                return YES;
        default:
            return NO;
    }
    return NO;
}

- (id) copyWithZone: (NSZone *) zone
{
    ClickAction *a = [[ClickAction allocWithZone:zone] initWithType: theType 
													   andModifiers:  theModifiers
														 andTrigger: theTrigger
														  andString:[myString copy] 
														  forCorner: theCorner
														  withLabel: [trueLabel copy]
														 andClicker:myClicker];
    return a;
}

@end

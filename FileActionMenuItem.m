#import "FileActionMenuItem.h"

@implementation FileActionMenuItem

- (id) initWithFilePath: (NSString *) path andClickPref:(ClickBoxPref *) pref
{
    return [self initWithFilePath: path andClickPref: pref andTitle:nil];
}
- (id) initWithFilePath: (NSString *) path andClickPref:(ClickBoxPref *) pref andTitle:(NSString *) title
{
    NSString *theTitle = title;
    if(title == nil)
        theTitle=[[NSFileManager defaultManager] displayNameAtPath:path];
    if(self = [super initWithTitle:theTitle action:@selector(doAction:) keyEquivalent:@""]){
        filePath = [path copy];
        myPref = pref;
        NSImage *img = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
        [img setSize:NSMakeSize(16.0,16.0)];
        [self setImage: img];
        [self setEnabled:YES];
        [self setTarget:self];
    }
    return self;
}
- (IBAction)doAction:(id)sender
{
    [myPref setSelectedActionPath:filePath resettingScriptLabel: YES];
}

- (void) dealloc
{
    [filePath release];
    [super dealloc];
}

@end


#import "CornerClickSupport.h"
#define CC_PREF_BUNDLE_ID_STR [NSString stringWithString:@"us.vario.greg.CornerClick"]

#define WEB_SITE_URL @"http://greg.vario.us/cornerclick"
#define EMAIL_URL @"mailto:greg-cornerclick@vario.us"

#define SHIFT_MASK (1<<0)
#define OPTION_MASK (1<<1)
#define COMMAND_MASK (1<<2)
#define CONTROL_MASK (1<<3)
#define FN_MASK (1<<4)

#define MAX_CORNERS 4

#define TL_CORNER 0
#define TR_CORNER 1
#define BL_CORNER 2
#define BR_CORNER 3

#define ACT_FILE 0
#define ACT_HIDE 1
#define ACT_HIDO 2
#define ACT_URL 3
#define ACT_SCPT 4

#define DEBUG_LEVEL 0
#define DEBUG(x)	if(DEBUG_LEVEL>0)NSLog((x))
#define DEBUG_ON ( DEBUG_LEVEL > 0 ? YES : NO )

#define CC_APP_VERSION 2
#define CC_PATCH_VERSION 1

#define LOCALIZE(x,y)	[x localizedStringForKey:y value:nil table:nil]
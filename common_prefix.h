
#import "CornerClickSupport.h"
#define CC_PREF_BUNDLE_ID_STR [NSString stringWithString:@"us.vario.greg.CornerClick"]

#define SHIFT_MASK 1
#define OPTION_MASK 2
#define COMMAND_MASK 4
#define CONTROL_MASK 8

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

#define DEBUG_LEVEL 1
#define DEBUG(x)	if(DEBUG_LEVEL>0)NSLog((x))

#if DEBUG_LEVEL < 1
#define CC_APP_VERSION 2
#endif
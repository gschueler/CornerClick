
#import "CornerClickSupport.h"
#define CC_PREF_BUNDLE_ID_STR [NSString stringWithString:@"us.vario.greg.CornerClick"]

#define WEB_SITE_URL @"http://greg.vario.us/cornerclick"
#define EMAIL_URL @"mailto:greg-cornerclick@vario.us"


#define MARKETING_VERSION_STRING @"0.8.2"

#define SHIFT_MASK (1<<0)
#define OPTION_MASK (1<<1)
#define COMMAND_MASK (1<<2)
#define CONTROL_MASK (1<<3)
#define FN_MASK (1<<4)

#define MAX_CORNERS 4

#define TRIGGER_CLICK 0
#define TRIGGER_RCLCK 1
#define TRIGGER_HOVER 2

#define TL_CORNER 0
#define TR_CORNER 1
#define BL_CORNER 2
#define BR_CORNER 3

#define ACT_FILE 0
#define ACT_HIDE 1
#define ACT_HIDO 2
#define ACT_URL 3
#define ACT_SCPT 4
#define ACT_EALL 5
#define ACT_EAPP 6
#define ACT_EDES 7
#define ACT_DASH 8
#define ACT_SCRE 9

#define DEBUG_LEVEL 0
#define DEBUG2(...)  if(DEBUG_LEVEL>3)NSLog(__VA_ARGS__)
#define DEBUG(...)  if(DEBUG_LEVEL>2)NSLog(__VA_ARGS__)
#define INFO(...)  if(DEBUG_LEVEL>1)NSLog(__VA_ARGS__)
#define WARN(...)  if(DEBUG_LEVEL>0)NSLog(__VA_ARGS__)
#define ERROR(...)  if(DEBUG_LEVEL>-1)NSLog(__VA_ARGS__)
#define DEBUG_ON ( DEBUG_LEVEL > 0 ? YES : NO )
#if DEBUG_LEVEL > 3
    #define WRITE_BUBBLES
#endif

#define CC_APP_VERSION 0
#define CC_APP_MIN_VERSION 8
#define CC_PATCH_VERSION 2

#define CC_MIN_VERSION 2
#define CC_MAX_VERSION 8

#define LOCALIZE(x,y)	[x localizedStringForKey:y value:nil table:nil]
#!/bin/bash

VERS=$1

if [ -z "$VERS" ] ; then
    echo "$0 <version>"
    exit 2
fi

#apple generic version update version
echo updating to version $VERS

agvtool new-version $VERS
agvtool new-marketing-version $VERS


# grep and replace in common_prefix.h

perl  -i'.orig' -p -e "s#MARKETING_VERSION_STRING @\".+?\"#MARKETING_VERSION_STRING @\"$VERS\"#" common_prefix.h

#
# TODO update these:
#define CC_APP_VERSION 0
#define CC_APP_MIN_VERSION 9
#define CC_PATCH_VERSION 0

# grep and replace in Makefile
perl  -i'.orig' -p -e "s#^VERS=.+\$#VERS=$VERS#" Makefile

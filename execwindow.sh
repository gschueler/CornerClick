#!/bin/sh
PWD=`pwd`
DMGNAME=$1
echo hdiutil attach "$PWD/build/$DMGNAME.dmg" -readwrite
exit 0

#mount volume  \"file://$PWD/build/$DMGNAME.dmg\"
osascript -e "
set x to load script (POSIX file \"$PWD/makewindow.scpt\")

tell x to doit(\"$DMGNAME\")"

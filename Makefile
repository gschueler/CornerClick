VERS=0.4


compress:
	bin/compressimg "production/CornerClick.dmg" "build/CornerClick ${VERS}.dmg"

createdmg:
	hdiutil create "build/CornerClick ${VERS}.dmg" -srcdir dmg-source -volname "CornerClick ${VERS}"

bundle:
	./execwindow.sh "CornerClick ${VERS}"

build/CornerClick.prefPane: *.h *.m English.lproj/*
	xcodebuild

build/CornerClickBG.app: clickBG/*.m clickBG/*.h
	xcodebuild CornerClickBG

readme:
	cp English.lproj/Readme.rtf ${HOME}/Library/PreferencePanes/CornerClick.prefPane/Contents/Resources/English.lproj/
information:
	cp English.lproj/Information.rtf ${HOME}/Library/PreferencePanes/CornerClick.prefPane/Contents/Resources/English.lproj/


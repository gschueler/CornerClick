VERS=0.6


compress: 
	bin/compressimg "build/CornerClick-rw.dmg" "build/CornerClick ${VERS}.dmg"

dmg: 
	hdiutil create "build/CornerClick-rw.dmg" -srcdir dmg-source -ov -attach -format UDRW -volname "CornerClick ${VERS}"

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


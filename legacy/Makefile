VERS=0.9
CP=/Developer/Tools/CpMac
DMGSRC=dmg-source
EXPORT=export
CCEXP=${EXPORT}/CornerClick-${VERS}
LOCALIZED_XIBS=Spanish.lproj/ClickBoxPref.xib French.lproj/ClickBoxPref.xib German.lproj/ClickBoxPref.xib zh_TW.lproj/ClickBoxPref.xib

dist: 
	-rm -rf "${EXPORT}"
	-mkdir -p "${EXPORT}"
	svn export ${DMGSRC} "${CCEXP}"
	-mkdir "${CCEXP}/Uninstall"
	${CP} English.lproj/Uninstall.rtf "${CCEXP}/Uninstall/English.rtf"
	${CP} English.lproj/Readme.rtf "${CCEXP}/Readme (E).rtf"
	#${CP} French.lproj/Readme.rtf "${CCEXP}/Old Readmes/Readme (F).rtf"
	#${CP} zh_TW.lproj/Readme.rtf "${CCEXP}/Old Readmes/Readme (zh_TW).rtf"
	#${CP} Spanish.lproj/Readme.rtf "${CCEXP}/Old Readmes/Readme (Es).rtf"
	${CP} Spanish.lproj/Uninstall.rtf "${CCEXP}/Uninstall/Espanol.rtf"
	${CP} German.lproj/Deinstallieren.rtf  "${CCEXP}/Uninstall/German.rtf"
	-rm -r "${CCEXP}/CornerClick.prefPane"
	${CP} -r "build/Deployment/CornerClick.prefPane"  "${CCEXP}/"
	cd "${EXPORT}" && tar cjf "CornerClick-${VERS}.tar.bz2" "CornerClick-${VERS}"

compress: 
	bin/compressimg "build/CornerClick-rw.dmg" "build/CornerClick ${VERS}.dmg"

dmg: 
	-mkdir "${DMGSRC}/Uninstall"
	${CP} English.lproj/Uninstall.rtf "${DMGSRC}/Uninstall/English.rtf"
	${CP} English.lproj/Readme.rtf "${DMGSRC}/Readme (E).rtf"
	${CP} French.lproj/Readme.rtf "${DMGSRC}/Readme (F).rtf"
	${CP} zh_TW.lproj/Readme.rtf "${DMGSRC}/Readme (zh_TW).rtf"
	${CP} Spanish.lproj/Readme.rtf "${DMGSRC}/Readme (Es).rtf"
	${CP} Spanish.lproj/Uninstall.rtf "${DMGSRC}/Uninstall/Espanol.rtf"
	rm -r ${DMGSRC}/CornerClick.prefPane
	${CP} -r build/Deployment/CornerClick.prefPane  ${DMGSRC}/CornerClick.prefPane
	hdiutil create "build/CornerClick-rw.dmg" -srcdir ${DMGSRC} -ov -attach -format UDRW -volname "CornerClick ${VERS}"

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

trans: $(LOCALIZED_XIBS)

transbuild/ClickBoxPref.xib.English.strings: English.lproj/ClickBoxPref.xib
	ibtool --export-strings-file transbuild/ClickBoxPref.xib.English.strings English.lproj/ClickBoxPref.xib

Spanish.lproj/ClickBoxPref.xib.translated.strings: English.lproj/ClickBoxPref.xib Spanish.lproj/ClickBoxPref.strings transbuild/ClickBoxPref.xib.English.strings
	perl transbuild/transstrings.pl transbuild/ClickBoxPref.xib.English.strings Spanish.lproj/ClickBoxPref.strings Spanish.lproj/ClickBoxPref.xib.translated.strings Spanish.lproj/ClickBoxPref.xib.missing.strings

German.lproj/ClickBoxPref.xib.translated.strings: English.lproj/ClickBoxPref.xib German.lproj/ClickBoxPref.strings transbuild/ClickBoxPref.xib.English.strings
	perl transbuild/transstrings.pl transbuild/ClickBoxPref.xib.English.strings German.lproj/ClickBoxPref.strings German.lproj/ClickBoxPref.xib.translated.strings German.lproj/ClickBoxPref.xib.missing.strings

French.lproj/ClickBoxPref.xib.translated.strings: English.lproj/ClickBoxPref.xib French.lproj/ClickBoxPref.strings transbuild/ClickBoxPref.xib.English.strings
	perl transbuild/transstrings.pl transbuild/ClickBoxPref.xib.English.strings French.lproj/ClickBoxPref.strings French.lproj/ClickBoxPref.xib.translated.strings French.lproj/ClickBoxPref.xib.missing.strings

zh_TW.lproj/ClickBoxPref.xib.translated.strings: English.lproj/ClickBoxPref.xib zh_TW.lproj/ClickBoxPref.strings transbuild/ClickBoxPref.xib.English.strings
	perl transbuild/transstrings.pl transbuild/ClickBoxPref.xib.English.strings zh_TW.lproj/ClickBoxPref.strings zh_TW.lproj/ClickBoxPref.xib.translated.strings zh_TW.lproj/ClickBoxPref.xib.missing.strings

Spanish.lproj/ClickBoxPref.xib: Spanish.lproj/ClickBoxPref.xib.translated.strings
	ibtool --strings-file Spanish.lproj/ClickBoxPref.xib.translated.strings --write Spanish.lproj/ClickBoxPref.xib English.lproj/ClickBoxPref.xib

German.lproj/ClickBoxPref.xib: German.lproj/ClickBoxPref.xib.translated.strings
	ibtool --strings-file German.lproj/ClickBoxPref.xib.translated.strings --write German.lproj/ClickBoxPref.xib English.lproj/ClickBoxPref.xib

French.lproj/ClickBoxPref.xib: French.lproj/ClickBoxPref.xib.translated.strings
	ibtool --strings-file French.lproj/ClickBoxPref.xib.translated.strings --write French.lproj/ClickBoxPref.xib English.lproj/ClickBoxPref.xib

zh_TW.lproj/ClickBoxPref.xib: zh_TW.lproj/ClickBoxPref.xib.translated.strings
	ibtool --strings-file zh_TW.lproj/ClickBoxPref.xib.translated.strings --write zh_TW.lproj/ClickBoxPref.xib English.lproj/ClickBoxPref.xib

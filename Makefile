VERS=0.8.1
CP=/Developer/Tools/CpMac
DMGSRC=dmg-source
EXPORT=export
CCEXP=${EXPORT}/CornerClick-${VERS}

dist: 
	-rm -r "${EXPORT}"
	-mkdir -p "${EXPORT}"
	${CP} -r ${DMGSRC} "${CCEXP}"
	-mkdir "${CCEXP}/Uninstall"
	${CP} English.lproj/Uninstall.rtf "${CCEXP}/Uninstall/English.rtf"
	${CP} English.lproj/Readme.rtf "${CCEXP}/Readme (E).rtf"
	${CP} French.lproj/Readme.rtf "${CCEXP}/Readme (F).rtf"
	${CP} zh_TW.lproj/Readme.rtf "${CCEXP}/Readme (zh_TW).rtf"
	${CP} Spanish.lproj/Readme.rtf "${CCEXP}/Readme (Es).rtf"
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

publish:
	scp "${EXPORT}/CornerClick-${VERS}.tar.bz2" snoop.mekka-tech.com:greg.vario.us/cornerclick/

publish2:
	scp "build/CornerClick ${VERS}.dmg" mojo.vario.us:greg.vario.us/cornerclick/

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


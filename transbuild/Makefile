NIBNAME=ClickBoxPref
NIB=${NIBNAME}.nib
ORIG=English
LANG=French

French/${NIB}:
	perl makenib.pl French

strings: ../${ORIG}.lproj/${NIB} ../${LANG}.lproj/${NIBNAME}.strings
	nibtool -L ../${ORIG}.lproj/${NIB} > ${ORIG}.strings
	cp ../${LANG}.lproj/${NIBNAME}.strings ${LANG}_trans.strings
	perl mergestrings.pl ${ORIG}.strings ${LANG}_trans.strings ${LANG}_newtrans.strings
	
	

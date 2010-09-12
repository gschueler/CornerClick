NIBNAME=ClickBoxPref
NIB=${NIBNAME}.nib
ORIG=English
TLANG=French

#makenib creates a new File.nib based on File.strings in the language dir
French/${NIB}: ../French.lproj/${NIBNAME}.strings
	perl makenib.pl French

Spanish/${NIB}: ../Spanish.lproj/${NIBNAME}.strings
	perl makenib.pl Spanish


#create TLANG_newtrans.string based on base English nib and any available translated strings under TLANG.lproj/nib.strings

strings: ../${ORIG}.lproj/${NIB} ../${TLANG}.lproj/${NIBNAME}.strings
	nibtool -L ../${ORIG}.lproj/${NIB} > ${ORIG}.strings
	cp ../${TLANG}.lproj/${NIBNAME}.strings ${TLANG}_trans.strings
	perl mergestrings.pl ${ORIG}.strings ${TLANG}_trans.strings ${TLANG}_newtrans.strings
	
	

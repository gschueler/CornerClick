
index.text: Makefile index.text.template txt/*.text
	cp index.text.template index.text
	bash -c 'for i in *.text ;  do echo "* [" $${i%.text} "]($$i) " >> index.text ; done'

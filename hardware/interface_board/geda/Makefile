#PROJNAME = interface_board
#SHEETS = sheet1.sch sheet2.sch sheet3.sch sheet4.sch
#
#open: $(SHEETS)
#	gschem $(SHEETS)
#
#printpdf: $(PROJNAME).ps
#	ps2pdf -dOptimize=true -dUseFlateCompression=true -sPAPERSIZE=a4 $<
#$(PROJNAME).pdf
#
#$(PROJNAME).ps : printps
#
#printps: $(SHEETS)
#    rm -f ONEPAGE.ps
#    rm -f $(PROJNAME).ps
#    for S in $(SHEETS); \
#    do \
#    gschem -q -p -o ONEPAGE.ps -s$(HOME)/geda/share/gEDA/scheme/print.scm 
#$$S; \
#    cat ONEPAGE.ps; done > $(PROJNAME).ps
#    rm -f ONEPAGE.ps
#
#

# The following comes from
# http://logonex.eu/cgi-bin/viewvc/viewvc.cgi/pskel/

#include ../globals
PCB=pcb
#FILEBASE=${BASE}
FILEBASE=interface_board
GERB_DIR=gerber
BOMFILE=${FILEBASE}.bom.txt
XYFILE=${FILEBASE}.xy.txt

default: gerber bom pdf

gerber:
	mkdir ${GERB_DIR}
	${PCB} -x gerber --gerberfile ${GERB_DIR}/${FILEBASE} ${FILEBASE}.pcb

bom:
	${PCB} -x bom --bomfile ${BOMFILE} --xyfile ${XYFILE} ${FILEBASE}.pcb

ps:
	${PCB} -x ps --psfile ${FILEBASE}.ps ${FILEBASE}.pcb

pdf: ps
	${PS2PDF} ${FILEBASE}.ps

output_tar: gerber
	tar -jcvf ${FILEBASE}_output.tar.bz2 ${GERB_DIR}/*.gbr ${GERB_DIR}/*.cnc

output_zip: gerber
	zip -r ${FILEBASE}_output.zip ${GERB_DIR}/*.gbr ${GERB_DIR}/*.cnc

plate_all_holes:
	perl -p -i -e 's/\"hole\"/\"\"/' ${FILEBASE}.pcb

output_barebones: plate_all_holes gerber
	zip -r ${FILEBASE}_barebones_output.zip \
			${GERB_DIR}/${FILEBASE}.front.gbr \
			${GERB_DIR}/${FILEBASE}.back.gbr \
			${GERB_DIR}/${FILEBASE}.plated-drill.cnc  \
			${GERB_DIR}/${FILEBASE}.unplated-drill.cnc

clean:
	rm -rf *.gbr *.bom *.cnc *.ps *.eps *.pdf ${GERB_DIR} ${FILEBASE}_output.tar.bz2 ${FILEBASE}.pcb- ${FILEBASE}_output.zip ${FILEBASE}_barebones_output.zip ${BOMFILE} ${XYFILE}
	rm -f index.html

html: gerber ps pdf 
	echo -e "<html>\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html" >index.html
	echo -e "charset=UTF-8\">" >>index.html
	echo -e "<link rel=\"stylesheet\" href=\"../pskel.css\" type=\"text/css\">" >>index.html
	echo -e "<title>PCB data of ${FILEBASE}</title>\n</head>" >>index.html
	echo -e "<body>\n<h1>PCB data of ${FILEBASE}</h1>" >>index.html
	echo -e "<h2>PCB source</h2>\n<a href=${FILEBASE}.pcb>${FILEBASE}.pcb</a>" >>index.html
	echo -e "<h2>Gerber data</h2>" >>index.html
	for GBRFILE in *.gbr; do echo -e "<a href=$$GBRFILE>$$GBRFILE</a><br>" >>index.html; done
	for CNCFILE in *.cnc; do echo -e "<a href=$$CNCFILE>$$CNCFILE</a><br>" >>index.html; done
	echo -e "<h2>Postscript plots</h2>" >>index.html
	echo -e "<a href=${FILEBASE}.ps>${FILEBASE}.ps</a>" >>index.html
	echo -e "<h2>PDF plots</h2>" >>index.html
	echo -e "<a href=${FILEBASE}.pdf>${FILEBASE}.pdf</a>" >>index.html
	echo -e "<hr>\nGenerated on ${DATE} by pskel.\n</body>\n</html>" >>index.html


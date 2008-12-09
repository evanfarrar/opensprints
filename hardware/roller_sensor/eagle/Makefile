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
BOMFILE=${FILEBASE}.bom.txt
XYFILE=${FILEBASE}.xy.txt

default: gerber bom pdf

gerber:
	${PCB} -x gerber --gerberfile ${FILEBASE} ${FILEBASE}.pcb

bom:
	${PCB} -x bom --bomfile ${BOMFILE} --xyfile ${XYFILE} ${FILEBASE}.pcb

ps:
	${PCB} -x ps --psfile ${FILEBASE}.ps ${FILEBASE}.pcb

pdf: ps
	${PS2PDF} ${FILEBASE}.ps

output: gerber
	tar -jcvf ${FILEBASE}_output.tar.bz2 *.gbr *.cnc

output_zip_clean: gerber
	zip -r ${FILEBASE}_output.zip *.G?? *.TXT *.dri 
	rm *.gbr *.cnc

clean:
	rm -f *.G?? *.dri *.gpi *.gbr *.bom *.cnc *.ps *.eps *.pdf ${FILEBASE}_gerb.zip ${BOMFILE} ${XYFILE}


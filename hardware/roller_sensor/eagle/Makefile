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
EAGLE=eagle
#FILEBASE=${BASE}
FILEBASE=roller_sensor
BOMFILE=${FILEBASE}.bom.txt
XYFILE=${FILEBASE}.xy.txt

default: gerber bom pdf

gerber:
	${PCB} -x gerber --gerberfile ${FILEBASE} ${FILEBASE}.pcb
	#create our gerber files! this comes from http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1191638084
	echo "Creating Gerber Files..."
	${EAGLE} -X -N -d GERBER_RS274X -o "$TO_DIR/gerber/ComponentTraces.pho" $BOARD/*.brd Top Pads Vias
	${EAGLE} -X -N -d GERBER_RS274X -o "$TO_DIR/gerber/CopperTraces.pho" $BOARD/*.brd Bottom Pads Vias
	${EAGLE} -X -N -d GERBER_RS274X -o "$TO_DIR/gerber/SolderMaskComponent.pho" $BOARD/*.brd tStop
	${EAGLE} -X -N -d GERBER_RS274X -o "$TO_DIR/gerber/SolderMaskCopper.pho" $BOARD/*.brd bStop
	${EAGLE} -X -N -d GERBER_RS274X -o "$TO_DIR/gerber/SilkScreen.pho" $BOARD/*.brd Dimension tPlace tDocu

# Drill data for NC drill st.
# warning : eagle takes path of -R option from input file directory.
	${EAGLE} -X -N -d EXCELLON -E -0.02 -E 0.1 -R ${BOARD}.drl -o $TO_DIR/gerber/${BOARD}.drd ${BOARD}/*.brd Drills Holes
	cp $BOARD/*.drl $TO_DIR/gerber 

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
	rm -rf gerber *.l#? *.b#? *.s#? *.pho *.G?? *.dri *.gpi *.gbr *.bom *.cnc *.ps *.eps *.pdf ${FILEBASE}_gerb.zip ${BOMFILE} ${XYFILE}


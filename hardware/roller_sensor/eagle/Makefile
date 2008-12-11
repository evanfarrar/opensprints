# The following comes from
# http://logonex.eu/cgi-bin/viewvc/viewvc.cgi/pskel/

EAGLE=eagle
FILEBASE=roller_sensor


all: clean default

default: gerber pdf output

# TODO: automate the generation of a drill file. the command from within the PCB editor is run drillcfg.
# should I choose mm or in?

# TODO: be able to handle multiple schematic sheets.

gerber:
	mkdir gerber
	${PCB} -x gerber --gerberfile ${FILEBASE} ${FILEBASE}.pcb
	#create our gerber files! this comes from http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1191638084
	echo "Creating Gerber Files..."
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/ComponentTraces.pho" *.brd Top Pads Vias
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/CopperTraces.pho" *.brd Bottom Pads Vias
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/SolderMaskComponent.pho" *.brd tStop
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/SolderMaskCopper.pho" *.brd bStop
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/SilkScreen.pho" *.brd Dimension tPlace tDocu
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/Dimensions.pho" *.brd Dimension

# Drill data for NC drill st.
# warning : eagle takes path of -R option from input file directory.
	${EAGLE} -X -N -d EXCELLON -E -0.02 -E 0.1 -R ${FILEBASE}.drl -o gerber/${FILEBASE}.drd *.brd Drills Holes

# finish this:
pdf:
	echo "Creating PS Files..."
	${EAGLE} -X -N -d PS -o "Schematic.ps" ${FILEBASE}.sch Nets Busses Symbols Names Values
	${EAGLE} -X -N -d PS -o "ComponentTraces.ps" ${FILEBASE}.brd Top Pad Via Dimension
	${EAGLE} -X -N -d PS -o "ComponentSilkscreen.ps" ${FILEBASE}.brd Pad Via Dimension tPlace tNames tValues
	${EAGLE} -X -N -d PS -o "CopperTraces.ps" ${FILEBASE}.brd Bottom Pad Via Dimension 
	${EAGLE} -X -N -d PS -o "CopperSilkscreen.ps" ${FILEBASE}.brd Pad Via Dimension bPlace bNames

#convert to pdf...
#	echo "Converting to PDF..."
#	for PS in *.ps
#	do
#		TO_FILE=`basename $PS .ps`.pdf
#			ps2pdf $PS $TO_DIR/pdf/$TO_FILE
#			done
#			rm $TO_DIR/pdf/*.ps

# this doesn't work:
pdf:
	${EAGLE} -C"print file ${FILEBASE}_brd.pdf;quit;" ${FILEBASE}.brd
	${EAGLE} -C"print rotate file ${FILEBASE}_sch.pdf;quit;" ${FILEBASE}.sch
	
output: gerber
	zip -r ${FILEBASE}_gerber.zip gerber/*

output_barebones: gerber
	zip -r ${FILEBASE}_barebones_gerber.zip gerber/ComponentTraces.pho gerber/CopperTraces.pho gerber/roller_sensor.drd gerber/Dimensions.pho
	
clean:
	rm -rf gerber *.l#? *.b#? *.s#? *.pho *.G?? *.dri *.gpi *.gbr *.bom *.cnc *.ps *.eps *.pdf ${FILEBASE}_gerber.zip ${BOMFILE} ${XYFILE}


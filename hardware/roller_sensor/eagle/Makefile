# The following comes from
# http://logonex.eu/cgi-bin/viewvc/viewvc.cgi/pskel/

EAGLE=eagle
PROJECT=roller_sensor
LAYERS=2

all: clean default

default: gerber pdf output


# TODO: be able to handle multiple schematic sheets.

gerber:
	mkdir gerber
#	${PCB} -x gerber --gerberfile ${PROJECT} ${PROJECT}.pcb
	# Create the gerber files. This comes from http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1191638084
	echo "Creating Gerber Files..."
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/TopCopper.pho" *.brd Top Pads Vias
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/BottomCopper.pho" *.brd Bottom Pads Vias
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/TopSolderMask.pho" *.brd tStop
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/BottomSolderMask.pho" *.brd bStop
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/TopSilkScreen.pho" *.brd Dimension tPlace tDocu
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/BottomSilkScreen.pho" *.brd Dimension bPlace bDocu
	${EAGLE} -X -N -d GERBER_RS274X -o "gerber/Dimensions.pho" *.brd Dimension
	# Loop through the following lines to produce the gerber files for the inner layers:
	# @@@
	# Clean out info files:
#rm gerber/*.gpi

# Drill data for NC drill file.
# TODO: automate the generation of a drill file. 
# Before using this script, The following command must be run from within the 
# PCB editor. Save the output as ${PROJECT}.drl
#		run drillcfg
	${EAGLE} -X -N -d EXCELLON -E -0.02 -E 0.1 -R ${PROJECT}.drl -o gerber/${PROJECT}.drd *.brd Drills Holes

# finish this:
pdf:
	mkdir pdf
	echo "Creating PS Files..."
	${EAGLE} -X -N -d PS -o "pdf/Schematic.ps" ${PROJECT}.sch Nets Busses Symbols Names Values
	${EAGLE} -X -N -d PS -o "pdf/TopCopper.ps" ${PROJECT}.brd Top Pad Via Dimension
	${EAGLE} -X -N -d PS -o "pdf/BottomCopper.ps" ${PROJECT}.brd Bottom Pad Via Dimension
	${EAGLE} -X -N -d PS -o "pdf/TopSilkScreen.ps" ${PROJECT}.brd Pad Via Dimension tPlace tNames tValues
	${EAGLE} -X -N -d PS -o "pdf/BottomSilkScreen.ps" ${PROJECT}.brd Pad Via Dimension bPlace bNames bValues
	# Loop through the following lines to produce the pdf files for the inner layers:
	# @@@
#convert to pdf...
	echo "Converting to PDF..."
	for PS in pdf/*.ps
	do
		TO_FILE=
		ps2pdf $PS pdf/`basename $PS .ps`.pdf
	done
#	rm pdf/*.ps

output: gerber
	zip -r ${PROJECT}_gerber_complete.zip gerber/*

output_barebones: gerber
	zip -r ${PROJECT}_gerber_barebones.zip \
	gerber/TopCopper.pho \
	gerber/BottomCopper.pho \
	gerber/Dimensions.pho \
	gerber/${PROJECT}.drd
	
clean:
	rm -rf gerber *.l#? *.b#? *.s#? *.pho *.G?? *.dri *.gpi *.gbr *.bom *.cnc *.ps *.eps *.pdf \
		${PROJECT}_gerber_complete.zip \
		${PROJECT}_gerber_barebones.zip \


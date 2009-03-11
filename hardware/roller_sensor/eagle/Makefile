EAGLE=eagle
PROJECT=roller_sensor
LAYERS=2
GERB_DIR=gerber
DRAWINGS_DIR=drawings

all: clean default

default: gerber drawings output

gerber:
	mkdir ${GERB_DIR}
	# Create the gerber files. This comes from http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1191638084
	${EAGLE} -X -N -d GERBER_RS274X -o "${GERB_DIR}/TopCopper.pho" *.brd Top Pads Vias
	${EAGLE} -X -N -d GERBER_RS274X -o "${GERB_DIR}/BottomCopper.pho" *.brd Bottom Pads Vias
	${EAGLE} -X -N -d GERBER_RS274X -o "${GERB_DIR}/TopSolderMask.pho" *.brd tStop
	${EAGLE} -X -N -d GERBER_RS274X -o "${GERB_DIR}/BottomSolderMask.pho" *.brd bStop
	${EAGLE} -X -N -d GERBER_RS274X -o "${GERB_DIR}/TopSilkScreen.pho" *.brd Dimension tPlace tDocu
	${EAGLE} -X -N -d GERBER_RS274X -o "${GERB_DIR}/BottomSilkScreen.pho" *.brd Dimension bPlace bDocu
	${EAGLE} -X -N -d GERBER_RS274X -o "${GERB_DIR}/Dimensions.pho" *.brd Dimension
	# TODO: Loop through the following lines to produce the gerber files for the inner layers:
	# @@@
# Drill data for NC drill file.
# TODO: automate the generation of a drill file. 
# Before using this script, The following command must be run from within the 
# PCB editor. Save the output as ${PROJECT}.drl
#		run drillcfg
	${EAGLE} -X -N -d EXCELLON -E -0.02 -E 0.1 -R ${PROJECT}.drl -o ${GERB_DIR}/${PROJECT}.drd *.brd Drills Holes
	# Clean out info files:
	rm ${GERB_DIR}/*.dri ${GERB_DIR}/*.gpi


drawings_ps:
	mkdir ${DRAWINGS_DIR}
	${EAGLE} -X -N -d PS -o "${DRAWINGS_DIR}/${PROJECT}_schem.ps" ${PROJECT}.sch Nets Busses Symbols Names Values
	${EAGLE} -X -N -d PS -o "${DRAWINGS_DIR}/${PROJECT}_pcb_top.ps" ${PROJECT}.brd Top Pad Via Dimension tPlace tNames tValues
	${EAGLE} -X -N -d PS -o "${DRAWINGS_DIR}/${PROJECT}_pcb_bottom.ps" ${PROJECT}.brd Bottom Pad Via Dimension bPlace bNames bValues
	# TODO: Loop through the following lines to produce the pdf files for the inner layers:
	# @@@

drawings: drawings_ps
	# TODO: convert each *.ps in in the drawings dir to pdf then delete the .ps files.

output: gerber
	zip -r ${PROJECT}_gerber_complete_output.zip ${GERB_DIR}/*

output_barebones: gerber
	zip -r ${PROJECT}_gerber_barebones_output.zip \
	${GERB_DIR}/TopCopper.pho \
	${GERB_DIR}/BottomCopper.pho \
	${GERB_DIR}/Dimensions.pho \
	${GERB_DIR}/${PROJECT}.drd
	
output_batchpcb: output
	cp ${GERB_DIR}/* .
	zip ${PROJECT}_gerber_batchpcb_output.zip *.pho *.drd
	rm *.pho *.drd

clean:
	rm -rf *.l#? *.b#? *.s#? \
		${GERB_DIR} ${DRAWINGS_DIR} \
		${PROJECT}_gerber_complete_output.zip \
		${PROJECT}_gerber_barebones_output.zip \


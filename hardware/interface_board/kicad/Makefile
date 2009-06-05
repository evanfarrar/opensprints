FILEBASE=interface_board

gerber:
	echo "Open PCBnew and plot the gerber files and generate the drill report."

output_tar: gerber
	tar -jcvf ${FILEBASE}_output.tar.bz2 *.pho *.drl *-drl.rpt

output_zip: gerber
	zip -r ${FILEBASE}_output.zip *.pho *.drl *-drl.rpt

output_barebones: gerber
	zip -r ${FILEBASE}_barebones_output.zip \
			${FILEBASE}-Component.pho \
			${FILEBASE}-Copper.pho \
			${FILEBASE}-Edges_Pcb.pho \
			${FILEBASE}.drl

clean:
	rm -f *.bak
	rm -f *.cache.dcm
	rm -f *.cache.lib
	rm -f *.bck
	rm -f *.0??
	rm -f ?savepcb.brd
	rm -f *.rpt
	rm -f *.pho
	rm -f *.drl
	rm -f *_output.zip
	rm -f *_output_barebones.zip

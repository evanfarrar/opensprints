#!/bin/bash

#########################################################################
#
# usage: ./eagle_package_release board_name [version]
#
# running this script will generate an electronics release file suitable for release on sourceforge and for production use.
# it will produce the following files in a .zip file:
# 
# * gerber
# * postscript
# * pdf
# * png
# * povray render
#
# installation / required tools:
#
# this script is for linux.  recommend using Ubuntu.
#
# *eagle*
# you must have eagle in your path somewhere.  we recommend using the latest version
# download here: http://www.cadsoft.de/download.htm
# (dont forget to add it to your $PATH in ~/.bashrc)
# 
# *povray*
# this is the 3D rendering engine.  its pretty easy to install:
# sudo apt-get install povray povray-includes
#
#########################################################################

#init up
BOARD=roller_sensor

#directory structure
echo "Making Files..."
mkdir -p "gerber"

#export drill rack
eagle -C"drillcfg.ulp;" ${BOARD}

#create our gerber files!
echo "Creating Gerber Files..."
eagle -X -N -d GERBER_RS274X -o "gerber/ComponentTraces.pho" *.brd Top Pads Vias
eagle -X -N -d GERBER_RS274X -o "gerber/CopperTraces.pho" *.brd Bottom Pads Vias
eagle -X -N -d GERBER_RS274X -o "gerber/SolderMaskComponent.pho" *.brd tStop
eagle -X -N -d GERBER_RS274X -o "gerber/SolderMaskCopper.pho" *.brd bStop
eagle -X -N -d GERBER_RS274X -o "gerber/SilkScreen.pho" *.brd Dimension tPlace tDocu tValues tNames

# Drill data for NC drill st.
# warning : eagle takes path of -R option from input file directory.
#eagle -X -N -d EXCELLON  *.brd Drills Holes
#eagle -X -N -d EXCELLON -o gerber/${BOARD}.drl.TXT *.brd Drills Holes
eagle -X -N -d EXCELLON -E -0.02 -E 0.1 -o gerber/${BOARD}.drd *.brd Drills Holes
#mv *.drl gerber 

#clean up the process
rm -rf gerber/*.gpi 

#archive the gerbers
zip ${BOARD}_gerber.zip gerber/*

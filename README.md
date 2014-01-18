Prime_pillar-post-processor
=========================

Works with KISSlicer and Cura gcode files with the comments enabled.

Add a prime pillar and delay for printing small objects to Cura and Kisslicer gcode

The script is written in lua so you will need lua installed or an executable copy in the same folder as the script 
and the slicer. 

To use with Kisslicer you will also need to add the following to the post-process field in the firmware tab of Kisslicer.
`lua "Prime_pillar.lua" " <FILE> "`

To use with Cura you will have to run it as a seperate process from the command line with the following command.
`lua "Prime_pillar.lua" "example.gcode"`

At the top of the script file you will see where the variables are set

Note: The script creates a second gcode file marked processed.


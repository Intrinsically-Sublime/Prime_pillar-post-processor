-- Prime_pillar.lua
-- By Sublime 2014 https://github.com/Intrinsically-Sublime
-- Add a prime pillar and delay for printing small objects

-- Licence:  GPL v3
-- This library is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-->>>>>>>>>>>>>>>>>>>>>>>>>> START USER SETTINGS <<<<<<<<<<<<<<<<<<<<<<<<<<--
-----------------------------------------------------------------------------

-- Filament diameter set in the slicer (mm)
SLICE_DIAMETER = 3

-- Layer height used to slice (mm)
LAYER_HEIGHT = 0.2

-- Nozzle diameter (mm)
NOZZLE_DIA = 0.5

-- Retraction distance (mm)
DISTANCE = 2

-- Tool change retraction speed
R_SPEED = 1800 -- In mm/m (1800mm/m = 30mm/s)

-- Print speed
P_SPEED = 1800 -- In mm/m (1800mm/m = 30mm/s)

-- Travel speed
T_SPEED = 6000 -- In mm/m (6000mm/m = 100mm/s)

-- Pause for x seconds then print prime pillar and return to printing (ZERO will disable)
SECONDS = 2

-- If using Cura then set to true. If using Kisslicer then set to false
CURA = false

-- Extrusion mode (Absolute E because Cura does not support Relative or use ABS_2_REL post processor first https://github.com/Intrinsically-Sublime/ABS_2_REL )
ABSOLUTE_E = true

-- Prime pillar location
PPL_X = 10
PPL_Y = 10

-- Prime pillar size (Will be centred at the prime pillar location)(Minimum size is 4mm)
P_SIZE_X = 10
P_SIZE_Y = 10

-----------------------------------------------------------------------------
-->>>>>>>>>>>>>>>>>>>>>>>>>>> END USER SETTINGS <<<<<<<<<<<<<<<<<<<<<<<<<<<--
-----------------------------------------------------------------------------

-- open files
collectgarbage()  -- ensure unused files are closed
local fin = assert( io.open( arg[1] ) ) -- reading
local fout = assert( io.open( arg[1] .. ".processed", "wb" ) ) -- writing must be binary

SLICE_AREA = (3.14159*((SLICE_DIAMETER*0.5)*(SLICE_DIAMETER*0.5)))

LAYER = 0
LAST_E = 0

function RETRACT()
	if ABSOLUTE_E then
		local E = LAST_E - DISTANCE
		fout:write("G1 F" , R_SPEED , " E" , E , "\r\n")
	else
		fout:write("G1 F" , R_SPEED , " E-" , DISTANCE , "\r\n")
	end
end

function UN_RETRACT()
	if ABSOLUTE_E then
		local E = LAST_E - DISTANCE
		fout:write("G92 E" , E , "\r\n")
		fout:write("G1 F" , R_SPEED , " E" , LAST_E , "\r\n")
	else
		fout:write("G1 F" , R_SPEED , " E" , DISTANCE , "\r\n")
	end
end

function LINE_OUT(line)
	fout:write(";\r\n" .. line .. "\r\n")
end

function WAIT() -- G4  - Dwell S<seconds> or P<milliseconds>
	if SECONDS > 0 then
		fout:write(";\r\n;Pause for " .. SECONDS .. " seconds \r\n")
		fout:write("G4 S" , SECONDS , "\r\n")
	end
end

function GO_TO_PPL()
	fout:write(";\r\n;Go to prime pillar location \r\n")
	fout:write("G0 F" , T_SPEED , " X" , PPL_X , " Y" , PPL_Y , "\r\n")
end

function GO_TO_LAST()
	fout:write(";\r\n;Go to last print location \r\n")
	fout:write("G0 F" , T_SPEED , " X" , LAST_X , " Y" , LAST_Y , "\r\n")
end

function DRAW_PILLAR()

	fout:write(";\r\n;Prime pillar \r\n")
	UN_RETRACT()
	ABS_E = LAST_E
	fout:write("G0 F" , T_SPEED , " X" , PPL_X , " Y" , PPL_Y , "\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X + (P_SIZE_X*0.125)) , " E" , E_LENGTH(P_SIZE_X*0.250) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y + (P_SIZE_Y*0.125)) , " E" , E_LENGTH(P_SIZE_Y*0.250) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X - (P_SIZE_X*0.125)) , " E" , E_LENGTH(P_SIZE_X*0.250) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y - (P_SIZE_Y*0.125)) , " E" , E_LENGTH(P_SIZE_Y*0.250) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X + (P_SIZE_X*0.250)) , " E" , E_LENGTH(P_SIZE_X*0.375) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y + (P_SIZE_Y*0.250)) , " E" , E_LENGTH(P_SIZE_Y*0.375) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X - (P_SIZE_X*0.250)) , " E" , E_LENGTH(P_SIZE_X*0.500) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y - (P_SIZE_Y*0.250)) , " E" , E_LENGTH(P_SIZE_Y*0.500) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X + (P_SIZE_X*0.375)) , " E" , E_LENGTH(P_SIZE_X*0.625) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y + (P_SIZE_Y*0.375)) , " E" , E_LENGTH(P_SIZE_Y*0.625) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X - (P_SIZE_X*0.375)) , " E" , E_LENGTH(P_SIZE_X*0.750) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y - (P_SIZE_Y*0.375)) , " E" , E_LENGTH(P_SIZE_Y*0.750) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X + (P_SIZE_X*0.500)) , " E" , E_LENGTH(P_SIZE_X*0.875) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y + (P_SIZE_Y*0.500)) , " E" , E_LENGTH(P_SIZE_Y*0.875) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X - (P_SIZE_X*0.500)) , " E" , E_LENGTH(P_SIZE_X) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y - (P_SIZE_Y*0.500)) , " E" , E_LENGTH(P_SIZE_Y) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X + (P_SIZE_X*0.500)) , " E" , E_LENGTH(P_SIZE_X) ,"\r\n")
	if ABSOLUTE_E then
		fout:write("G92 E" , LAST_E , "\r\n")
	end
	RETRACT(R)
	fout:write("G0 F" , T_SPEED , " X" , PPL_X , " Y" , PPL_Y , "\r\n")
end

function E_LENGTH(length) -- Width, Length

	local new_length = ((NOZZLE_DIA*1.1)*length*LAYER_HEIGHT)/SLICE_AREA
	local rounded_L = math.floor((new_length*10000)+0.5)*0.0001
	
	if ABSOLUTE_E then
		ABS_E = ABS_E + rounded_L
		return ABS_E
	else
		return rounded_L
	end
end

function PILLAR(line)
	RETRACT(LAST_RETRACT)
	GO_TO_PPL()
	WAIT()	
	DRAW_PILLAR()
	GO_TO_LAST()
	UN_RETRACT(LAST_RETRACT)
	LINE_OUT(line)
end

-- read lines
for line in fin:lines() do
	
	-- Record X position
	local X = string.match(line, "X%d+%.%d+")
	if X then
		LAST_X = string.match(X, "%d+%.%d+")
	end
	
	-- Record Y position
	local Y = string.match(line, "Y%d+%.%d+")
	if Y then
		LAST_Y = string.match(Y, "%d+%.%d+")
	end
	
	local layer = string.match(line, ";LAYER:") or string.match(line, "; BEGIN_LAYER")
	if layer then
		LAYER = LAYER + 1
	end
	
	-- Record E value for ABSOLUTE_E
	if  ABSOLUTE_E then
		local E = string.match(line, "E%d+%.%d+")
		if E then
			LAST_E = string.match(E, "%d+%.%d+")
		end
	end
	
	local g92_E0 = line.match(line, "G92 E0")
	if g92_E0 then
		LAST_E = 0
	end

	-- Generate prime pillar at the end of each layer.
	if LAYER ~= LAST_LAYER and LAYER > 1 then
		PILLAR(line)
		
	else
		if CURA then
		        fout:write( line .. "\r\n" )
		else
		        fout:write( line)
		end
	end
	
	LAST_LAYER = LAYER
end

-- done
fin:close()
fout:close()
print "done"

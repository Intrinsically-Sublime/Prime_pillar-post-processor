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

-- Extrusion mode (Absolute E because Cura does not support Relative or use ABS_2_REL post processor first https://github.com/Intrinsically-Sublime/ABS_2_REL )
ABSOLUTE_E = true

-- Prime pillar location
PPL_X = 10
PPL_Y = 10

-- Prime pillar size (Will be centred at the prime pillar location)(Minimum size is 4mm)
P_SIZE_X = 10
P_SIZE_Y = 10

-- Prime pillar raft inflation (Raft will be this many mm larger than the prime pillar)
RAFT_INFLATE = 2

-- Raft extrusion in percent
RAFT_GAIN = 110

-- Raft line spacing
RAFT_SPACING = 2

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

-- Creates arrays of Prime Pillar Points (X and Y coordinates)
Get_PPP_X = {[0]=P_SIZE_X}
Get_PPP_Y = {[0]=P_SIZE_Y}
for i=1, 7 do
	Get_PPP_X[i] = P_SIZE_X*(i*0.125)
	Get_PPP_Y[i] = P_SIZE_Y*(i*0.125)
end

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

function WAIT() -- Dwell S<seconds> or P<milliseconds>
	if SECONDS > 0 then
		fout:write(";\r\n;Pause for " .. SECONDS .. " seconds \r\n")
		fout:write("G4 S" , SECONDS , "\r\n")
	end
end

function SET_FLOW(flow)
	fout:write("M221 S" .. flow .. "\r\n")
end

function GO_TO_PPL()
	fout:write(";\r\n;Go to prime pillar location \r\n")
	TRAVEL(PPL_X,PPL_Y)
end

function GO_TO_LAST()
	fout:write(";\r\n;Go to last print location \r\n")
	TRAVEL(LAST_X,LAST_Y)
end

function TRAVEL(X,Y)
	fout:write("G0 F" , T_SPEED , " X" , X , " Y" , Y , "\r\n")
	DRAW_X = X
	DRAW_Y = Y
end

function DRAW_LINE(X,Y)
	E = E_LENGTH(PATH_LENGTH(X,Y))
	fout:write("G1 F" , P_SPEED , " X" , X , " Y" , Y , " E" , E , "\r\n")
	DRAW_X = X
	DRAW_Y = Y
end
-- Calculate path length
function PATH_LENGTH(X,Y)
	X = X-DRAW_X
	Y = Y-DRAW_Y
	return math.sqrt((X*X)+(Y*Y))
end

-- Calculate Raft size
R_SIZE_X = P_SIZE_X+(RAFT_INFLATE*2)
R_SIZE_Y = P_SIZE_Y+(RAFT_INFLATE*2)
-- Calculate Raft min and max locations on X and Y
R_MIN_X = PPL_X-(R_SIZE_X/2)
R_MAX_X = R_MIN_X+R_SIZE_X
R_MIN_Y = PPL_Y-(R_SIZE_Y/2)
R_MAX_Y = R_MIN_Y+R_SIZE_Y
-- Calculate the distance between paths
R_SPACES = (NOZZLE_DIA*1.1)*RAFT_SPACING
R_X_STEP = R_SIZE_X/(math.floor(R_SIZE_X/R_SPACES))
R_Y_STEP = R_SIZE_Y/(math.floor(R_SIZE_Y/R_SPACES))
R_X_COUNT = R_SIZE_X/R_X_STEP
R_Y_COUNT = R_SIZE_Y/R_Y_STEP
RP_COUNT = (R_X_COUNT+R_Y_COUNT)*2

-- Creates arrays of Raft Points (X and Y coordinates)
Get_RP_X = {}
Get_RP_Y = {}
for i=1, RP_COUNT do
	if i <= R_Y_COUNT then 
		value_1 = R_MIN_X
		value_2 = R_MIN_Y+(R_Y_STEP*i)
	elseif i > R_Y_COUNT and i <= (R_Y_COUNT+R_X_COUNT) then
		value_1 = R_MIN_X+(R_X_STEP*(i-R_Y_COUNT))
		value_2 = R_MAX_Y
	elseif i > (R_Y_COUNT+R_X_COUNT) and i <= ((R_Y_COUNT*2)+R_X_COUNT) then
		value_1 = R_MAX_X
		value_2 = R_MAX_Y-(R_Y_STEP*(i-(R_X_COUNT+R_Y_COUNT)))
	else 
		value_1 = R_MAX_X-(R_X_STEP*(i-((R_Y_COUNT*2)+R_X_COUNT)))
		value_2 = R_MIN_Y
	end
	Get_RP_X[i] = math.floor((value_1*10000)+0.5)*0.0001
	Get_RP_Y[i] = math.floor((value_2*10000)+0.5)*0.0001
end

function DRAW_RAFT(line)

	fout:write(";\r\n;Prime pillar raft \r\n")
	UN_RETRACT()
	ABS_E = LAST_E
	TRAVEL(R_MIN_X,R_MIN_Y)
	SET_FLOW(RAFT_GAIN)
	DRAW_LINE(R_MIN_X,R_MAX_Y)
	DRAW_LINE(R_MAX_X,R_MAX_Y)
	DRAW_LINE(R_MAX_X,R_MIN_Y)
	DRAW_LINE(R_MIN_X,R_MIN_Y)
	for i=1, RP_COUNT do
		DRAW_LINE(Get_RP_X[i],Get_RP_Y[i])
		DRAW_LINE(Get_RP_X[RP_COUNT-(i-1)],Get_RP_Y[RP_COUNT-(i-1)])
	end
	SET_FLOW(100)
	if ABSOLUTE_E then
		fout:write("G92 E" , LAST_E , "\r\n")
	end
	RETRACT()
	LINE_OUT(line)
end

function DRAW_PILLAR()

	fout:write(";\r\n;Prime pillar \r\n")
	UN_RETRACT()
	ABS_E = LAST_E
	DRAW_LINE(PPL_X+Get_PPP_X[1],Get_PPP_Y[0])
	DRAW_LINE(PPL_X+Get_PPP_X[1],PPL_Y+Get_PPP_Y[1])
	DRAW_LINE(PPL_X-Get_PPP_X[1],PPL_Y+Get_PPP_Y[1])
	DRAW_LINE(PPL_X-Get_PPP_X[1],PPL_Y-Get_PPP_Y[1])
	DRAW_LINE(PPL_X+Get_PPP_X[2],PPL_Y-Get_PPP_Y[1])
	DRAW_LINE(PPL_X+Get_PPP_X[2],PPL_Y+Get_PPP_Y[2])
	DRAW_LINE(PPL_X-Get_PPP_X[2],PPL_Y+Get_PPP_Y[2])
	DRAW_LINE(PPL_X-Get_PPP_X[2],PPL_Y-Get_PPP_Y[2])
	DRAW_LINE(PPL_X+Get_PPP_X[3],PPL_Y-Get_PPP_Y[2])
	DRAW_LINE(PPL_X+Get_PPP_X[3],PPL_Y+Get_PPP_Y[3])
	DRAW_LINE(PPL_X-Get_PPP_X[3],PPL_Y+Get_PPP_Y[3])
	DRAW_LINE(PPL_X-Get_PPP_X[3],PPL_Y-Get_PPP_Y[3])
	DRAW_LINE(PPL_X+Get_PPP_X[4],PPL_Y-Get_PPP_Y[3])
	DRAW_LINE(PPL_X+Get_PPP_X[4],PPL_Y+Get_PPP_Y[4])
	DRAW_LINE(PPL_X-Get_PPP_X[4],PPL_Y+Get_PPP_Y[4])
	DRAW_LINE(PPL_X-Get_PPP_X[4],PPL_Y-Get_PPP_Y[4])
	DRAW_LINE(PPL_X+Get_PPP_X[4],PPL_Y-Get_PPP_Y[4])
	if ABSOLUTE_E then
		fout:write("G92 E" , LAST_E , "\r\n")
	end
	RETRACT()
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
	RETRACT()
	GO_TO_PPL()
	WAIT()	
	DRAW_PILLAR()
	GO_TO_LAST()
	UN_RETRACT()
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
	if LAYER ~= LAST_LAYER and LAYER > 2 then
		PILLAR(line)
	elseif LAYER ~= LAST_LAYER and LAYER == 2 then
		DRAW_RAFT(line)
	else
		fout:write( line .. "\n" )
	end
	
	LAST_LAYER = LAYER
end

-- done
fin:close()
fout:close()
print "done"

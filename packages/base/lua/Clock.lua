-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

Clock_ = {
	type_ = "Clock",
  
	--- Save a Clock into a file. Supported extensions are bmp, jpg, png, and tiff.
	-- @arg file A string with the file name.
	-- @usage timer = Timer{
	--     Event{action = function() end}
	-- }
	-- 
	-- clock = Clock{target = timer}
	--
	-- clock:save("file.bmp")
	-- rmFile("file.bmp")
	save = function(self, file)
		local _, extension = string.match(file, "(.-)([^%.]+)$")

		local availableExtensions = {bmp = true, jpg = true, png = true, tiff = true}

		if not availableExtensions[extension] then
			invalidFileExtensionError(1, extension)
		end

		extension = string.upper(extension)

		self.cObj_:save(file, extension)
	end,
	--- Update the Clock with the latest values of its target. It is usually recommended
    -- to use the Clock as action of an Event instead of calling this function explicitly.
	-- @usage timer = Timer{
	--     Event{action = function() end}
	-- }
	-- 
	-- clock = Clock{target = timer}
	--
	-- clock:update()
	update = function(self)
		self.target:notify()
	end
}

metaTableClock_ = {__index = Clock_}

--- Create a display with the current time and Event queue of a given Timer.
-- @arg data.target A Timer.
-- @usage timer = Timer{
--     Event{action = function() end},
--     Event{period = 2, action = function() end}
-- }
-- 
-- Clock{target = timer}
--
-- timer:run(3)
-- timer:notify()
Clock = function(data)
	verifyNamedTable(data)
	verifyUnnecessaryArguments(data, {"target"})

	mandatoryTableArgument(data, "target", "Timer")

	local observerAttrs = {}
	local observerParams = {"", ""}
	local observerType = 8
	local id
	local obs

	id, obs = data.target.cObj_:createObserver(observerType, observerAttrs, observerParams)
  
	local clock = TeTimer()
	clock:setObserver(obs)

	data.cObj_ = clock
	data.id = id

	setmetatable(data, metaTableClock_)  

	table.insert(_Gtme.createdObservers, data)
  
	return data
end


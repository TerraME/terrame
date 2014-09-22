Pair_ = {
	-- @RODRIGO
	-- ESSE TYPE PRECISA REVISAO
	-- IMPLICA EM FALHA DO TIMER, EVENT  
	--type_ = "Pair", 
	notify = function(self, modelTime)
		if (modelTime == nil) or (type(modelTime) ~= 'number') then 
			modelTime = 0
		end
		if (type(self.cObj_[1]) == 'userdata') then
			self.cObj_[1]:notify(modelTime)
		end
	end,
	-- RODRIGO
	-- método de Event
	-- TODO: Verify if it can be moved to Event.lua
	config = function(self, time, period, priority)
		if time == nil then
			time = self.cObj_[1]:getTime()
		elseif type(time) ~= "number" then
			incompatibleTypesErrorMsg("#1", "number",type(time), 3)
		end

		if period == nil then
			period = self.cObj_[1]:getPeriod()
		elseif type(period) ~= "number" then
			incompatibleTypesErrorMsg("#2", "number", type(period), 3)
		elseif period <= 0 then
			incompatibleValuesErrorMsg("#2", "positive number", period, 3)
		end

		if priority == nil then
			priority = self.cObj_[1]:getPriority()
		elseif type(priority) ~= "number" then
			incompatibleTypesErrorMsg("#3", "number", type(priority), 3)
		end

		self.cObj_[1]:config(time, period, priority)
	end
}

local metaTablePair_ = {__index = Pair_, __tostring = tostringTerraME}

function Pair(data)
	if data == nil then data = {} end

	if getn(data) ~= 2 then
		customErrorMsg("A pair must have two attributes.", 3)
	end

	setmetatable(data, metaTablePair_)
	data.cObj_ = data	

	return data
end

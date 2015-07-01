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
	config = function(self, time, period, priority)
    if time == nil or type(time) ~= "number" then
			incompatibleTypesErrorMsg("#1", "positive number",type(time), 3)
		elseif time < 0 then
			incompatibleValuesWarningMsg("#1", "positive number", time, 3)
		end

    if period == nil or type(period) ~= "number" then
			incompatibleTypesErrorMsg("#2", "positive number", type(period), 3)
    elseif period < 0 then
			incompatibleValuesErrorMsg("#2", "positive number", period, 3)
    end

    if priority == nil or type(priority) ~= "number" then
			incompatibleTypesErrorMsg("#3", "positive number", type(priority), 3)
		elseif priority < 0 then
			incompatibleValuesErrorMsg("#3", "positive number", priority, 3)
    end

		self.cObj_[1]:config(time, period, priority)
	end
}

local metaTablePair_ = {__index = Pair_}

function Pair(data)
	if(data == nil) then data = {}; end

	if getn(data) ~= 2 then
		customErrorMsg("Error: A pair must have two attributes.", 3)
	end

	setmetatable(data, metaTablePair_)
	data.cObj_ = data	

	return data
end

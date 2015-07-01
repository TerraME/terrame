---A Flow describes the behavior of an automaton or Agent in a given State.
-- @param data.1st A function(ev, agent, cell), where the arguments are: an Event that activated the Flow, the Automaton or Agent that owns the Flow, and the Cell over which the Flow will be evaluated.
-- @usage Flow { function(ev, agent, cell)
--     agent.value = agent.value + 2
-- end}
function Flow(data)
	local cObj = TeFlow()
	local metaAttr = {rule = cObj}
	local metaTable = {__index = metaAttr}

  if data == nil then
    data = {}
    defaultValueWarningMsg("#1", "table", "{}", 3)
	elseif(type(data) ~= "table") then
		incompatibleTypesErrorMsg("data","table",type(data),3)
	end

	if(type(data[1]) ~= "function") then
		customErrorMsg("Error: Flow constructor expected a function as parameter.", 3)
	end

	setmetatable(data, metaTable)
	cObj:setReference(data)

	return cObj
end


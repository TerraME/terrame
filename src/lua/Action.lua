function Action(data)
	local cObj = TeMessage()
	local metaAttr = {cObj_ = cObj}
	local metaTable = {__index = metaAttr}
	if (data.id ~= nil) then cObj:config(data.id) end
	setmetatable(data, metaTable)
	cObj:setReference(data)
	return data
end


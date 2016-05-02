
soc = Society{
	quantity = 10,
	instance = Agent{}
}

forEachOrderedElement(soc, function(el)
	el.w = el.w + 1
end)


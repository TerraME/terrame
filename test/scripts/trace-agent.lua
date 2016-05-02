soc = Society{
	quantity = 10,
	instance = Agent{}
}

forEachAgent(soc, function(agent)
	agent.w = agent.w + 1
end)


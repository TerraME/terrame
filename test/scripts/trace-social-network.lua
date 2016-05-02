soc = Society{
	quantity = 10,
	instance = Agent{}
}

soc:createSocialNetwork{quantity = 1}

forEachSocialNetwork(soc.agents[1], function(agent)
	agent.w = agent.w + 1
end)


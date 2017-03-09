-- @example Implementation of El Farol model.
-- It is based on Brian Arthur's paper available at
-- http://www.santafe.edu/~wbarthur/Papers/El_Farol.
-- In this model, there is a city with a given population.
-- Everybody wants to go to an entertainment offered once a week
-- by a bar called El Farol. However, if the bar is too crowded,
-- it is not enjoyable. Each agent decides on
-- whether to go to the bar based on its expectations on how much
-- people the bar will have. Decisions are taken independently from
-- each other. Agents can have different ways of thinking, based on the
-- amount of people that went to the bar in the last weeks.
-- @arg N Number of people in the city. The default value is 100.
-- @arg K number of strategies each individual has (if only one then the
-- agent will never change its strategy). The default value is 3.
-- @arg MAX Maximum number of people in the bar. The default value is 60.
-- @image el-farol.bmp

N = 100
K = 3
MAX = 60

LAST_TURNS = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

update_last_turns = function(new_value)
	for i = 9, 1, -1 do
		LAST_TURNS[i + 1] = LAST_TURNS[i]
	end
	LAST_TURNS[1] = new_value
end

-- different strategies that can be adopted by the agents
-- t[x] represent the amount of people that went to the bar x weeks ago
function d_same_last_week(t)    return t[1]                            end
function d_same_plus_10(t)      return t[1] + 10                       end
function d_mirror_last_week(t)  return 100 - t[1]                      end
function d_67()                 return 67                              end
function d_same_2_weeks(t)      return t[2]                            end
function d_same_5_weeks(t)      return t[5]                            end
function d_average_4_weeks(t)   return (t[1] + t[2] + t[3] + t[4]) / 4 end
function d_average_2_weeks(t)   return (t[1] + t[2]) / 2               end
function d_max_2_weeks(t)       return math.max(t[1], t[2])            end
function d_min_2_weeks(t)       return math.min(t[1], t[2])            end

STRATEGIES = {d_same_last_week, d_same_plus_10, d_mirror_last_week, d_67, d_same_2_weeks,
              d_same_5_weeks, d_average_4_weeks, d_max_2_weeks, d_min_2_weeks}

NAMES_STRATEGIES = {
	[d_same_last_week]   = "d_same_last_week",
	[d_same_plus_10]     = "d_same_plus_10",
	[d_mirror_last_week] = "d_mirror_last_week",
	[d_67]               = "d_67",
	[d_same_2_weeks]     = "d_same_2_weeks",
	[d_same_5_weeks]     = "d_same_5_weeks",
	[d_average_4_weeks]  = "d_average_4_weeks",
	[d_max_2_weeks]      = "d_max_2_weeks",
	[d_min_2_weeks]      = "d_min_2_weeks"
}

c = Cell{agents_in_the_bar = 0}

list_attributes = {}

forEachElement(NAMES_STRATEGIES, function(_, name)
	c[name] = 0
	list_attributes[#list_attributes + 1] = name
end)

chartBar = Chart{
	target = c,
	select = {"agents_in_the_bar"},
	symbol = "hexagon",
	size = 7,
	yLabel = "percentage"
}

chartStrategies = Chart{
	target = c,
	select = list_attributes
}

function count_strategies(soc)
	local tot = {}
	for i = 1, #STRATEGIES do
		tot[STRATEGIES[i]] = 0
	end

	local strat

	forEachAgent(soc, function(agent)
		strat = agent.strategies[agent.last_strategy]
		tot[strat] = tot[strat] + 1
	end)

	for i = 1, #STRATEGIES do
		strat = STRATEGIES[i]
		c[NAMES_STRATEGIES[strat]] = tot[strat]
	end
end

beerAgent = Agent{
	init = function(ag)
		ag.strategies = {}
		ag.count_fails = {}

		-- choose K different strategies
		ag.chosen = {0, 0, 0, 0, 0, 0, 0, 0, 0}
		for i = 1, K do
			ag.count_fails[i] = 0
			local p
			repeat
				p = Random{min = 1, max = #STRATEGIES, step = 1}:sample()
			until ag.chosen[p] == 0

			ag.strategies [i] = STRATEGIES[p]
			ag.chosen[p] = 1
		end

		ag.last_strategy = 1
	end,
	execute = function(ag)
		local best = 1

		for i = 2, K do
			if ag.count_fails[best] > ag.count_fails[i] then
				best = i
			end
		end

		ag.last_strategy = best

		local last = ag.strategies[best](LAST_TURNS)

		if last < 60 then
			ag.last_choose = 1
		else
			ag.last_choose = 0
		end

		return ag.last_choose
	end,
	update = function(ag, quantity)
		for i = 1, K do
			-- punishment is equal to the difference btw the predicted value
			-- and the number of attendances
			local diff = ag.strategies[i](LAST_TURNS) - quantity
			ag.count_fails[i] = ag.count_fails[i] + math.abs(diff)
		end
	end
}

s = Society{
	instance = beerAgent,
	quantity = N
}

t = Timer{
	Event{action = function()
		local quant = 0

		forEachAgent(s, function(ag)
			quant = quant + ag:execute()
		end)

		c.agents_in_the_bar = quant
		count_strategies(s)

		forEachAgent(s, function(ag)
			ag:update(quant)
		end)

		update_last_turns(quant)
	end},
	Event{action = chartStrategies},
	Event{action = chartBar}
}

t:run(100)


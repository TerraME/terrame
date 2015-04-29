
-- @example Model to study scenarios for the economy of Southeast Para state. 
-- Andrade et al. 2010 From input-output matrixes to agent-based models: A case study on 
-- carbon credits in a local economy. BWSS 2010.
-- @arg scenario Number of the scenario. It can be an integer value between 1 and 5.
-- The default value is 1.

M_NAMES    = 17
M_SALARIES = 18
M_TAXES = 19
M_EMPLOYMENT = 20
M_EMISSION = 21

m_csa = {}
m_csa[ 1] = { 5.1,  0.0,   0.0,  9.0, 184.6,  17.6,  39.9,   62.3,  0.2,   0.0,   0.6,    0.0,   0.0,    0.0,    1.6,   0.0,  258.3, 156.3,   0.0,    0.0}
m_csa[ 2] = { 0.0, 24.9,   0.0, 10.4,  77.6,  43.9,  32.1,   35.7,  0.2,   0.0,   2.2,    0.0,   0.0,    0.0,    8.9,   0.0,  260.1,  78.3,   0.0,    0.0}
m_csa[ 3] = { 0.0,  0.0,   0.0,  0.0, 410.5,   0.0,   0.0,    0.0,  0.0,   0.0,   0.0,    0.0, 334.7,    0.0,    0.0,   0.0,    0.0,   0.0,   0.0, 4098.8}
m_csa[ 4] = { 0.0,  0.0,   0.0,  0.0,  42.9,   0.0,  10.4,    0.0,  0.0,   0.0,   0.8,    0.0,   0.0,    0.0,    0.0,   0.0,    0.3,   0.0,   0.0,    0.0}
m_csa[ 5] = { 0.0,  0.0,   0.0,  0.0,  19.5,  56.5,   4.4,  158.7,  0.0,   6.9,  40.5,  183.8,   0.0,   45.2,   31.4,  86.1,    2.6,   0.0,   0.0,  485.9}
m_csa[ 6] = { 0.0,  0.0,   0.0,  0.3,   0.0,   0.0,   0.0,  898.0,  0.0,   0.0,   0.0,    9.5,   0.0,   75.9,    0.0,  56.6,    0.0,   0.0,   0.0,    0.0}
m_csa[ 7] = { 2.2,  2.4,  32.4,  0.0,   1.6, 207.8,  22.7,  582.3, 23.5,   6.8,  50.6,    0.0,   4.5,    0.0,   28.6,   0.0,    5.0,   0.0,   0.0,    0.0}
m_csa[ 8] = {96.4, 49.9, 352.7,  0.0,   9.4,   0.0,   0.9,    0.0,  0.0,   0.0,   0.2,    0.0,   0.0,    0.0,    0.0,   0.0, 3198.9, 648.1,   0.0,    0.0}
m_csa[ 9] = { 0.0,  0.0,   0.0,  0.0,   0.0,   0.0,   0.0,    0.8,  0.0, 137.9, 258.5,    0.0,   0.0,    0.0,    0.0,   0.0,    0.0,   0.0,   0.0,    0.0}
m_csa[10] = { 0.0,  0.0,   0.0,  0.0,   0.0,   0.0,  38.8,    0.0,  0.0,   0.0, 171.0,   73.6,   0.0,    0.0,   70.1,   0.0,    0.0,   0.0,   0.0,    0.4}
m_csa[11] = { 1.6,  1.4,   5.6,  0.2,  38.0, 128.6, 340.4,  768.9, 13.5,   8.3,   5.1,  118.0,   0.9,    0.0,    0.0,   0.0,    0.0,   0.0,  41.5,   68.0}
m_csa[12] = { 0.0,  0.0,  54.2,  0.0,   0.0,   0.0,   0.0,    0.0,  0.0,   0.0,   0.0,    0.0,   0.0,    0.0,    0.0,   0.0,  277.8,   0.0, 387.7,    0.0}
m_csa[13] = { 0.0,  0.0,   0.0,  0.0,   0.0,   0.0,   0.0,    0.0,  0.0,  71.9,   0.0,    0.0,   0.0, 2711.1,    0.0,   0.2,    0.0,   0.0,   0.0,    0.1}
m_csa[14] = { 0.0,  0.0,   0.0,  0.0,   0.0, 108.6,  69.6,  403.5,  0.0,   0.0, 663.0,  138.1,   0.0,    0.0, 1670.7, 179.6,    0.0,   0.0,   0.0,  477.4}
m_csa[15] = { 0.0,  0.0, 526.6,  0.0,   0.0,   0.0, 297.9,  771.8,  0.0,   0.0, 156.8,    2.2,  91.9,  125.8,    6.8,   7.9,   41.0,   0.0,   0.0,   78.5}
m_csa[16] = { 0.0,  0.0,   0.0,  0.0,   0.0,   0.0,   0.0,    0.0, 0.01,   0.0,   0.01,   0.0,   0.0,    0.0,    0.0,   0.0,    0.0,   0.0,   0.0,  443.3}

m_csa[M_SALARIES]   = {169.1,  72.9, 272.0, 2.3, 71.1, 73.3, 41.7, 366.0, 17.0, 24.9, 66.2, 60.5, 94.1, 288.6, 137.7, 54.1}
m_csa[M_TAXES]      = { 12.6,   0.9, 643.2, 3.5, 45.5, 12.7,  9.1, 103.1,  4.1,  4.4, 57.3, 37.2, 98.0, 146.5,  59.1, 38.0}
m_csa[M_EMPLOYMENT] = { 50.7, 138.1,  13.9, 0.4, 12.0, 10.5,  7.5,  51.6,  2.2,  3.2, 11.1,  7.3, 12.6,  24.5,  17.6,  5.0}
m_csa[M_EMISSION]   = {217.8,  75.4,     0,    0,   0,    0,    0,     0,    0,    0,    0,    0,    0,     0,     0,    0}

m_csa[M_NAMES] = {	"Large farms         ", "Small farms            ", "Mining               ", "Intermediation     ",
					"Local_processing    ", "Local_manufacturing    ", "Local_wholesaler     ", "Local_retailer     ",
					"Regional_processing ", "Regional_manufacturing ", "Regional_wholesaler  ", "Regional_retailer  ",
					"National_processing ", "National_manufacturing ", "National_wholesaler  ", "National_retailer  "}

function f(value) return string.format("%.2f", value) end

scenario = 1

family = Agent {
	sum_vr = 0, 
	received = 0, 
	name = "Family          ",
	id = "17",
	sum_cost = 0,
	execute = function(ag)
		if ag.received < 0.001 and ag.received > -0.001 then return end

		ag.sum_cost = ag.sum_cost + ag.received

		forEachConnection(ag, function(ag, neigh, weigh)
			ag:message{receiver = neigh, subject = "money", value = ag.received * weigh}
		end)
		ag.received = 0
	end,
	print = function(ag)
		print(ag.name.."\t"..f(ag.sum_cost))
	end,
	on_money = function(ag, mes)
		ag.received = ag.received + mes.value
	end
}

government = Agent {
	sum_vr = 0,
	sum_em = 0,
	sum_cost = 0,
	sum_sa = 0,
	sum_lu = 0,
	name = "Government              ",
	id = "19",
	sum_co2 = 0,
	on_money      = function(ag, mes) ag.sum_vr  = ag.sum_vr  + mes.value end,
	on_salary     = function(ag, mes) ag.sum_sa  = ag.sum_sa  + mes.value end,
	on_employment = function(ag, mes) ag.sum_em  = ag.sum_em  + mes.value end,
	on_profit     = function(ag, mes) ag.sum_lu  = ag.sum_lu  + mes.value end,
	on_carbon     = function(ag, mes) ag.sum_co2 = ag.sum_co2 + mes.value end,
	print         = function() end,
	execute       = function() end
}

capital_formation = Agent{
	sum_vr = 0, 
	received = 0, 
	name = "Capital formation",
	id = "18",
	sum_cost = 0,
	execute = function(ag)
		if ag.received < 0.001 and ag.received > -0.001 then return end

		ag.sum_cost = ag.sum_cost + ag.received

		forEachConnection(ag, function(ag, neigh, weigh)
			ag:message{receiver = neigh, subject = "money", value = ag.received * weigh}
		end)
		ag.received = 0
	end,
	print = function(ag)
		print(ag.name.."\t"..f(ag.sum_cost))
	end,
	on_money = function(ag, mes)
		ag.received = ag.received + mes.value
	end
}

sum_demand = 0
basicAgent = Agent{
	sum_vr = 0, taxes = 0, sum_cost = 0, salary = 0, received = 0, name = "", 
	family = 0, capital_formation = 0, employment = 0, sum_salary=0, sum_taxes=0, sum_employment=0, sum_r = 0,

	print = function(ag)
		print(ag.name.."\t"..f(ag.sum_r).."\t"..f(ag.sum_salary).."\t"..f(ag.sum_taxes).."\t"..f(ag.sum_employment))
	end,
	execute = function(ag)
		if ag.received < 0.001 and ag.received > -0.001 then return end

		local vr = ag.received - ag.received * (ag.taxes + ag.salary + ag.costs)
		local cost       = ag.received * ag.costs
		local salary     = ag.received * ag.salary
		local taxes      = ag.received * ag.taxes
		local employment = ag.received * ag.employment
		local emissions  = ag.received * ag.emissions
		local profit     = ag.received - cost - salary - taxes

		ag.sum_salary = ag.sum_salary + salary
		ag.sum_taxes = ag.sum_taxes + taxes
		ag.sum_employment = ag.sum_employment + employment
		ag.sum_cost = ag.sum_cost + cost

		ag.sum_vr = ag.sum_vr + profit + salary + taxes + cost

		local profit_family = profit * 0.2818
		local profit_capital = profit * 0.1114

		ag:message{receiver = family,            subject = "money", value = salary + profit_family}
		ag:message{receiver = capital_formation, subject = "money", value = profit_capital}
			
		ag:message{receiver = government, subject = "money",      value = taxes}
		ag:message{receiver = government, subject = "employment", value = employment}
		ag:message{receiver = government, subject = "salary",     value = salary}
		ag:message{receiver = government, subject = "carbon",     value = emissions}
		ag:message{receiver = government, subject = "profit",     value = profit}
--		ag:message{receiver = family,     subject = "money",      value = salary}

		forEachConnection(ag, function(ag, neigh, weigh)
			ag:message{receiver = neigh, subject = "money", value = cost * weigh}
		end)
		ag.received = 0
	end,
	on_money = function(ag, mes)
		local value = mes.value
		ag.received = ag.received + value
		sum_demand = sum_demand + value
		ag.sum_r = ag.sum_r + value
	end
}

read_csa = function(society, matrix)
	for idx = 1, #society do
		local a = society:get(idx)

		local vbp = 0
		for i = 1, 20 do -- sum the line
			local value = matrix[idx][i]
			vbp = vbp + value
		end
	
		a.taxes      = matrix[M_TAXES]     [idx] / vbp
		a.salary     = matrix[M_SALARIES]  [idx] / vbp
		a.employment = matrix[M_EMPLOYMENT][idx] / vbp
		a.emissions  = matrix[M_EMISSION]  [idx] / vbp
		a.name       = matrix[M_NAMES]     [idx]
		a.idx = idx

		local sum = 0
		for i = 1, 16 do -- sum the column
			local value = matrix[i][idx]
			sum = sum + value
		end
		a.costs = sum / vbp

		local sn = SocialNetwork()
		for i = 1, 16 do
			local value = matrix[i][idx]
			if value > 0 then
				sn:add(society:get(i), value / sum)
			end
		end	
	a:addSocialNetwork(sn)
	end
end

read_csa_consumers = function(society, matrix)
	local vp = {family, capital_formation}
	for idx = 1, getn(vp) do
		local a = vp[idx]

		local sum = 0
		for i = 1, 16 do -- sum the column
			local value = matrix[i][16 + idx]
			sum = sum + value
		end

		local sn = SocialNetwork()
		for i = 1, 16 do
			local value = matrix[i][16 + idx]
			if value > 0 then
				sn:add(society:get(i), value / sum)
			end
		end
		a:addSocialNetwork(sn)
	end
end

print_connections = function()
	for idx = 1, s:getn() do
		local a = s:get(idx)
		print("\nIDX: "..a.id.."  ".. a.name)
	
		local sum = 0
		for i = 1, 16 do
			local value = m_csa[i][idx]
			sum = sum + value
		end

		forEachConnection(a, function(nei, wei)
			print(nei.name.."\t"..wei.."   "..wei * sum)
		end)
	end
end

s = Society{instance = basicAgent, quantity = 16}
read_csa(s, m_csa)
read_csa_consumers(s, m_csa)

s:add(family)
s:add(capital_formation)
s:add(government)

exogenous_agent = Agent{name = "-=-=-=  exogenous  -=-=-", execute = function() end}

s:add(exogenous_agent)

default_scenario = function()
	for i = 1, 16 do
		for j = 19, 20 do
			exogenous_agent:message{receiver = s:get(i), value = m_csa[i][j], subject = "money"}
		end
	end
end

scenario_1 = function()
	print "SCENARIO 1"
	default_scenario()
	exogenous_agent:message{receiver = s:get(8), value = 435.14, subject = "money"}
	exogenous_agent:message{receiver = s:get(1), value = -367.67, subject = "money"}
	exogenous_agent:message{receiver = s:get(2), value = -287.21, subject = "money"}
end

scenario_2 = function()
	print "SCENARIO 2"
	default_scenario()

	exogenous_agent:message{receiver = s:get(8), value = 435.14, subject = "money"}
end

scenario_3 = function()
	print "SCENARIO 3"
	default_scenario()
	exogenous_agent:message{receiver = s:get(1), value = -735.33, subject = "money"}
	exogenous_agent:message{receiver = s:get(2), value = 735.33,  subject = "money"}
	exogenous_agent:message{receiver = s:get(8), value = 435.14,  subject = "money"}
end

scenario_4 = function()
	print "SCENARIO 4"
	default_scenario()
	exogenous_agent:message{receiver = s:get(1), value = -367.67, subject = "money"}
	exogenous_agent:message{receiver = s:get(2), value = -287.21, subject = "money"}
	exogenous_agent:message{receiver = s:get(3), value = 6563.05, subject = "money"}
	exogenous_agent:message{receiver = s:get(8), value = 435.14,  subject = "money"}
end

scenario_5 = function()
	print "SCENARIO 5"
	default_scenario()
	exogenous_agent:message{receiver = s:get(1), value = 287.21*2,  subject = "money"}
	exogenous_agent:message{receiver = s:get(2), value = -287.21*2, subject = "money"}
	exogenous_agent:message{receiver = s:get(8), value = 435.14,    subject = "money"}
end

scenarios = {default_scenario, scenario_1, scenario_2, scenario_3, scenario_4, scenario_5}

execute = function(time)
	for i = 1, time do
		s:execute()
	end
end

scenarios[scenario + 1]()
execute(100)

print("REPORT:")
luc = government.sum_lu
print("Salaries:   "..f(government.sum_sa) .."\t"..f(government.sum_sa - 1811.7))
print("Profit:     "..f(government.sum_lu) .."\t"..f(government.sum_lu - 7921.4))
print("Taxes:      "..f(government.sum_vr) .."\t"..f(government.sum_vr - 1275.3))
print("Employment: "..f(government.sum_em) .."\t"..f(government.sum_em - 368.2))
print("Carbon:     "..f(government.sum_co2).."\t"..f(government.sum_co2 - 217.8-75.4))
print("Tot Demand: "..f(sum_demand)        .."\t"..f(sum_demand - 25752.1))

print("")
a = s:get(1)
print("Profit:     "..f(a.sum_vr))
print("Employment: "..f(a.sum_employment))
a = s:get(2)
print("Profit:     "..f(a.sum_vr))
print("Employment: "..f(a.sum_employment))


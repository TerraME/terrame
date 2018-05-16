--[[ [previous](03-output.lua) | [back to index](00-contents.lua) | [next](00-contents.lua)

Sometimes it is interesting to use an automatic approach to try to get insights
related to the parameters of the model. Package calibration provides SAMDE, an
automatic calibration method based on genetic algorithms. It requires a
goodness-of-fit function that gets the result of a simulation and return how good
it is, in order to allow comparing the results between different simulations. The
parameters it gets as argument define the search space (Choice values) as well as
static values (other parameters). It also needs a fit function that returns a
value with the difference between reality and simulation. As default, SAMDE will
try to find a set of parameters that produces an approximated minimum fit in a
computationally reasonable time. The example below uses a
Susceptible-Infected-Recovered (SIR) model from sysdyn package. It uses real
fluData to compute the fit using the sum of the squares of the differences.

]]

import("sysdyn")
import("calibration")

fluData = {3, 7, 25, 72, 222, 282, 256, 233, 189, 123, 70, 25, 11, 4}

fluSimulation = SAMDE{
	model = SIR,
	maxGen = 50,
	parameters = {
		contacts = Choice{min = 2, max = 50, step = 1},
		probability = Choice{min = 0, max = 1},
		duration = Choice{min = 1, max = 20},
		finalTime = 13,
		susceptible = 763,
		infected = 3
	},
	fit = function(model)
		local dif = 0

		forEachOrderedElement(model.finalInfected, function(idx, att)
			dif = dif + math.abs(att - fluData[idx]) ^ 2
		end)

		return dif
	end
}

--[[

The results of the final fit as well as the parameters of the best simulation are
stored in the output of SAMDE within instance attribute.

]]

print("Difference between data and best simulation: "..fluSimulation.fit)
modelF = fluSimulation.instance

print("Parameters of best simulatoin:")
print("duration:    "..modelF.duration)
print("contacts:    "..modelF.contacts)
print("probability: "..modelF.probability)

--[[

From the output, it is possible to repeat the best simulation using the selected
parameters.

]]

instance = SIR{
	duration    = modelF.duration,
	contacts    = modelF.contacts,
	probability = modelF.probability,
	susceptible = 763,
	infected    = 3,
	finalTime   = modelF.finalTime
}

instance:run()

data = DataFrame{data = fluData, infected = instance.finalInfected}

chart = Chart{
	target = data,
	select = {"data", "infected"},
	label = {"Data", "Best simulation"},
	title = "Infected"
}


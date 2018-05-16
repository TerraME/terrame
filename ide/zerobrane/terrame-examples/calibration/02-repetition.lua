--[[ [previous](01-parameter.lua) | [back to index](00-contents.lua) | [next](03-output.lua)

When working with models that use random numbers, it is necessary to repeat the
simulations in order to investigate whether they always converge to a stable
state. MultipleRuns has an argument repetition to indicate the amout of times a
given simulation must be repeated. As default, it only executes once. The source
code below executes model Fire from package ca, simulating different values for
empty argument, and repeating each of them five times. The function summary
executes in the end of the repetitions of a given simulation. In this case, it
computes the average value of forest in the end of the simulation.

]]

import("ca")
import("calibration")

mr = MultipleRuns{
    model = Fire,
    repetition = 5,
    parameters = {
        empty = Choice{min = 0.2, max = 1, step = 0.05},
        dim = 30
    },
    forest = function(model)
        return model.cs:state().forest or 0
    end,
    summary = function(result)
        local sum = 0

        -- each value of result.forest is obtained from the function above
        forEachElement(result.forest, function(_, value)
            sum = sum + value
        end)

        return {average = sum / #result.forest}
    end
}

--[[

Finally, it is possible to plot the result of the averages.

]]

chart = Chart{
    target = mr.summary,
    select = "average",
    label = "average in the end",
    xAxis = "empty",
    color = "red"
}


--[[ [previous](00-contents.lua) | [back to index](00-contents.lua) | [next](02-repetition.lua)

Type MultipleRuns can simulate a given Model several times. It has strategies to
help de user to execute multiple simulations according to ordinary modeling
necessities. For example, one of the basic simulation procedures is to explore
different values for the given parameter leaving all other unchanged. The code
below uses the Model Daisyworld to investigate how sunLuminosity affects the final
outcomes of the model. It simulates the model 121 times, using sunLuminosity from
0.4 to 1.6, with 0.01 of step (0.4, 0.41, 0.42, ..., 1.6). Note that lower step
values implies in more simulations and therefore more execution time. In the end,
an object mr is created with all the outputs of all simulations.

]]

import("sysdyn")
import("calibration")

mr = MultipleRuns{
    model = Daisyworld,
    parameters = {
        sunLuminosity = Choice{min = 0.4, max = 1.6, step = 0.01},
    }
}

--[[

After that, it is possible to save the output, as shown below. An object of type
MultipleRuns has an object output with all the results. The saved file will have
122 lines because it adds a header.

]]

mr.output:save("result.csv")

--[[

It is also possible to plot the output of the simulations in a Chart using
sunLuminosity as xAxis. The same output object can be used as target Note that
each point in this Chart is the final output of one simulation.

]]

chart = Chart{
    target = mr.output,
    select = {"blackArea", "whiteArea", "emptyArea"},
    xAxis = "sunLuminosity"
}


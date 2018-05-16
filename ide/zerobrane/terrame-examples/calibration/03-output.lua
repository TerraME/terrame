--[[ [previous](02-repetition.lua) | [back to index](00-contents.lua) | [next](04-samde.lua)

When running a simulation, all the output files are created in the current
directory as default. If one wants to run several simulations following this
procedure, the output of consecultive simulations will be overwritten.
MultipleRuns has an argument output that describes a directory where the output
data will be saved. For each simulation, it creates a given directory with the
parameters of the simulation and stores the output there. This way, no file is
overwritten by a following simulation during the experiment.

The code below saves the map created by each simulation. The code to save is
implemented in function save, but it could be implemented in any other function
within MultipleRuns as well as within the model itself. Note that, to allow saving
the maps, it is necessary to use hideGraphics = false as argument to MultipleRuns.

]]

import("ca")
import("calibration")

MultipleRuns{
    model = Fire,
    hideGraphics = false,
    repetition = 2,
    folderName = "output",
    parameters = {
        empty = Choice{min = 0.2, max = 0.4, step = 0.1},
        finalTime = 5, -- all the simulations run only five steps
        dim = 20
    },
    save = function(model)
        model.map:save("map.png")
    end
}

--[[

After running this script, open the directory where this script is stored to see
the created files and directories. Note that, as the simulations stop in the end
of time five, the burning process is still taking place.

]]


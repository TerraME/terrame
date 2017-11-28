--[[ [previous](08-model-sir-run.lua) | [contents](00-contents.lua) | [next](10-model-sir-configure.lua) ]]

dofile("07-model-sir.lua")

instance = SIR{
    duration = 4,
    contacts = 2,
	finalTime = 80
}

instance:run()


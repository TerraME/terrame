--[[ [previous](10-model-sir-configure.lua) | [contents](00-contents.lua) | [next](12-model-life.lua) ]]

dofile("07-model-sir.lua")

env = Environment{
    SIR{},
    SIR{duration = 4},
    SIR{duration = 8}
}

clean() -- remove the three Charts previously created by SIR calls

chart = Chart{
    target = env,
    select = "infected"
}

env:add(Event{action = chart})
env:run()


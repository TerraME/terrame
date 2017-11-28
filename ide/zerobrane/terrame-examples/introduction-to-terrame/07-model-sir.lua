--[[ [previous](06-event-timer.lua) | [contents](00-contents.lua) | [next](08-model-sir-run.lua)

This code does not show anything in the screen as it is only
the definition of SIR Model. See the next examples.

]]

SIR = Model{
    susceptible = 9998,
    infected = 2,
    recovered = 0,
    duration = 2,
    contacts = 6,
    probability = 0.25,
    finalTime = 30,
    init = function(self)
        self.chart = Chart{
            target = self,
            select = {"susceptible", "infected", "recovered"},
            color = {"green", "red", "blue"}
        }
        local total = self.susceptible + self.infected + self.recovered
        local alpha = self.contacts * self.probability
        self.timer = Timer{
            Event{action = function()
                local prop = self.susceptible / total

                local newInfected = self.infected * alpha * prop
                local newRecovered = self.infected / self.duration
                self.susceptible = self.susceptible - newInfected
                self.recovered = self.recovered + newRecovered
                self.infected = self.infected + newInfected - newRecovered
            end},
            Event{action = self.chart}
        }
    end
}


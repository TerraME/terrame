
font {
	name = "Pet Animals",
	file = "Pet Animals.ttf",
	summary = " Pet animals by Zdravko Andreev, aka Z-Designs. This font is free for personal and non-commercial use.",
	source = "http://www.dafont.com/pet-animals.font",
	symbol = {
		fish   = 66,
		rabbit = 67,
		owl    = 71,
		mouse  = 72,
		snake  = 74,
		turtle = 76,
		bird   = 77,
		horse  = 78,
		pig    = 80,
		dog    = 85,
		cat    = 90
	}
}

font {
	name = "JLS Smiles Sampler",
	file = "JLS Smiles Sampler.ttf",
	summary = "Font by Michael Adkins & James Stirling. \"Have a nice day!\" I can remember that motto and the smiley face from childhood. It was friendly, optimistic little image that became an icon. These days it has been updated and is a collection of emoticons used by cultures world wide. The smiley face can now be friendly, sad, happy, angry, etc. This collection is our fun expression of the smiley face.",
	source = "http://www.dafont.com/jls-smiles-sampler.font",
	symbol = {
		smile = 65,
		smile2 = 71,
		smile3 = 77,
		smile4 = 79,
		pirate = 74,
		skeleton = 86,
		vampire = 88,
		mustache = 99,
		cry = 101,
		sick = 113
	}
}

font {
	name = "Grissom Free",
	file = "Grissom Free.ttf",
	summary = "Intellecta Design makes research and development of fonts with historical and artistical relevant forms. This font is a FREE software for personal and non-commercial use only.",
	source = "http://www.dafont.com/grissom.font",
	symbol = {
		beetle      =  52,
		fly         =  71,
		ant         =  74,
		snail       =  75,
		grasshopper =  80,
		butterfly   =  81,
		spider      =  86,
		bug         =  88,
		dragonfly   =  90,
		fly2        =  97,
		bug2        = 100,
		mantis      = 108,
		scorpion    = 109,
	}
}

local symbols = {}

for i = 65, 90 do
	symbols[string.char(i)] = i
end

font {
	name = "Ubuntu",
	summary = "The Ubuntu Font Family are a set of matching new libre/open fonts. The development is being funded by Canonical on behalf the wider Free Software community and the Ubuntu project. The technical font design work and implementation is being undertaken by Dalton Maag.",
	file = "Ubuntu-L.ttf",
	source = "http://font.ubuntu.com",
	symbol = symbols
}



font {
	name = "Pet Animals",
	file = "Pet Animals.ttf",
	summary = "Pet animals by Zdravko Andreev, aka Z-Designs. This font is free for personal and non-commercial use.",
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

local eyes = {}

for i = 48, 57 do
	eyes["eye"..i - 48] = i
end

font {
	name = "Freaky Face",
	file = "TheFreakyFace.ttf",
	summary = "Some faces with different number of eyes.",
	source = "https://www.dafont.com/the-freaky-face.font",
	symbol = eyes
}

font{
	name = "LL Faces",
	file = "LLFACES2.ttf",
	summary = "Head faces of different sizes and internal content.",
	source = "https://www.dafont.com/llfaces.font",
	symbol = {
		size0 = 49,
		size1 = 50,
		size2m = 51,
		size2f = 52,
		size3m = 53,
		size3f = 54,
		size4m = 55,
		size4f = 56,
		head1 = 76,
		head2 = 77,
		head3 = 78,
		head4 = 79,
		head5 = 80,
		head6 = 81,
		head7 = 82,
		head8 = 83,
		head9 = 84,
		head10 = 85,
		head11 = 86,
		head12 = 87
	}
}

font {
	name = "Science",
	file = "Science Icons.ttf",
	summary = "Some science objects and symbols.",
	source = "https://dl.dafont.com/dl/?f=science",
	symbol = {
		magnifier = 42,
		lamp = 39,
		atom = 91,
		researcher = 97,
		mask = 101,
		doubt = 102
	}
}

font {
	name = "Chess",
	file = "CHEQ_TT.ttf",
	summary = "Chess icons.",
	source = "https://www.dafont.com/chess.font",
	symbol = {
		bishop = 98,
		pawn = 112,
		king = 107,
		rook = 114,
		knight = 104,
		queen = 113
	}
}

font {
	name = "Pregnancy",
	file = "Pregnancy.ttf",
	summary = "Pregnancy icons.",
	source = "https://www.dafont.com/pregnancy.font",
	symbol = {
		doctor = 60,
		pregnant1 = 68,
		pregnant2 = 71,
		pregnant3 = 72,
		pregnant4 = 75,
		baby1 = 82,
		baby2 = 87,
		feet = 84,
		nurse = 90,
		hands = 92,
		dna = 93,
		coupple = 109,
		ambulance = 120,
		embryo1 = 51,
		embryo2 = 63
	}
}



local symbols = {}

for i = 65, 90 do
	symbols[string.char(i)] = i
end

font {
	name = "Ubuntu",
	summary = "The Ubuntu Font Family are a set of matching new libre/open fonts. The development is being funded by Canonical on behalf the wider Free Software community and the Ubuntu project. The technical font design work and implementation is being undertaken by Dalton Maag. This font is used in every window displayed by TerraME.",
	file = "Ubuntu-L.ttf",
	source = "http://font.ubuntu.com",
	symbol = symbols
}


local s = sessionInfo().separator
local so = "mac"

files = {
	packageInfo("onerror").path..s.."examples"..s.."discrete-rain.log",
	packageInfo("onerror").path..s.."log"..s..so..s.."chart_cell.bmp",
	packageInfo("twoerrors").path..s.."examples"..s.."continuous-rain.log",
	packageInfo("twoerrors").path..s.."examples"..s.."discrete-rain.log",
	packageInfo("twoerrors").path..s.."log"..s..so..s.."chart_cell.bmp",
	packageInfo("twoerrors").path..s.."log"..s..so..s.."chart_cell_select.bmp",
	packageInfo("nodatadotlua").path..s.."data.lua",
	packageInfo("nofontdotlua").path..s.."font.lua",
	packageInfo("models").path..s.."tests"
}


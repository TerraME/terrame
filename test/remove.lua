local s = sessionInfo().separator
local so = sessionInfo().system

files = {
	packageInfo("onerror").path.."log"..s..so..s.."chart_cell.bmp",
	packageInfo("twoerrors").path.."log"..s..so..s.."discrete-rain.log",
	packageInfo("twoerrors").path.."log"..s..so..s.."chart_cell_select.bmp",
	packageInfo("nodatadotlua").path.."data.lua",
	packageInfo("nofontdotlua").path.."font.lua",
	packageInfo("models").path.."tests",
	currentDir().."onerror-file-1.txt",
	currentDir().."twoerrors-file-1.txt",
	currentDir().."twoerrors-file-2.txt",
	currentDir().."trace-layer.tview"
}


local s = sessionInfo().separator
local so = sessionInfo().system

files = {
	packageInfo("terralib").path.."data/itaituba.qix",
	packageInfo("terralib").path.."data/amazonia.qix",
	packageInfo("terralib").path.."data/cabecadeboi.qix",
	packageInfo("terralib").path.."data/emas.qix",
	packageInfo("onerror").path.."log/chart_cell.bmp",
	packageInfo("twoerrors").path.."log/discrete-rain.log",
	packageInfo("twoerrors").path.."log/chart_cell_select.bmp",
	packageInfo("nodatadotlua").path.."data.lua",
	packageInfo("nofontdotlua").path.."font.lua",
	packageInfo("models").path.."tests",
	currentDir().."onerror-file-1.txt",
	currentDir().."twoerrors-file-1.txt",
	currentDir().."twoerrors-file-2.txt",
	currentDir().."trace-layer.tview"
}


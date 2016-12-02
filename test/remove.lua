local s = sessionInfo().separator
local mdir = sessionInfo().initialDir
local so = sessionInfo().system

files = {
	packageInfo("terralib").path.."data/itaituba.qix",
	packageInfo("terralib").path.."data/amazonia.qix",
	packageInfo("terralib").path.."data/cabecadeboi.qix",
	packageInfo("terralib").path.."data/emas.qix",
	mdir.."packages/onerror/log/chart_cell.bmp",
	mdir.."packages/twoerrors/log/discrete-rain.log",
	mdir.."packages/twoerrors/log/chart_cell_select.bmp",
	mdir.."packages/nodatadotlua/data.lua",
	mdir.."packages/nofontdotlua/font.lua",
	mdir.."packages/models/tests",
	currentDir().."onerror-file-1.txt",
	currentDir().."twoerrors-file-1.txt",
	currentDir().."twoerrors-file-2.txt",
	currentDir().."trace-layer.tview"
}


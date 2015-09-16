local s = sessionInfo().separator

files = {
	packageInfo("onerror").path..s.."examples"..s.."discrete-rain.log",
	packageInfo("onerror").path..s.."snapshots"..s.."chart_cell.bmp",
	packageInfo("twoerrors").path..s.."examples"..s.."continuous-rain.log",
	packageInfo("twoerrors").path..s.."examples"..s.."discrete-rain.log",
	packageInfo("twoerrors").path..s.."snapshots"..s.."chart_cell.bmp",
	packageInfo("twoerrors").path..s.."snapshots"..s.."chart_cell_select.bmp"
}


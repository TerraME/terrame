local hpa = HPA()

local function setupToSum(np, dim)
	local t0 = os.clock()
	
	local csA = CellularSpace {
		xdim = dim
	}

	local csB = CellularSpace {
		xdim = dim
	}

	local csC = CellularSpace {
		xdim = dim
	}

	local csD = CellularSpace {
		xdim = dim
	}

	function fillCsA()
		forEachCell(csA, function(cell)
			cell.value = dim
		end)
	end

	function fillCsB()
		forEachCell(csB, function(cell)
			cell.value = dim
		end)
	end

	function fillCsC()
		forEachCell(csC, function(cell)
			cell.value = dim
		end)
	end

	function fillCsD()
		forEachCell(csD, function(cell)
			cell.value = dim
		end)
	end

	hpa:np(np)

	local t1 = os.clock()

	hpa:parallel("fillCsA()")
	hpa:parallel("fillCsB()")
	hpa:parallel("fillCsC()")
	hpa:parallel("fillCsD()")
	hpa:joinall()

	io.flush()
	local t2 = os.clock()

	print(string.format("setup elapsed time (parallel): %.4f", t2 - t1))
	print(string.format("setup elapsed time (total): %.4f", t2 - t0))

	return csA, csB, csC, csD
end

local function matrixSum(np, dim, csA, csB, csC, csD)
	local t0 = os.clock()

	local res = CellularSpace {
		xdim = dim
	}

	function sum(i)
		for j = 0, dim - 1 do
			res:get(i, j).value = csA:get(i, j).value + csB:get(i, j).value
								+ csC:get(i, j).value + csD:get(i, j).value
		end
	end

	hpa:np(np)

	local t1 = os.clock()

	for i = 0, dim - 1 do
		hpa:parallel("sum(i)", i)
	end

	hpa:joinall()

	io.flush()
	local t2 = os.clock()

	print(string.format("sum elapsed time (parallel): %.4f", t2 - t1))
	print(string.format("sum elapsed time (total): %.4f", t2 - t0))

	return res:sample().value
end

local np = hpa:np() - 1 -- time increase using all processors
local dim = 500

for n = 1, np do
	print("number of processors: "..n)
	local csA, csB, csC, csD = setupToSum(n, dim)
	collectgarbage("collect")
	local sample = matrixSum(n, dim, csA, csB, csC, csD)
	collectgarbage("collect")
	if sample ~= 4*dim then
		print("Error", sample, 4*dim)
		os.exit(1)
	end
end

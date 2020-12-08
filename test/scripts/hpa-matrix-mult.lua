do
	local hpa = HPA()

	local function setup(np, dim)
		local t0 = os.clock()

		local csA = CellularSpace {
			xdim = dim
		}

		local csB = CellularSpace {
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

		hpa:np(np)

		local t1 = os.clock()

		hpa:parallel("fillCsA()")
		hpa:parallel("fillCsB()")
		hpa:joinall()

		io.flush()
		local t2 = os.clock()

		print(string.format("setup elapsed time (parallel): %.3f", t2 - t1))
		print(string.format("setup elapsed time (total): %.3f", t2 - t0))	

		return csA, csB
	end

	local function matrixMultiplication(np, dim, csA, csB)
		local t0 = os.clock()

		hpa:np(np)

		local res = CellularSpace {
			xdim = dim
		}

		function multiply(i, j)
			res:get(i, j).value = 0
			for k = 0, dim - 1 do
				res:get(i, j).value = res:get(i, j).value +
									csA:get(i, k).value * csB:get(k, j).value
			end
		end

		local t1 = os.clock()

		for i = 0, dim - 1 do
			for j = 0, dim - 1 do
				hpa:parallel("multiply(i, j)", i, j)
			end
		end

		hpa:joinall()

		io.flush()
		local t2 = os.clock()

		print(string.format("multiplication elapsed time (parallel): %.3f", t2 - t1))
		print(string.format("multiplication elapsed time (total): %.3f", t2 - t0))
		return res:sample().value
	end

	local function matrixMultiplicationGranularity(np, dim, csA, csB)
		local t0 = os.clock()

		hpa:np(np)

		local res = CellularSpace {
			xdim = dim
		}

		function multiply(i)
			for j = 0, dim - 1 do
				res:get(i, j).value = 0
				for k = 0, dim - 1 do		
					res:get(i, j).value = res:get(i, j).value +
									csA:get(i, k).value * csB:get(k, j).value
				end
			end
		end

		local t1 = os.clock()

		for i = 0, dim - 1 do
			hpa:parallel("multiply(i)", i)
		end

		hpa:joinall()

		io.flush()
		local t2 = os.clock()

		print(string.format("mult granularity elapsed time (parallel): %.3f", t2 - t1))
		print(string.format("mult granularity elapsed time (total): %.3f", t2 - t0))
		return res:sample().value
	end

	local np = hpa:np() - 1 -- time increase using all processors
	if np > 3 then np = 3 end
	local dim = 150

	for n = 1, np do
		print("number of processors: "..n)
		local csA, csB = setup(n, dim)
		local sample1 = matrixMultiplication(n, dim, csA, csB)
		collectgarbage("collect")
		local sample2 = matrixMultiplicationGranularity(n, dim, csA, csB)
		collectgarbage("collect")
		if sample1 ~= sample2 then
			print("Error", sample1, sample2)
			os.exit(1)
		end
	end
end
collectgarbage("collect")

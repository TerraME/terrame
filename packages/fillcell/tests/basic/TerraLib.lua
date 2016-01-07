return {
	TerraLib = function(unitTest)
		local t1 = TerraLib{}
		local t2 = TerraLib{}
		
		unitTest:assertEquals(t1, t2)
	end,
	init = function(unitTest)
		unitTest:assert(true)
	end,
	finalize = function(unitTest)
		-- TODO: THIS TEST IS IMPORTANT
		unitTest:assert(true)
	end,
	createProject = function(unitTest)
		unitTest:assert(true)
	end,
	openProject = function(unitTest)
		unitTest:assert(true)
	end,
	-- getProjectInfo = function(unitTest)
		-- unitTest:assert(true) -- SKIP
	-- end,
	-- getLayersNames = function(unitTest)
		-- unitTest:assert(true) -- SKIP
	-- end,
	-- getLayerInfo = function(unitTest)
		-- unitTest:assert(true) -- SKIP
	-- end,
	addShpLayer = function(unitTest)
		unitTest:assert(true)
	end,
	addTifLayer = function(unitTest)
		unitTest:assert(true)
	end,
	layerExists = function(unitTest)
		unitTest:assert(true)
	end,	
	addShpCellSpaceLayer = function(unitTest)
		unitTest:assert(true)
	end
}
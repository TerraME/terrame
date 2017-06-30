-- @example Amazonia deforestation models. It uses a top-down approach
-- with three strategies to compute deforestation potential.
-- The first strategy compute the deforestation potential based on
-- the deforestation of neighbor cells. The second one uses the result
-- of a statistical regression using distance to urban areas, connection
-- to markets, and coverage of protected areas as parameters.
-- The last strategies mixes the other two. It adds the average deforestation
-- of the neighborhood to the statistical regression.
-- @image deforestation.png

local function calculatePotNeighborhood(cs)
	local total_pot = 0

	forEachCell(cs, function(cell)
		cell.pot = 0
		local countNeigh = 0

		if cell.defor < 1.0 then
			forEachNeighbor(cell, function(neigh)
				-- The potential of change for each cell is
				-- the average of neighbors deforestation.
				-- fully deforested cells have zero potential
				cell.pot = cell.pot + neigh.defor
				countNeigh = countNeigh + 1
			end)

			if cell.pot > 0 then
				-- increment the total potential
				cell.pot = cell.pot / countNeigh
				total_pot = total_pot + cell.pot
			end
		end
	end)

	return total_pot
end

local function calculatePotRegression(cs)
	local total_pot = 0

	-- The potential for change is the residue of a
	-- linear regression between the cell's
	-- current and expected deforestation
	forEachCell(cs, function(cell)
		cell.pot = 0

		if cell.defor < 1.0 then
			expected =  - 0.150 * math.log(cell.distroads)
			            - 0.048 * cell.protected
			            - 0.060 * math.log(cell.distports)
			            + 2.7

			if expected > cell.defor then
				cell.pot = expected - cell.defor
				total_pot = total_pot + cell.pot
			end
		end
	end)

	return total_pot
end

local function calculatePotMixed(cs)
	local total_pot = 0

	forEachCell(cs, function(cell)
		cell.pot = 0
		cell.ave_neigh = 0

		-- Calculate the average deforestation
		countNeigh = 0
		forEachNeighbor(cell, function(neigh)
			-- The potential of change for each cell is
			-- the average of neighbors' deforestation.
			if cell.defor < 1.0 then
				cell.ave_neigh = cell.ave_neigh + neigh.defor
				countNeigh = countNeigh + 1
			end
		end)

		-- find the average deforestation
		if cell.defor < 1.0 then
			cell.ave_neigh = cell.ave_neigh / countNeigh
		end

		-- Potential for change
		if cell.defor < 1.0 then
			expected =    1.056 * cell.ave_neigh
						- 0.035 * math.log(cell.distroads)
						+ 0.018 * math.log(cell.distports)
						- 0.051 * cell.protected
						+ 0.059

			if expected > cell.defor then
				cell.pot = expected - cell.defor
				total_pot = total_pot + cell.pot
			end
		end
	end)

	return total_pot
end

Amazonia = Model{
	finalTime = 2040,
	allocation = 10000, -- km^2
	area = 50 * 50, -- km^2
	limit = 30, -- km^2
	potential = Choice{"neighborhood", "regression", "mixed"},
	init = function(model)
		if model.potential == "neighborhood" then
			model.potential = calculatePotNeighborhood
		elseif model.potential == "regression" then
			model.potential = calculatePotRegression
		else
			model.potential = calculatePotMixed
		end

		model.cell = Cell{
			init = function(cell)
				cell.defor = cell.defor / 100
			end
		}

		model.amazonia = CellularSpace{
			file = filePath("amazonia.shp"),
			instance = model.cell,
			as = {
				defor = "prodes_10"
			}
		}

		model.amazonia:createNeighborhood()

		model.map = Map{
			target = model.amazonia,
			select = "defor",
			slices = 10,
			min = 0,
			max = 1,
			color = "RdYlGn",
			invert = true
		}

		model.deforest = function(cs, total_pot)
			-- ajust the demand for each cell so that
			-- the maximum demand for change is 100%
			-- adjust the demand so that excess demand is
			-- allocated to the remaining cells
			-- there is an error limit (30 km2 as default)
			local total_demand = model.allocation

			while total_demand > model.limit do
				forEachCell(cs, function(cell)
					newarea = (cell.pot / total_pot) * total_demand
					cell.defor = cell.defor + newarea / model.area
					if cell.defor >= 1 then
						total_pot = total_pot - cell.pot
						cell.pot = 0
						excess = (cell.defor - 1) * model.area
						cell.defor = 1
					else
						excess = 0
					end
					-- adjust the total demand
					total_demand = total_demand - (newarea - excess)
				end)
			end
		end

		model.traj = Trajectory{
			target = model.amazonia,
			select = function(cell) return cell.pot > 0 end,
			greater = function (cell1, cell2) return cell1.pot > cell2.pot end,
			build = false
		}

		model.timer = Timer{
			Event{start = 2005, action = function()
				local total_pot = model.potential(model.amazonia)
				model.traj:rebuild()
				model.deforest(model.traj, total_pot)
			end},
			Event{start = 2004, action = model.map}
		}
	end
}

scenario1 = Amazonia{}

scenario1:run()


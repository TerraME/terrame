-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-------------------------------------------------------------------------------------------

return {
	random = function(unitTest)
		local mt = TerraLib().random().MersenneTwister(1)
		unitTest:assertEquals(mt(), 1791095845.0)
		unitTest:assertEquals(mt(), -12091157.0)
		unitTest:assertEquals(mt(), -1201197172.0)
		unitTest:assertEquals(mt(), -289663928.0)
		unitTest:assertEquals(mt(), 491263.0)

		local nd = TerraLib().random().NormalDistribution(mt, 1, 6)
		unitTest:assertEquals(tostring(nd()), "4.7151483786373")
		unitTest:assertEquals(tostring(nd()), "2.5726576432307")
		unitTest:assertEquals(tostring(nd()), "-3.8409899443622")
		unitTest:assertEquals(tostring(nd()), "5.5080297971463")
		unitTest:assertEquals(tostring(nd()), "10.036695820812")

		local lnd = TerraLib().random().LogNormalDistribution(mt, 1, 6)
		unitTest:assertEquals(tostring(lnd()), "0.53320690362806")
		unitTest:assertEquals(tostring(lnd()), "0.27052591194277")
		unitTest:assertEquals(tostring(lnd()), "0.035485398109431")
		unitTest:assertEquals(tostring(lnd()), "0.68541231059635")
		unitTest:assertEquals(tostring(lnd()), "2.876358760925")

		local dd = TerraLib().random().DiscreteDistribution(mt, {1, 2, 3, 4, 5, 6})
		unitTest:assertEquals(dd(), 3.0)
		unitTest:assertEquals(dd(), 5.0)
		unitTest:assertEquals(dd(), 1.0)
		unitTest:assertEquals(dd(), 2.0)
		unitTest:assertEquals(dd(), 2.0)

		local uid = TerraLib().random().UniformIntDistribution(mt, 1, 6)
		unitTest:assertEquals(uid(), 1.0)
		unitTest:assertEquals(uid(), 2.0)
		unitTest:assertEquals(uid(), 6.0)
		unitTest:assertEquals(uid(), 1.0)
		unitTest:assertEquals(uid(), 2.0)

		local urd = TerraLib().random().UniformRealDistribution(mt, 1, 6)
		unitTest:assertEquals(tostring(urd()), "1.6406222388614")
		unitTest:assertEquals(tostring(urd()), "2.5116628387477")
		unitTest:assertEquals(tostring(urd()), "5.9952025769744")
		unitTest:assertEquals(tostring(urd()), "1.7337794627529")
		unitTest:assertEquals(tostring(urd()), "2.18044488132")

		local wd = TerraLib().random().WeibullDistribution(mt, 1, 6)
		unitTest:assertEquals(tostring(wd()), "0.82265148355886")
		unitTest:assertEquals(tostring(wd()), "2.1600764871354")
		unitTest:assertEquals(tostring(wd()), "41.69468572402")
		unitTest:assertEquals(tostring(wd()), "0.95225758335771")
		unitTest:assertEquals(tostring(wd()), "1.6158237460576")

		local bd = TerraLib().random().BernoulliDistribution(mt, 0.5)
		unitTest:assert(bd())
		unitTest:assert(bd())
		unitTest:assert(not bd())
		unitTest:assert(bd())
		unitTest:assert(bd())

		local pd = TerraLib().random().PoissonDistribution(mt, 1.0)
		unitTest:assertEquals(pd(), 0.0)
		unitTest:assertEquals(pd(), 0.0)
		unitTest:assertEquals(pd(), 5.0)
		unitTest:assertEquals(pd(), 0.0)
		unitTest:assertEquals(pd(), 0.0)

		local ed = TerraLib().random().ExponentialDistribution(mt, 1.0)
		unitTest:assertEquals(tostring(ed()), "0.65314414116404")
		unitTest:assertEquals(tostring(ed()), "0.27995804155729")
		unitTest:assertEquals(tostring(ed()), "0.70171066758756")
		unitTest:assertEquals(tostring(ed()), "0.81248823021991")
		unitTest:assertEquals(tostring(ed()), "1.9455296925014")

		local betad = TerraLib().random().BetaDistribution(1, 6)
		unitTest:assertEquals(tostring(betad(0.1)), "0.01740680614731")
		unitTest:assertEquals(tostring(betad(0.25)), "0.046815707003063")
		unitTest:assertEquals(tostring(betad(0.5)), "0.10910128185966")
		unitTest:assertEquals(tostring(betad(0.75)), "0.2062994740159")
		unitTest:assertEquals(tostring(betad(0.9)), "0.31870793094204")
	end
}
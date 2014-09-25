-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP -- www.terrame.org
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
-- Authors: 
--      Antonio Gomes de Oliveira Junior
--      Pedro R. Andrade
--      Raian Vargas Maretto
-------------------------------------------------------------------------------------------

-- TODO: alow UnitTest.lua to use print_red from terrame.lua directly, removing the lines below
local begin_red = "\027[00;31m"
local end_color = "\027[00m"

local function print_red(value)
    if sessionInfo().separator == "/" then
        print(begin_red..value..end_color)
    else
        print(value)
    end
end

UnitTest_ = {
	type_ = "UnitTest",
	success = 0,
	fail = 0,
	test = 0,
	last_error = "",
	count_last = 0,
	print_error = function(self, msg)
		local info = debug.getinfo(3)
		local str = string.match(info.short_src, "[^/]*$")
		str = str..":".. info.currentline ..": "..msg
		if self.last_error == str then
			self.count_last = self.count_last + 1
		elseif self.count_last > 0 then
			print_red("[The error above occurs more "..self.count_last.." times.]")
			self.count_last = 0
			self.last_error = str
		else
			self.last_error = str
		end

		if self.count_last == 0 then
			print_red(str)
		end
	end,
	assert = function(self, value)
		self.test = self.test + 1
		if value then
			self.success = self.success + 1
		else
			self:print_error("Test should be true got false.")
			self.fail = self.fail + 1
		end
	end,	
	assert_type = function (self, value, mtype)
		self.test = self.test + 1
		if type(value) == mtype then
			self.success = self.success + 1
		else
			self:print_error("Test should be "..mtype.." got "..type(value)..".")
			self.fail = self.fail + 1
		end
	end,	
	assert_nil = function(self, value)
		self.test = self.test + 1
		if value == nil then
			self.success = self.success + 1
		else
			print_red("Test should be nil, got "..type(value)..".")
			self.fail = self.fail + 1
		end
	end,
	assert_not_nil = function (self, value)
		self.test = self.test + 1
		if value ~= nil then
			self.success = self.success + 1
		else
			print_red("Test should not be nil.")
			self.fail = self.fail + 1
		end
	end,
	assert_equal = function (self, v1, v2, tol)
		self.test = self.test + 1

		if tol == nil then tol = 0 end

		if type(v1) == "number" and type(v2) == "number" then
			if v1 <= v2 + tol and v1 >= v2 - tol then
				self.success = self.success + 1
			else 
				self:print_error("Values should be equal, but got '"..v1.."' and '"..v2.."'.")
				self.fail = self.fail + 1
			end
		elseif type(v1) == "string" and type(v2) == "string" then
			if v1 == v2 then
				self.success = self.success + 1
			else 
				self:print_error("Values should be equal, but got '"..v1.."' and '"..v2.."'.")
				self.fail = self.fail + 1
			end
		elseif type(v1) ~= type(v2) then
				self.fail = self.fail + 1
			self:print_error("Values should be equal, but they have different types ("..type(v1).." and "..type(v2)..").")
		elseif v1 ~= v2 then
				self.fail = self.fail + 1
			self:print_error("Values have the same type ("..type(v1)..") but different values.")
		else
			self.success = self.success + 1
		end
	end,
	assert_error = function (self, my_function, error_message)
		self.test = self.test + 1

		local _, err = pcall(my_function)
		if not err then
			self:print_error("Test expected an error ('"..error_message.."'), but no error was found.", 2)
			self.fail = self.fail + 1
		else
			local shortErrorMsg = string.match(err, ":[0-9]*:.*")

			-- TODO: verificar se tem como pegar o nome do arquivo e verificar se o erro nao ocorre
			-- em um dos arquivos internos. na verdade o erro tem que ocorrer no arquivo que foi
			-- carregado. descobrir este erro eh importante para verificar se o level foi usado corretamente.
			if shortErrorMsg == nil then
				self.fail = self.fail + 1
				self:print_error("Error should contain line number (possibly wrong level), got: '"..err.."'.")
				return
			end

			shortErrorMsg = string.gsub(shortErrorMsg,":[0-9]*: ", "")

			local distance = levenshtein(error_message, shortErrorMsg)

			if distance == 0 then
				self.success = self.success + 1
			else
				self.fail = self.fail + 1
				self:print_error("Test expected:\n  '"..error_message.."'\n  got:\n  '"..shortErrorMsg.."'")
			end
		end
	end
}

local metaTableUnitTest_ = {
	__index = UnitTest_
}

function UnitTest(data)
	setmetatable(data, metaTableUnitTest_)

	if data.dbType ~= nil then
		data.dbType = string.lower(data.dbType)
	end

	checkUnnecessaryParameters(data, {"dbType", "host", "port", "password", "user"}, 3)

	return data
end


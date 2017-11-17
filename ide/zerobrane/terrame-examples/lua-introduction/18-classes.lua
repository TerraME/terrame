--[[ [previous](17-tables-with-functions.lua) | [contents](00-contents.lua) | [next](00-contents.lua)

**Classes**

Finally, we can declare a class in Lua by creating a function that takes a table
constructor as argument. This function typically initializes, checks properties
values and adds auxiliary data structure or methods. For instance, the next
example builds the type _MyLocation_:

]]

function MyLocation(locdata)
	locdata.covertype = "forest"
	locdata.deforPot = function(self)
	      return 1 / (self.distRoad + self.distUrban)
	end

	return locdata
end

loc = MyLocation({distRoad = 0.3, distUrban = 2})

--[[

Lua provides a special syntax for function calls that take a table as argument.
We can ommit the parentheses when declaring a table to be used as argument of
a function, as shown below. This is the way we create objects in TerraME.

]]

loc = MyLocation{distRoad = 0.3, distUrban = 2}

-- or, in a more readable way:

loc = MyLocation{
	distRoad = 0.3,
	distUrban = 2
}

print(loc.covertype)
print(loc:deforPot())


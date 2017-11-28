--[[ [previous](15-arguments.lua) | [contents](00-contents.lua) | [next](17-tables-with-functions.lua)

**Higher-order function**

Functions can also be parameters to other functions. This kind of function is what
we call a higher-order function, a great source of flexibility on the language.
For example, TerraME provides function **forEachElement**, that applies a function
to each element of a given table. The function used as argument receives up to
three arguments (name/position of the value, the value itself, and a string with
its type), and is called once for each value of the table. For instance:

]]

x = {7, 3, 2, 6, 4}

forEachElement(x, function(position)
	print(position)
end)

--[[
It is important to note that the name of the argument in the second-order function
does not change original the semantics of the function. For example, if we
erroneously declare the function with arguments named (value, position), the
position will be stored in the argument value, while the value will be stored in
the argument position, which can cause confusion in the source code. See the
example below:

]] 

forEachElement(x, function(value, position)
	print(position, value)
end)


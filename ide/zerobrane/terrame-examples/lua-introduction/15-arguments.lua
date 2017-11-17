--[[ [previous](14-function-3.lua) | [contents](00-contents.lua) | [next](16-high-order-functions.lua)

**Parameters and arguments**

It is possible to call a function with a number of arguments different
from the number of parameters in its definition. Lua adjusts the number
of arguments to the number of parameters: Extra arguments are thrown
away; extra parameters get nil. For instance:

]]

function f(a, b)
	print(a, b)
end

f(3)
f(3, 4)
f(3, 4, 5) -- 5 is discarded

-- **Exercise:** What would happen to each of the three function calls above
-- if we replace function f() by the one below?

--[[

function f(a, b)
	print(a + b)
end

--]]


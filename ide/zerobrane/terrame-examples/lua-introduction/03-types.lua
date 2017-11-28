--[[ [previous](02-comments.lua) | [contents](00-contents.lua) | [next](04-nil.lua)

**Types**

This tutorial presents five lua types: nil, boolean, number, string, function,
and table. Every value in Lua has a type associated to it.

]]

print(type(nil))
print(type("a string!!"))
print(type(print))

--[[

On the other hand, variables do not have an explicit type. The type of a
variable is the type of the value it is currently storing.

]]

x = 2

print(type(x))

x = print

print(type(x))


-- **Exercise:** What is the output of the code below? Why?

--[[

print(type(type(print)))

--]]


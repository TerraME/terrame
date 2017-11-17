--[[ [previous](01-variables-values.lua) | [contents](00-contents.lua) | [next](03-types.lua)

**Comments**

A comment starts anywhere with a double hyphen (--) and runs until the end of
the line. Block comments start with --[[ and run until the corresponding ]]
--]]

print("hello1") -- my comment
-- print("hello2") -- no action (comment)

print("hello3")

--[[
print("hello4") -- no action (comment)
]]

print("hello5")

-- A common trick, when we want to comment out a piece of code, is to
-- use -- just before ]], as follows:

--[[
print("hello6") -- no action (comment)
--]]

-- Now, if we add a single empty space after -- in the beginning of the first
-- line, it becomes an end-of-line comment, and then the code is in again.
-- Note that, as the end of block comment now starts with --, it is not
-- necessary to remove it.

-- **Exercise:** comment and uncomment some print lines above and see the output.


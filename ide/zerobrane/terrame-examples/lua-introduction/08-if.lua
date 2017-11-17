--[[ [previous](07-string.lua) | [contents](00-contents.lua) | [next](09-for.lua)

**If**

Lua provides a small and conventional set of control structures. All control
structures have an explicit terminator: **end**. An if statement tests its
condition and executes its then-part accordingly.

]]

a = 8

if a < 10 then
	a = 0
end

--[[

Ifs can also include an else-part. In this case, the code will execute one
of two paths.

]]

b = 7

if a < b then
	a = 5
else
	a = b
end

print(a) -- What's the value of 'a'?

--[[

When you write nested ifs, you can use **elseif**. It is similar to an else
followed by an if, but it avoids the need for multiple ends.

]]

if op == "+" then -- Note the warning here
	r = a + b
elseif op == "-" then -- And here as well
	r = a - b
else
	customError("invalid operation") -- And the error here
end

-- **Exercise:** What is the output of the code below?
--[[

a = 6
b = 5

if a < 0 then
	print("a < 0")
end

if a < b then print("a < b") else print("a >= b") end

if a < b then
	print("a < b")
elseif a < b + 5 then
	print("b <= a < b+5")
else
	print("a > b+5")
end

--]]


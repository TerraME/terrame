--[[ [previous](08-if.lua) | [contents](00-contents.lua) | [next](10-table.lua)

**For**

A numeric for has the following syntax:

for var = exp1, exp2, exp3 do
	something
end

That loop will execute _something_ for each value of _var_ from _exp1_ to _exp2_, using
_exp3_ as the step to increment _var_. This third expression is optional; when
absent, Lua assumes one as the step value.

-- **For programmers:** Lua has two other statements for repetitions:
-- repeat-until and while-do-end.
]]

-- print 1 to 10, one in each line
for i = 1, 10 do
	print(i)
end

-- print 1 to 10, all in the same line separated by commas
str = ""

for i = 1, 10 do
	str = str..", "..i
end

print(string.sub(str, 3)) -- why is string.sub() necessary?

-- print 1 to 10 with step 2
for i = 1, 10, 2 do
	print(i)
end

-- **Exercises:**
-- 1) Write a program that prints the next 20 leap years.
-- 2) Write a program to print all multiples of three or five from 1
--    to 100: 3, 5, 6, 9, 10, 12, 15, ..
-- 3) Print only the sum of the numbers of the last exercise.
-- 4) Write a function that computes the list of the first 100 Fibonacci numbers.
-- 5) Write a program that prints a multiplication table from 1 to 10.
-- 6) Write a program that prints all prime numbers from 1 to 1000.


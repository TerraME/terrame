--[[ [previous](11-tables-2.lua) | [contents](00-contents.lua) | [next](13-libraries.lua)

**Functions**

A function is a first-class value in Lua. It means that a function is a value
with the same rights as conventional values like numbers and strings. Functions
can be stored in variables and in tables, can be passed as arguments, and can
be returned by other functions, giving great flexibility to the language. A
function can carry out a specific task (commonly called procedure) or compute and
return values. In the first case, we use a function call as a statement; in the
second case, we use it as an expression:

]]

print(8 * 9, 9 / 8) -- a statement: not using the result of the function
a = math.sin(3) + math.cos(10) -- an expression: using the result of the function

myprint = print -- creating a new variable

print(myprint == print)

print = nil

-- print(5) -- try this function call here

myprint(2)

print = myprint

print(2)


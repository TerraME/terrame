--[[ [previous](06-number.lua) | [contents](00-contents.lua) | [next](08-if.lua)

**String**

String is a sequence of immutable characters. You cannot change a character
inside a string; instead, you create a new string with the desired
modifications. We can delimit literal strings by matching single (') or
double (") quotes. As a matter of style, you should use always the same kind
of quotes in a program, unless the string itself has quotes; then you use the
other quote, or escape those quotes with backslashes. We can concatenate
strings by using the operator ".." (two dots). If any of its operands is a
number, Lua converts that number to a string.

**For programmers:** Strings can contain escape sequences such as \n, \t, \\, and \".

]]

print("hello")
print('hello')
x = 2
print ("x = "..x)

-- **Exercise:** Why the output of the last line below is false as
-- print(value1) and print(value2) show the same value?

--[[

value1 = (3-1).."."..(24/6)
print(value1)
value2 = tonumber(value1)
print(value2)
print(value1 == value2)

--]]


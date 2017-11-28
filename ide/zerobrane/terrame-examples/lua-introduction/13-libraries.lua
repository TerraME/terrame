--[[ [previous](12-function.lua) | [contents](00-contents.lua) | [next](14-function-3.lua)

**Libraries**

Lua has a set of libraries to execute usual tasks, such as opening files,
handling strings, and executing mathematical operations. These functionalities
are stored in libraries, which are Lua tables. For example, **math** is a library
with mathematical functions. It has functions such as **math.rad** to compute
convert a value from degrees to radians.

]]

print(8*9, 9/8)

a = math.sin(3) + math.cos(10)

print(a)
print(os.time())
print(string.find("pattern", "tt"))

--[[
Examples of functions available in Lua libraries:

**math.sin, math.cos, math.tan, etc.**
Trigonometric functions, always working with radians.
Example:
math.sin(2 * math.pi)

**math.deg, math.rad**
Converts between degrees and radians.
Example:
math.deg(math.pi)

**math.exp, math.log, math.log10**
Exponentiation and logarithms.
Examples:
math.exp(1)
math.log(2.71)

**math.floor, math.ceil**
Rounding functions.
Example:
math.floor(2.3)

**math.max, math.min**
The maximum (minimum) of two numbers.
Example:
math.max(4, 7)

**string.upper, string.lower**
Upper (lower) case.
Example:
string.upper("moon")

**string.sub**
Cuts a string, from the i-th to the j-th character inclusive. The first character
of a string has index 1. Value -1 refers to the last character, -2 to the previous
one, and so on. If you do not provide a third argument, it has default -1.
Example:
s = "[in brackets]"
string.sub(s, 4)
string.sub(s, 2, 7)
string.sub(s, 2, -2)

**string.format**
Formats a string, with rules similar to those of the standard C printf function.
Example:
string.format("pi = %.4f", math.pi)

**string.gsub**
Replaces the occurrences of a given pattern inside of the subject string. Returns
the new string and the number of occurrences. An optional fourth parameter limits
the number of substitutions to be made.
Example:
string.gsub("Lua is cute", "cute", "great")
string.gsub("all lii", "l", "x", 1)

**table.insert**
Inserts an element in a given position of an array, moving up other elements to
open space and incrementing the size of the array.
Example:
a = {3, 7, 5}
table.insert(a, 1, 15)
table.insert(a, 3, 10)

**table.remove**
Removes (and returns) an element from a given position in an array, moving down
other elements. When called without a position, it removes the last element.
Example:
a = {3, 7, 5}
table.remove(a, 1)
table.remove(a)

**table.sort**
Orders the elements of a table according to an order function, that has two
arguments and must return true if the first argument should come first in the
sorted array. This function has the less-than operation (corresponding to
the `<´ operator) as default.
Example:
a = {3, 7, 4, 1, 2}
table.sort(a)
table.sort(a, function(v1, v2)
    return string.lower(v1) < string.lower(v2)
end)

**tostring**
Converts a number to a string.
Example:
tostring(12)

**tonumber**
Converts a string to a number.
Example:
tonumber("11")

--]]

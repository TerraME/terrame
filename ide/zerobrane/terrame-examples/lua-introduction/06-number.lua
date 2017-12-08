--[[ [previous](05-boolean.lua) | [contents](00-contents.lua) | [next](07-string.lua)

**Number**

Numbers represent real numbers. They can be written as integers (e.g. 52), as
real values (e.g. 3.14), or using scientific notation (e.g. 5e+2 for 500).
Besides the traditional arithmetic operators (+, -, *, /), Lua provides the
exponent (^) and the modulo (%) operators for working with number values.

**For programmers:** Numbers represent double-precision floating-point values.
Lua has no integer type, as it does not need it. There is a misconception about
floating-point arithmetic errors and some people fear that even a simple
increment can go weird with floating-point numbers. The fact is that when you
use a double to represent an integer, there is no rounding error at all (unless
the number is greater than 10^14). Specifically, a Lua number can represent any
long integer without rounding problems. Moreover, most modern CPUs do
floating-point arithmetic at least as fast as integer arithmetic. 

]]

A = 6 + 2.2 * 4e+3
a = A ^ 2
b = A % 7
print(a)
print(b)
print(a > b)
print(b ~= 2)


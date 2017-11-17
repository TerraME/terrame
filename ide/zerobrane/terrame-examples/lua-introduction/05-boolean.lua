--[[ [previous](04-nil.lua) | [contents](00-contents.lua) | [next](06-number.lua)

**Boolean**

Boolean is a type with two values, _false_ and _true_.
However, they do not hold a monopoly of condition values: In Lua, any value
may represent a condition. Conditionals consider **false and nil as false** and
anything else as true. There are three logical operators for working
with condition values: _and_, _or_, and _not_. Both _and_ and _or_ use short-cut
evaluation, evaluating their second operand only when necessary. The operator
and returns its first argument if it is false; otherwise, it returns its
second argument. The operator or returns its first argument if it is not
false; otherwise, it returns its second argument.

**For programmers:** Beware! Lua considers both zero and the empty string
as true in conditional tests.

]]

print(4 and 5) --> 5
print(nil and 13) --> nil
print(4 or 5) --> 4
print(false or 5) --> 5

-- **Exercise:** What is the output of the lines below? Execute the code
-- afterwards to check the correct outputs.
--[[

print(not true)
print(true or false)
print(true and (false or true))
print(false or (true and false) or (true and true))

--]]


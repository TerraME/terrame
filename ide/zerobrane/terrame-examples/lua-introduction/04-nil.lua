--[[ [previous](03-types.lua) | [contents](00-contents.lua) | [next](05-boolean.lua)

**Nil**

Nil is a type with a single value, **nil**, whose main property is to be
different from any other value, representing the absence of a useful
value. A variable has a nil value by default, before a first assignment,
and you can assign nil to a variable to delete it.

]]

print(c)
c = 10

print(type(c))
c = nil

print(type(c))

-- **Exercise:** What happens if the following code is executed?
-- [[

print = nil
print("hello")

--]]


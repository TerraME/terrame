--[[ [previous](13-libraries.lua) | [contents](00-contents.lua) | [next](15-arguments.lua)

**Declaring functions**

A function definition has a conventional syntax, with a name, a list of
parameters, a body (a list of statements), and the explicit terminator _end_.
For instance, the following code creates a function that sums two numbers:

]]

function add(a, b)
	return a + b
end

print(add(2, 3))

--[[

Because functions are first-class values, the code above is just an instance of
what we call syntactic sugar; in other words, it is just a pretty way to write

]]

add = function(a, b)
	return a + b
end

print(add(2, 3))

--[[

That is, a function definition is in fact a statement that assigns a value of
type function to a variable. We can see the expression function (...) ... end
as a function constructor, just as {} is a table constructor. Parameters of a
funcion are local variables, initialized with the arguments of the function call.

]]

a = 5
b = 2

print(add(a, a))

add = function(a, b)
	a = a + 1 -- updating the local a, not the one above (global)
	return a + b
end

print(add(a, a))
print(a)




--[[ [previous](09-for.lua) | [contents](00-contents.lua) | [next](11-tables-2.lua)

**Table**

Table is the only structured data type in Lua. It implements associative arrays,
which can be indexed not only with numbers, but also with strings or any other
value of the language, except nil. Moreover, tables have no fixed size; you can
add as many elements as you want dynamically. We use tables to represent ordinary
arrays, symbol tables, sets, records, queues, and other data structures, in a
simple, uniform, and efficient way.

Tables in Lua are neither values nor variables; they are dynamically allocated
objects which contain references (or pointers) to their fields. You create tables
by means of a constructor expression, which in its simplest form is written as {}.
We can access the values for tables by using [] with the position of the desired
element.

The most basic use of tables is to store arrays. There is no way to declare its
size; you just initialize the elements as you need. In this case, the first
element of the table is stored in position one.

]]

x = {7, 3, 2, 6, 4, 3, 9} -- this is an array with seven numbers

print(x[1]) -- printing the value of position one
x[1] = x[2] + x[3] -- updatig the value of position one
print(x[1])
print(x[x[4]]) -- what does this line do?

print(#x)

-- show the content of the whole table
for i = 1, #x do
	print(i.." "..x[i])
end

-- **Exercise:** What is the value of x[10]? Why?


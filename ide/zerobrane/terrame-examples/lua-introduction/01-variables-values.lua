--[[ [previous](00-contents.lua) | [contents](00-contents.lua) | [next](02-comments.lua)

Lua has a conventional sintax, having lots of similarities with other languages.
Lua is case sensitive, meaning that x and X are different variables. The
operator = is used to give values to variables. Each piece of code Lua executes
is a chunk. More specifically, a chunk is a sequence of statements. Line breaks
play no role in Lua's syntax.

**For programmers:** A semicolon may optionally follow any statement. Usually, I use
semicolons only to separate two or more statements written in the same line, but
this is just a convention. 

]]

a = 1 -- creates variable 'a' with value 1
b = a * 2 -- creates variable 'b' with 'a' times 2

print(a) -- show a in the screen
print(b) -- same for b


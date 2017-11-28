--[[ [previous](01-d-data.lua) | [contents](00-contents.lua) | [next](01-f-table.lua)

What is wrong with the code below?
Try to figure out the problem before executing the code.

]]

t = {w = {t = 1, v = 2, x = 3}, x = 5, v = {x = 7, y = 5, z = 3}}
print(t.v.y + t.x + t.w.u)


--[[ [previous](06-counting.lua) | [contents](00-contents.lua) | [next](08-criptography.lua)

Implement functions area() and perimeter(). The first one gets a geometrical
object as argument and returns its area. The second one also gets a
geometrical object and returns its perimeter.

]]

function area(object)
	-- implement here
end

function perimeter(object)
	-- implement here
end

square1 = {side = 5}
square2 = {side = 20}
rectangle1 = {side1 = 10, side2 = 5}
rectangle2 = {side1 = 7, side2 = 8}
circle1 = {radius = 5}
circle2 = {radius = 15}
triangle1 = {side1 = 3, side2 = 4, side3 = 5}

-- Tip: first call area() and perimeter() for individual objects
-- print(area(square1)) print(perimeter(square1))
-- print(area(rectangle1)) print(perimeter(rectangle1))
-- ...

objects = {
	square1, square2, rectangle1, rectangle2, circle1, circle2, triangle1
}

for i = 1, #objects do
	print(i, area(objects[i]), perimeter(objects[i]))
end



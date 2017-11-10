--[[ [previous](01-p-function.lua) | [contents](00-contents.lua) | [next](03-function.lua)

Given function zoo() below, call it several times with different values as arguments
in such a way that the seven "Founds" are shown. See an example in the bottom.

]]

function zoo(a, b, c, d)
	if a > b and c > d then
		if a > d then
			if b > d then
				print("Found 1")
			elseif b == 4 and d == 5 then
				print("Found 2")
             end
         elseif c == 3 and a == b + 2 then
             print("Found 3")
         elseif d == 5 and a == 3 then
             print("Found 4")
         end
     elseif a == 3 * b + 2 - c and b == 5 and c > 3 then
         print("Found 5")
     elseif a == b + c - 4 * d and b == a + c + d then
         print("Found 6")
     else
         print("Found 7")
     end
end

zoo(2, 1, 1, 0) -- "Found 1"


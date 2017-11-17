--[[ [previous](16-high-order-functions.lua) | [contents](00-contents.lua) | [next](18-classes.lua)

**Tables with functions**

Tables also can have operations:

]]

loc = {cover = "forest", distRoad = 0.3, distUrban = 2}
loc.deforestPot = function()
	return 1 / (loc.distRoad + loc.distUrban)
end

--[[

This definition creates a new function and stores it in the field deforestPot of
the loc object. Then, we can call it as

]]

print(loc.deforestPot())

--[[

This kind of function is almost what we call a method. However, the use of the
name loc inside the function is a bad programming practice. First, this function
will work only for this particular object. Second, even for this particular
object the function will work only as long as the object is stored in that
particular variable; if we change the name of this object, deforestPot does not
work any more:

]]

a = loc
loc = nil
a.deforestPot() -- ERROR!

--[[

Such behaviour violates the principle that objects have independent life cycles.
A more flexible approach is to operate on the receiver of the operation. For
that, we would have to define our method with an extra parameter, which tells
the method on which object it has to operate. This parameter usually has the
name self or this:

]]

loc. deforestPot = function(self)
	return 1 / (self.distRoad + self.distUrban)
end

--[[

Now, when we call the method we have to specify on which object it has to operate:

]]

a1 = loc
loc = nil
a1.deforestPot(a1) -- OK

--[[

This use of a self parameter is a central point in any object-oriented language.
Most OO languages have this mechanism partly hidden from the programmer, so that
she does not have to declare this parameter. Lua can also hide this parameter,
using the colon operator. We can rewrite the previous method definition as

]]

function loc:deforestPot() return 1 / (self.distRoad + self.distUrban) end

-- and the method call as

loc:deforestPot()

--[[

The effect of the colon is to add an extra hidden parameter in a method
definition and to add an extra argument in a method call. The colon is only a
syntactic facility; there is nothing really new here. We can define a function
with the dot syntax and call it with the colon syntax, or vice-versa, as long
as we handle the extra parameter correctly.

]]

loc = {
	cover = "forest", 
	distRoad = 0.3, 
	distUrban = 2,
	deforestPot = function(myloc)
		return 1/(myloc.distRoad + myloc.distUrban)
	end
}

print(loc.deforestPot(loc))
print(loc:deforestPot()) -- avoiding loc itself as argument


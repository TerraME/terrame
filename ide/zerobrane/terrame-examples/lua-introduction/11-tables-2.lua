--[[ [previous](10-table.lua) | [contents](00-contents.lua) | [next](12-function.lua)

**Named tables**

It is possible to give names to the values of a table. For example, the code below
create a table 'location' with three values: 'cover', 'distRoad', and 'distUrban'.

]]

location = {
	cover = "forest",
	distRoad = 0.3,
	distUrban = 2
}

print(location["cover"])
print(location["distRoad"] + location["distUrban"])

--[[

To simplify the access to table records, Lua provides a.name as syntactic sugar
for a["name"]. For Lua, the two forms are equivalent and can be intermixed freely;
but for a human reader, each form may signal a different intention. So, we could
write the last lines of the previous example in a cleanlier manner:

]]

print(location.cover)
print(location.distRoad + location.distUrban)

-- Table values can be updated, and new attributes can be created:

location.distRoad = location.distRoad ^ 2
location.distTotal = location.distRoad + location.distUrban

print(location.distTotal)

location.deforestationPot = 1/location.distTotal

print(location.deforestationPot)

-- Tables can also store tables internally:
location = {
    cover = "forest",
    dist = {road = 0.3, urban = 2}
}

print(location.dist.road)

location.dist.total = location.dist.road + location.dist.urban
print(location.dist.total)

-- **Exercise:** How to erase a value within a table?


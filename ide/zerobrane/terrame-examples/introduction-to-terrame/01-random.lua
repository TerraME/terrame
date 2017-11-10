--[[ [previous](00-contents.lua) | [contents](00-contents.lua) | [next](02-cell.lua) ]]

-- Bernoulli distribution:
bernoulli = Random{p = 0.4}
print(bernoulli:sample()) -- true (40%) or false (60%)

-- Continuous uniform distribution:
range = Random{min = 3, max = 7}
print(range:sample()) -- a value between 3 and 7

-- Categorical distribution with probabilities associated to values:
gender = Random{male = 0.49, female = 0.51}
print(gender:sample()) -- "male" (49%) or "female" (51%)

-- Discrete distribution:
cover = Random{"pasture", "forest", "clearcut"}
print(cover:sample()) -- "pasture", "forest", or "clearcut" (33.33% for each)

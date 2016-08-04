-- module highlighting
-- local M = {}
local string, table = string, table

local patterns = {
	{"^(%s+)"},                   -- spaces
	{"^(([\"\']).-%2)","string"}, -- string
	{"^([%a_][%w_]*)", "id"},     -- id
	{"^(%-%-[^\n]+)", "comment"},     -- comment
	{"^(%d*[%.%-%+]?%d+[eE]?)", "number"},    -- number
	{"^(.)"}                      -- other
}

local reserved = {
		"and",       "break",     "do",        "else",      "elseif",
		"end",       "false",     "for",       "function",  "if",
		"in",        "local",     "nil",       "not",       "or",
		"repeat",    "return",    "then",      "true",      "until",
		"while"
}

local base = {
	"Agent", "Automaton", "Cell", "CellularSpace", "Chart", "Choice",
	"Clock", "Environment", "Event", "File", "Flow", "Group", "InternetSender",
	"Jump", "LogFile", "Mandatory", "Map", "Model", "Neighborhood",
	"Random", "SocialNetwork", "Society", "State", "TextScreen",
	"Timer", "Trajectory", "UnitTest", "VisualTable"
}

words = {}

for _, j in ipairs(reserved) do
	reserved[j] = j
end

for _, j in ipairs(base) do
	base[j] = j
end

function parse(text, func)
	local code = {}
	while #text > 0 do
		local ending, token
		for i = 1, #patterns do
			_, ending, token = text:find(patterns[i][1])
			if token then 
				local class = patterns[i][2]

				if func == "#" and token == "#" then
					token = string.format("<span class=\"function\">#</span>")
				elseif class then
					if class == "id" then
						if reserved[token] then
							class = "reserved"
						elseif words[token] then
							class = "function"
						elseif base[token] then
							class = "function"
						end
					end

					if token == func then
						class = "function"
					end

					token = string.format("<span class=\"%s\">%s</span>",
																	class, token)
				end
				break
			end
		end
		text = text:sub(ending + 1)
		table.insert(code, token) 
	end
	return table.concat(code, "")
end

function setWords(lwords)
	words = lwords or {}
end

function getBase()
	return base
end

-- return M


-- module highlighting
local M = {}

local patterns = {
  {"^(%s+)"},                   -- spaces
  {"^(([\"\']).-%2)","string"}, -- string
  {"^([%a_][%w_]*)", "id"},     -- id
  {"^(%-%-[^\n]+)", "comment"},     -- comment
  {"^([%.%-]?%d+)", "number"},    -- number
  {"^(.)"}                      -- other
}

local reserved = {
    "and",       "break",     "do",        "else",      "elseif",
    "end",       "false",     "for",       "function",  "if",
    "in",        "local",     "nil",       "not",       "or",
    "repeat",    "return",    "then",      "true",      "until",
    "while"
}

M.words = {}

for i,j in ipairs(reserved) do
  reserved[j] = j
end

function M.parse(text)
  local code = {}
  while #text > 0 do
    local start, ending, token
    for i = 1, #patterns do
      start, ending, token = text:find(patterns[i][1])
      if token then 
        local class = patterns[i][2]
        if class then
          if class == "id" then
            if reserved[token] then
              class = "reserved"
            elseif M.words[token] then
              class = "function"
            end
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

function M.setWords(words)
  M.words = words or {}
end

return M



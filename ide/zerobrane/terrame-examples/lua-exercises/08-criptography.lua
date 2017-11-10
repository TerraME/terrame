--[[ [previous](07-geometry.lua) | [contents](00-contents.lua) | [next](00-contents.lua)

Given the string 'text'below, could you say what is written in portuguese?
Tips:
- Use functions string.byte(), string.char(), string.sub() e string.len().
- All the letters are in lower case.
- Spaces between words are really spaces.

]]

text = "gw gurgtq swg xqeg pcq vgpjc fguetkrvqitchcfq vqfc guvc uvtkpi ocpwcnogpvg rqtswg cngo fg owkvq fgoqtcfq ugtkc vqvcnogpvg gpvgfkcpvg"

-- Tip:
for i = 1, string.len(text) do
	print(string.byte(string.sub(text, i, i)))
end


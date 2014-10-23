-----------------------------------------------------------------
-- LuaDoc debugging facilities.
-- @release $Id: debug.lua,v 1.3 2007/04/18 14:28:39 tomas Exp $
-----------------------------------------------------------------

function printline()
	print(string.rep('-', 79))
end

-----------------------------------------------------------------
-- Print debug information about document
-- @param doc Table with the structured documentation.

function start (doc)
	print("Files:")
	for _, filepath in ipairs(doc.files) do
		print('\t', filepath)
	end
	printline()

	print("Modules:")
	for _, modulename in ipairs(doc.modules) do
		print('\t', modulename)
	end
	printline()
	
	forEachOrderedElement(doc.files, function(i, v)
		print('\t', i, v)
	end)
	printline()

	forEachOrderedElement(doc.files[doc.files[1]], function(i, v)
		print(i, v)
	end)
	printline()

	forEachOrderedElement(doc.files[doc.files[1]].doc[1], function(i, v)
		print(i, v)
	end)
	printline()

	print("Params")
	forEachOrderedElement(doc.files[doc.files[1]].doc[1].param, function(i, v)
		print(i, v)
	end)
end

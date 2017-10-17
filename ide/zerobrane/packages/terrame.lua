local win = ide.osname == "Windows"
local unix = ide.osname == "Macintosh" or ide.osname == "Unix"
local terrame
local id1 = ID("maketoolbar.makemenu1")
local id2 = ID("maketoolbar.makemenu2")
local id3 = ID("maketoolbar.makemenu3")
local id4 = ID("maketoolbar.makemenu4")
local id5 = ID("maketoolbar.makemenu5")
local id6 = ID("maketoolbar.makemenu5")

local function split(text, delim)
    -- returns an array of fields based on text and delimiter (one character only)
    local result = {}
    local magic = "().%+-*?[]^$"

    if delim == nil then
        delim = "%s"
    elseif string.find(delim, magic, 1, true) then
        -- escape magic
        delim = "%"..delim
    end

    local pattern = "[^"..delim.."]+"
    for w in string.gmatch(text, pattern) do
        table.insert(result, w)
    end
    return result
end

local function package(directory)
    local directories

	if win then
		directories = split(directory, "\\")
	else
		directories = split(directory, "/")
	end

    for i = #directories, 1, -1 do
		local md = directories[i]
        if md == "lua" or md == "tests" or md == "examples" or md == "data" then
            return directories[i - 1]
        end
    end

	return directories[#directories]
end

return {
	name = "TerraME-commands",
	description = "TerraME interpreter",
	author = "Pedro Andrade, Rodrigo Avancini",
	version = "2.0",
	api = {"baselib", "terrame"},
	onRegister = function(self)
		local menu = ide:FindTopMenu("&Project")
		menu:AppendSeparator()
		menu:Append(id1, "Package Manager\tCtrl-Shift-P")
		menu:AppendSeparator()
		menu:Append(id2, "Build Documentation\tCtrl-Shift-D")
		menu:Append(id3, "Documentation Sketch\tCtrl-Shift-S")
		menu:Append(id4, "View Documentation\tCtrl-Shift-V")
		menu:Append(id5, "Run tests\tCtrl-Shift-T")
		menu:Append(id6, "Check package\tCtrl-Shift-C")

		function myConnect(id, command)
			ide:GetMainFrame():Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, function()
				local ed = ide:GetEditor()
				if not ed then return end -- all editor tabs are closed
	
				local file = ide:GetDocument(ed):GetFilePath()
				self:frun(wx.wxFileName(file), command)
			end)
		end

		myConnect(id1)
		myConnect(id2, "doc")
		myConnect(id3, "sketch")
		myConnect(id4, "showdoc")
		myConnect(id5, "test")
		myConnect(id6, "check")
	end,
	onUnRegister = function(self)
		ide:RemoveMenuItem(id1)
		ide:RemoveMenuItem(id2)
		ide:RemoveMenuItem(id3)
		ide:RemoveMenuItem(id4)
		ide:RemoveMenuItem(id5)
	end,
	frun = function(self, wfilename, command)
		terrame = terrame or ide.config.path.terrame_install

		if not terrame then
			local executable = win and "\\terrame.exe" or "/terrame"
			-- path to TerraME
			terrame = os.getenv("TME_PATH")
			-- hack in Mac OS X
			if terrame == nil then
				terrame = "/Applications/terrame.app/Contents/bin"
			end

			local fopen = io.open(terrame..executable)
			if not fopen then
				DisplayOutputLn("Please define 'path.terrame_install' in your cfg/user.lua")
			else
				fopen:close()
			end
		end

		wx.wxSetEnv("TME_PATH", terrame)

		local cmd

		if command then
			cmd = terrame.."/terrame -package "..package(self:fworkdir(wfilename)).." -"..command
		else
			cmd = terrame.."/terrame"
		end
				DisplayOutputLn(cmd)

		local pid = CommandLineRun(cmd,self:fworkdir(wfilename).."/..",true,false, nil, nil, function() if rundebug then wx.wxRemoveFile(file) end end)
		return pid
	end,
	fprojdir = function(self,wfilename)
		return wfilename:GetPath(wx.wxPATH_GET_VOLUME)
	end,
	fworkdir = function (self,wfilename)
		return wfilename:GetPath(wx.wxPATH_GET_VOLUME)
	end,
	fattachdebug = function(self) DebuggerAttachDefault() end,
}

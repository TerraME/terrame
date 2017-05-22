local win = ide.osname == "Windows"
local unix = ide.osname == "Macintosh" or ide.osname == "Unix"
local terrame
local id1 = ID("maketoolbar.makemenu1")
local id2 = ID("maketoolbar.makemenu2")
local id3 = ID("maketoolbar.makemenu3")

return {
	name = "TerraME-doc",
	description = "TerraME interpreter",
	author = "Tiago Carneiro, Pedro Andrade, Rodrigo Avancini, Raian Maretto, Rodrigo Reis",
	version = "2.0",
	api = {"baselib", "terrame"},
	onRegister = function(self)
		local menu = ide:FindTopMenu("&Project")
		menu:AppendSeparator()
		menu:Append(id1, "Build Documentation\tCtrl-Shift-D")
		menu:Append(id2, "Documentation Sketch\tCtrl-Shift-S")
		menu:Append(id3, "View Documentation\tCtrl-Shift-V")

		function myConnect(id, command)
			ide:GetMainFrame():Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, function()
				local ed = ide:GetEditor()
				if not ed then return end -- all editor tabs are closed
	
				local file = ide:GetDocument(ed):GetFilePath()
				self:frun(wx.wxFileName(file), command)
			end)
		end

		myConnect(id1, "doc")
		myConnect(id2, "sketch")
		myConnect(id3, "showdoc")
	end,
	onUnRegister = function(self)
		ide:RemoveMenuItem(id1)
		ide:RemoveMenuItem(id2)
		ide:RemoveMenuItem(id3)
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

		local path = terrame.."/terrame -package "..self:fworkdir(wfilename).." -"..command

		local cmd = path -- .." ".."\""..self:fworkdir(wfilename).."/"..wfilename:GetFullName().."\""
		DisplayOutput(">>> "..cmd.." <<<")
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

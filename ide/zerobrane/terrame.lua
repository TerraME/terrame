local win = ide.osname == "Windows"
local unix = ide.osname == "Macintosh" or ide.osname == "Unix"
local terrame

return {
    name = "TerraME",
    description = "TerraME interpreter",
    author = "Tiago Carneiro, Pedro Andrade, Rodrigo Avancini, Raian Maretto, Rodrigo Reis",
    version = "2.0",
    api = {"baselib", "terrame"},
    frun = function(self,wfilename,rundebug)
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

        if rundebug then
            DebuggerAttachDefault({runstart = ide.config.debugger.runonstart == true})

            local tmpfile = wx.wxFileName()
            tmpfile:AssignTempFileName(".")
            filepath = tmpfile:GetFullPath()
            local f = io.open(filepath, "w")
            if not f then
                DisplayOutput("Can't open temporary file '"..filepath.."' for writing\n")
                return
            end
            f:write(rundebug)
            f:close()
        else
            -- if running on Windows and can't open the file, this may mean that
            -- the file path includes unicode characters that need special handling
            local tmpfile = wx.wxFileName()
            tmpfile:AssignTempFileName(".")
            filepath = tmpfile:GetFullPath()
            local fh = io.open(filepath, "r")
            if fh then fh:close() end
            if ide.osname == 'Windows' and pcall(require, "winapi")
                and wfilename:FileExists() and not fh then
                winapi.set_encoding(winapi.CP_UTF8)
                filepath = winapi.short_path(filepath)
            end
        end

        local path = win and (terrame..[[\terrame -ide -strict]])
                    or unix and (terrame.."/terrame -strict")
        local cmd = path.." ".."\""..self:fworkdir(wfilename).."/"..wfilename:GetFullName().."\""
        local pid = CommandLineRun(cmd,self:fworkdir(wfilename),true,false, nil, nil, function() if rundebug then wx.wxRemoveFile(file) end end)
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

local win = ide.osname == "Windows"
local unix = ide.osname == "Macintosh" or ide.osname == "Unix"

return {
    name = "TerraME",
    description = "TerraME interpreter",
    author = "Tiago Carneiro, Pedro Andrade, Rodrigo Avancini, Raian Maretto, Rodrigo Reis",
    version = "2.0",
    api = {"baselib", "terrame"},
    frun = function(self,wfilename,rundebug)
        if not ide.config.path.terrame_install then 
            DisplayOutputLn("Please define 'path.terrame_install' in your cfg/user.lua") 
            return 
        end
        wx.wxSetEnv("TME_PATH", ide.config.path.terrame_install)

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

        local path = win and ([[C:\TerraME\bin\terrame  -ide -mode=strict]]) 
                    or unix and (ide.config.path.terrame_install.."/terrame -mode=strict")
        local cmd = path.." "..self:fworkdir(wfilename).."/"..wfilename:GetFullName()    
        CommandLineRun(cmd,self:fworkdir(wfilename),true,false)
    end,
  
    fprojdir = function(self,wfilename)
        return wfilename:GetPath(wx.wxPATH_GET_VOLUME)
    end,
  
    fworkdir = function (self,wfilename)
        return wfilename:GetPath(wx.wxPATH_GET_VOLUME)
    end,
  
    hasdebugger = true,
    
    fattachdebug = function(self) DebuggerAttachDefault() end,
}
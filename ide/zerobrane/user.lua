--[[--
  Use this file to specify System preferences.
  Review [examples](+/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/cfg/user-sample.lua) or check [online documentation](http://studio.zerobrane.com/documentation.html) for details.
--]]--

-- Style preferences
local G = ...
styles = G.loadfile('cfg/tomorrow.lua')('Palleton')
stylesoutshell = styles -- also apply the same scheme to Output/Console windows

-- Editor preferences
editor.fontsize = 14 -- this is mapped to ide.config.editor.fontsize
editor.fontname = "Consolas"
-- to disable indicators (underlining) on function calls
-- styles.indicator.fncall = nil
-- to change the type of the indicator used for function calls
-- styles.indicator.fncall.st = wxstc.wxSTC_INDIC_HIDDEN
styles.indicator = {}

filehistorylength = 20 -- this is mapped to ide.config.filehistorylength

-- Output preferences
outputshell.fontname = "Consolas"-- set font name.
outputshell.fontsize = 14 -- set font size (the default value is 11 on OSX).

-- to have 4 spaces when TAB is used in the editor
editor.tabwidth = 4

-- to specify language to use in the IDE (requires a file in cfg/i18n folder)
language = "en"

-- Path to TerraME
-- Example:
-- path.terrame_install = "C:\\TerraME\\bin"

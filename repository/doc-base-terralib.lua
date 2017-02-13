-- Script to update the documentation of base and terralib
-- available at terrame.org.
-- 'terrame -color doc-base-terralib.lua'

-----------------------------------------------------------------------
local host = "ssh.dpi.inpe.br:"
local doc = "/home/www/terrame/packages/doc"
local repository = "/home/www/terrame/packages/"..sessionInfo().version
-----------------------------------------------------------------------

_Gtme.printNote("Updating documentation for version "..sessionInfo().version)

local basePath = sessionInfo().path.."/packages/base"
local terralibPath = sessionInfo().path.."/packages/terralib"

scp = "scp -r "..basePath.." "..terralibPath.." "
scp = scp..host..doc

_Gtme.print("\027[00;37;43m"..scp.."\027[00m")
os.execute(scp)

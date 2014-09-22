@C:\MinGW\msys\1.0\bin\pslist.exe -m -e TerraME > outputAux.txt
@REM @C:\MinGW\msys\1.0\bin\cat.exe outputAux.txt | C:\MinGW\msys\1.0\bin\awk '{print ($1, $4)}' > outputAux.txt 
@C:\MinGW\msys\1.0\bin\sed 4p -n outputAux.txt >> output_MemoryUsage.txt

@REM  Name                Pid      VM      WS    Priv Priv Pk   Faults   NonP Page

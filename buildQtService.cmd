call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"

cd ..

if exist buildQtService (
echo cleanup buildQtService
del /Q buildQtService\*
for /d %%x in (buildQtService\*) do @rd /s /q "%%x"
) else (
echo create buildQtService dir
mkdir buildQtService
)

echo current dir %CD%
echo cd buildQtService
cd buildQtService\

echo current dir %CD%
set PATH=%PATH%;C:\Qt\5.15.12\msvc2019_64\bin
set QMAKEPATH=C:\Users\frn9bh\source\repos\qdepservice
qmake ..\QtService\
nmake
nmake all
nmake install

pause

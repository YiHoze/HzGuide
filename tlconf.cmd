
@echo off

for /f "usebackq delims=" %%p in (`kpsewhich -var-value=TEXMFROOT`) do set tlroot=%%p
set tlroot=%tlroot:/=\%

if /i .%1. == .. goto help
if /i .%1. == .conf. goto conf
if /i .%1. == .texedit. goto texedit
if /i .%1. == .texmfhome. goto texmfhome
if /i .%1. == .sumatrapdf. goto SumatraPDF
if /i .%1. NEQ .batch. goto eof

:conf
REM checking if TeX Live is found
kpsewhich -var-value=TEXMFROOT >nul 2>&1
if errorlevel 1 (
echo TeX Live not on searchpath. Aborted.
exit /b
)

REM creating local.conf
set localconf=%tlroot%\texmf-var\fonts\conf\local.conf
set code=%LOCALAPPDATA%/Microsoft/Windows/Fonts
set code=%content:\=/%
set "code=^<dir^>%content%^</dir^>"
echo %content% > %localconf%
echo %localconf%:
type %localconf%
if /i .%1. NEQ .batch. goto eof

:texedit
if .%2. == .. (
setx TEXEDIT "code.exe -r -g ^"%%s:%%d^""
) else (
setx TEXEDIT "%2"
)
reg query HKEY_CURRENT_USER\Environment /v TEXEDIT
if /i .%1. NEQ .batch. goto eof

:texmfhome
if .%2. == .. (
setx TEXMFHOME "C:\home\texmf"
) else (
setx TEXMFHOME "%2"
)
reg query HKEY_CURRENT_USER\Environment /v TEXMFHOME
if /i .%1. NEQ .batch. goto eof

:SumatraPDF
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Classes\SumatraPDF.azw\DefaultIcon >nul 2>&1
if errorlevel 1 (
echo SumatraPDF is not found.
goto eof
) else (
for /f "usebackq tokens=3-4 delims=, " %%x in (`reg query  HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Applications\SumatraPDF.exe\DefaultIcon`) do set  sumatra="%%x %%y"
)
set sumatra=start "" %sumatra% -inverse-search
if .%2. == .. (
%sumatra% "code.exe -r -g ^"%%f:%%l^""
) else (
%sumatra% %2
)
goto eof

:help
set localconf=%tlroot%\texmf-var\fonts\conf\local.conf
echo %localconf%:
type %localconf%

echo.
echo.
echo tlconf.cmd conf             : Create local.conf with the user's local font directory.
echo tlconf.cmd texedit [...]    : Set the TEXEIDT environment variable. The default is
echo                               code.exe -r -g  "%%s:%%d"
echo tlconf.cmd texmfhome [...]  : Set the TEXMFHOME environment variable. The default is
echo                               C:\home\texmf
echo tlconf.cmd sumatrapdf [...] : Set the inverse search command-line option of SumatraPDF. The  default is
echo                               code.exe -r -g  "%%f:%%l"
echo tlconf.cmd batch            : Proceed with all options.

:eof
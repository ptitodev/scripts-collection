@echo off
if "%~1" equ ":probe" goto :probe
"%~f0" :probe %1 | findstr "\[.*]" | sort /+8
exit /b

:probe
setlocal disableDelayedExpansion
call :getChar %2 char
call :getChar 1A sub
for %%%% in ("") do for /f "tokens=1-31*" %%%char% in (
  "[01] [02] [03] [04] [05] [06] [07] [08] [09] [10] [11] [12] [13] [14] [15] [16] [17] [18] [19] [20] [21] [22] [23] [24] [25] [26] [27] [28] [29] [30] [31] [32]"
) do (
  echo \x01 = "%%"
  echo \x02 = "%%"
  echo \x03 = "%%"
  echo \x04 = "%%"
  echo \x05 = "%%"
  echo \x06 = "%%"
  echo \x07 = "%%"
  echo \x08 = "%%"
  echo \x09 = "%%	"
  echo \x0A = ^"%%^

"
  echo \x0B = "%%"
  echo \x0C = "%%"
  echo \x0E = "%%"
  echo \x0F = "%%"
  echo \x10 = "%%"
  echo \x11 = "%%"
  echo \x12 = "%%"
  echo \x13 = "%%"
  echo \x14 = "%%"
  echo \x15 = "%%"
  echo \x16 = "%%"
  echo \x17 = "%%"
  echo \x18 = "%%"
  echo \x19 = "%%"
  echo \x1A = "%%%sub%"
  echo \x1B = "%%"
  echo \x1C = "%%"
  echo \x1D = "%%"
  echo \x1E = "%%"
  echo \x1F = "%%"
  echo \x20 = "%% "
  echo \x21 = "%%!"
  echo \x22 = "%%""
  echo \x23 = "%%#"
  echo \x24 = "%%$"
  echo \x25 = "%%~%%"
  echo \x26 = "%%&"
  echo \x27 = "%%'"
  echo \x28 = "%%("
  echo \x29 = "%%)"
  echo \x2A = "%%*"
  echo \x2B = "%%+"
  echo \x2C = "%%,"
  echo \x2D = "%%-"
  echo \x2E = "%%."
  echo \x2F = "%%/"
  echo \x30 = "%%0"
  echo \x31 = "%%1"
  echo \x32 = "%%2"
  echo \x33 = "%%3"
  echo \x34 = "%%4"
  echo \x35 = "%%5"
  echo \x36 = "%%6"
  echo \x37 = "%%7"
  echo \x38 = "%%8"
  echo \x39 = "%%9"
  echo \x3A = "%%:"
  echo \x3B = "%%;"
  echo \x3C = "%%<"
  echo \x3D = "%%="
  echo \x3E = "%%>"
  echo \x3F = "%%?"
  echo \x40 = "%%@"
  echo \x41 = "%%A"
  echo \x42 = "%%B"
  echo \x43 = "%%C"
  echo \x44 = "%%D"
  echo \x45 = "%%E"
  echo \x46 = "%%F"
  echo \x47 = "%%G"
  echo \x48 = "%%H"
  echo \x49 = "%%I"
  echo \x4A = "%%J"
  echo \x4B = "%%K"
  echo \x4C = "%%L"
  echo \x4D = "%%M"
  echo \x4E = "%%N"
  echo \x4F = "%%O"
  echo \x50 = "%%P"
  echo \x51 = "%%Q"
  echo \x52 = "%%R"
  echo \x53 = "%%S"
  echo \x54 = "%%T"
  echo \x55 = "%%U"
  echo \x56 = "%%V"
  echo \x57 = "%%W"
  echo \x58 = "%%X"
  echo \x59 = "%%Y"
  echo \x5A = "%%Z"
  echo \x5B = "%%["
  echo \x5C = "%%\"
  echo \x5D = "%%]"
  echo \x5E = "%%^"
  echo \x5F = "%%_"
  echo \x60 = "%%`"
  echo \x61 = "%%a"
  echo \x62 = "%%b"
  echo \x63 = "%%c"
  echo \x64 = "%%d"
  echo \x65 = "%%e"
  echo \x66 = "%%f"
  echo \x67 = "%%g"
  echo \x68 = "%%h"
  echo \x69 = "%%i"
  echo \x6A = "%%j"
  echo \x6B = "%%k"
  echo \x6C = "%%l"
  echo \x6D = "%%m"
  echo \x6E = "%%n"
  echo \x6F = "%%o"
  echo \x70 = "%%p"
  echo \x71 = "%%q"
  echo \x72 = "%%r"
  echo \x73 = "%%s"
  echo \x74 = "%%t"
  echo \x75 = "%%u"
  echo \x76 = "%%v"
  echo \x77 = "%%w"
  echo \x78 = "%%x"
  echo \x79 = "%%y"
  echo \x7A = "%%z"
  echo \x7B = "%%{"
  echo \x7C = "%%|"
  echo \x7D = "%%}"
  echo \x7E = "%%~~"
  echo \x7F = "%%"
  echo \x80 = "%%�"
  echo \x81 = "%%�"
  echo \x82 = "%%�"
  echo \x83 = "%%�"
  echo \x84 = "%%�"
  echo \x85 = "%%�"
  echo \x86 = "%%�"
  echo \x87 = "%%�"
  echo \x88 = "%%�"
  echo \x89 = "%%�"
  echo \x8A = "%%�"
  echo \x8B = "%%�"
  echo \x8C = "%%�"
  echo \x8D = "%%�"
  echo \x8E = "%%�"
  echo \x8F = "%%�"
  echo \x90 = "%%�"
  echo \x91 = "%%�"
  echo \x92 = "%%�"
  echo \x93 = "%%�"
  echo \x94 = "%%�"
  echo \x95 = "%%�"
  echo \x96 = "%%�"
  echo \x97 = "%%�"
  echo \x98 = "%%�"
  echo \x99 = "%%�"
  echo \x9A = "%%�"
  echo \x9B = "%%�"
  echo \x9C = "%%�"
  echo \x9D = "%%�"
  echo \x9E = "%%�"
  echo \x9F = "%%�"
  echo \xA0 = "%%�"
  echo \xA1 = "%%�"
  echo \xA2 = "%%�"
  echo \xA3 = "%%�"
  echo \xA4 = "%%�"
  echo \xA5 = "%%�"
  echo \xA6 = "%%�"
  echo \xA7 = "%%�"
  echo \xA8 = "%%�"
  echo \xA9 = "%%�"
  echo \xAA = "%%�"
  echo \xAB = "%%�"
  echo \xAC = "%%�"
  echo \xAD = "%%�"
  echo \xAE = "%%�"
  echo \xAF = "%%�"
  echo \xB0 = "%%�"
  echo \xB1 = "%%�"
  echo \xB2 = "%%�"
  echo \xB3 = "%%�"
  echo \xB4 = "%%�"
  echo \xB5 = "%%�"
  echo \xB6 = "%%�"
  echo \xB7 = "%%�"
  echo \xB8 = "%%�"
  echo \xB9 = "%%�"
  echo \xBA = "%%�"
  echo \xBB = "%%�"
  echo \xBC = "%%�"
  echo \xBD = "%%�"
  echo \xBE = "%%�"
  echo \xBF = "%%�"
  echo \xC0 = "%%�"
  echo \xC1 = "%%�"
  echo \xC2 = "%%�"
  echo \xC3 = "%%�"
  echo \xC4 = "%%�"
  echo \xC5 = "%%�"
  echo \xC6 = "%%�"
  echo \xC7 = "%%�"
  echo \xC8 = "%%�"
  echo \xC9 = "%%�"
  echo \xCA = "%%�"
  echo \xCB = "%%�"
  echo \xCC = "%%�"
  echo \xCD = "%%�"
  echo \xCE = "%%�"
  echo \xCF = "%%�"
  echo \xD0 = "%%�"
  echo \xD1 = "%%�"
  echo \xD2 = "%%�"
  echo \xD3 = "%%�"
  echo \xD4 = "%%�"
  echo \xD5 = "%%�"
  echo \xD6 = "%%�"
  echo \xD7 = "%%�"
  echo \xD8 = "%%�"
  echo \xD9 = "%%�"
  echo \xDA = "%%�"
  echo \xDB = "%%�"
  echo \xDC = "%%�"
  echo \xDD = "%%�"
  echo \xDE = "%%�"
  echo \xDF = "%%�"
  echo \xE0 = "%%�"
  echo \xE1 = "%%�"
  echo \xE2 = "%%�"
  echo \xE3 = "%%�"
  echo \xE4 = "%%�"
  echo \xE5 = "%%�"
  echo \xE6 = "%%�"
  echo \xE7 = "%%�"
  echo \xE8 = "%%�"
  echo \xE9 = "%%�"
  echo \xEA = "%%�"
  echo \xEB = "%%�"
  echo \xEC = "%%�"
  echo \xED = "%%�"
  echo \xEE = "%%�"
  echo \xEF = "%%�"
  echo \xF0 = "%%�"
  echo \xF1 = "%%�"
  echo \xF2 = "%%�"
  echo \xF3 = "%%�"
  echo \xF4 = "%%�"
  echo \xF5 = "%%�"
  echo \xF6 = "%%�"
  echo \xF7 = "%%�"
  echo \xF8 = "%%�"
  echo \xF9 = "%%�"
  echo \xFA = "%%�"
  echo \xFB = "%%�"
  echo \xFC = "%%�"
  echo \xFD = "%%�"
  echo \xFE = "%%�"
  echo \xFF = "%%�"
)
exit /b

:getChar  hexStr  rtnVar    (0A and 0D not supported)
(echo %~1) >char.hex
certutil -f -decodehex char.hex char.bin >nul
for /f delims^=^ eol^= %%A in (char.bin) do set "%~2=%%A"
exit /b
#SingleInstance force
#InstallMouseHook
#Include OCR.ahk
#Include GDIp.ahk
#Include GDIpHelper.ahk
idleOption := 0
donate := 0
errorCheck := 0
error := 0
myGold := -1
myElixir := -1
myDarkElixir := -1
myTrophies := -1
myGems := -1
myBuilders := -1
enemyGold := -1
enemyElixir := -1
CoordMode, Pixel, Relative
CoordMode, Mouse, Relative
SetTitleMatchMode, RegEx
SetDefaultMouseSpeed, 10

; Create the popup menu by adding some items to it. 
Menu, Toggles, Add, Keep from idling, IdleHandler
Menu, Toggles, Add, Donate Goblins, DonateHandler
Menu, Toggles, Add, Check for Errors, ErrorHandler
Menu, MyMenu, Add, Toggle Options, :Toggles
Menu, Automations, Add, Gobblegobble, GoblinHandler
Menu, Automations, Add, Gobblegobbledebug, GoblinHandlerDebug
Menu, Automations, Add, Drop Trophies, DropTrophiesHandler
Menu, MyMenu, Add, Full Automation, :Automations
Menu, SmallAutomations, Add, Train Goblins, TrainGoblins 
Menu, SmallAutomations, Add, Collect Resources, CollectResources
Menu, SmallAutomations, Add, Test Colors, TestColors
Menu, MyMenu, Add, Small Routines, :SmallAutomations
Menu, Configuration, Add, Set Collector Locations, ConfigResourceLocation
Menu, Configuration, Add, Set Barracks Locations, ConfigBarracksLocation
Menu, MyMenu, Add, Configuration, :Configuration
Menu, MyMenu, Add, Get Resources, MenuHandler  ; Add another menu item beneath the submenu.
Menu, MyMenu, Add  ; Add a separator line.
Menu, MyMenu, Add, Cum on step it up, Sanic
Menu, MyMenu, Add, Show Debug Window, ShowDebug
Menu, MyMenu, Add, Close Script, CoCExit



;SetTimer, CopyLogToDropbox, 1800000
Gosub, IdleHandler
Gosub, ReadConfig

Gui, Add, Text,, Trophies:
Gui, Add, Text,, Gems:
Gui, Add, Text,, Builders:
Gui, Add, Text,, Gold:
Gui, Add, Text,, Elixir:
Gui, Add, Text,, DarkElixir:
Gui, Add, Text,w100 vTrophies ys, % myTrophies
Gui, Add, Text,w100 vGems, % myGems
Gui, Add, Text,w100 vBuilders, % myBuilders
Gui, Add, Text,w100 vGold, % myGold
Gui, Add, Text,w100 vElixir, % myElixir
Gui, Add, Text,w100 vDarkElixir, % myDarkElixir
Gui, Add, Text,ys, EnemyGold:
Gui, Add, Text,, EnemyElixir:
Gui, Add, Text,w100 vEnemyGold ys, % enemyGold
Gui, Add, Text,w100 vEnemyElixir, % enemyElixir

return  ; End of script's auto-execute section.

ShowDebug:
Gui, Show, ,
return

Sanic:
SoundPlay, sanic.mp3
return

WriteLog:
IfNotExist, log.csv 
{
	FileAppend, time`,myGold`,myElixir`,myDarkElixir`,myTrophies`,myGems`,myBuilders`n, log.csv
}
time := ((A_YDay*24)+A_Hour)*60+A_Min
FileAppend, %time%`,%myGold%`,%myElixir%`,%myDarkElixir%`,%myTrophies%`,%myGems%`,%myBuilders%`n, log.csv
return

CopyLogToDropbox:
if InStr(FileExist(HOMEDRIVE HOMEPATH "\Dropbox"), "D")
	FileCopy, log.csv, %HOMEDRIVE%%HOMEPATH%\Dropbox\CoClog.csv , 1
return
	

UpdateGui:
GuiControl,, Trophies, %myTrophies%
GuiControl,, Gems, %myGems%
GuiControl,, Builders, %myBuilders%
GuiControl,, Gold, %myGold%
GuiControl,, Elixir, %myElixir%
GuiControl,, DarkElixir, %myDarkElixir%
GuiControl,, EnemyGold, %enemyGold%
GuiControl,, EnemyElixir, %enemyElixir%
return

CheckIdle:
while (A_TimeIdlePhysical < 30000) {
Sleep 100
}
return

DrawText(text,x,y,res,size) {
StartDrawGDIP()
ClearDrawGDIP()
Gdip_SetSmoothingMode(G,4)
Gdip_TextToGraphics(G,text, "x350 y200 cff000000 r4 s72")
EndDrawGDIP()
return
}

CoCExit:
ExitApp
return

GetMyStats:
GoSub, GetWindow
GoSub, MyGold
GoSub, MyElixir
GoSub, MyDarkElixir
GoSub, MyTrophies
GoSub, MyGems
GoSub, MyBuilders
GoSub, UpdateGui
return

MenuHandler:
GoSub, MyGold
GoSub, MyElixir
GoSub, MyDarkElixir
GoSub, MyTrophies
GoSub, MyGems
GoSub, MyBuilders
MsgBox Gold: %myGold% Elixir: %myElixir% DarkElixir: %myDarkElixir% Trophies: %myTrophies% Gems: %myGems% Builders: %myBuilders%
return

Esc::Reload
;F2::Libraries\Documents\Thunder.mp3


#z::Menu, MyMenu, Show  ; i.e. press the Win-Z hotkey to show the menu.

IdleHandler:
menu, Toggles, ToggleCheck, Keep from idling
idleOption := !idleOption
if (idleOption) {
	SetTimer, CheckInactive, 270000
} else {
	SetTimer, CheckInactive, Off
}
return

ErrorHandler:
menu, Toggles, ToggleCheck, Check for Errors
errorCheck := !errorCheck
if (errorCheck) {
	SetTimer, CheckError, 60000
} else {
	SetTimer, CheckError, Off
}
return

DonateHandler:
menu, Toggles, ToggleCheck, Donate Goblins
donate := !donate
return

CheckError:
Gosub, GetWindow
PixelGetColor color, 803, 488
if (color =  0x282828) {
Click 803, 488
Error := 1
return
}
PixelGetColor color, 803, 499
if (color =  0x282828) {
Click 803, 499
Error := 1
return
}
Error := 0
return

CheckInactive:
if(!donate) {
Gosub, GetWindow
Gosub, ScrollUp
return
}
Gosub, GetWindow
PixelGetColor color, 28, 470
if (color = 0xFFFFFF) {
	Gosub, DonateGoblins
}
return

GoblinHandler:
if(idleOption = 1) {
	Gosub, IdleHandler
}
if(errorCheck = 0) {
	Gosub, ErrorHandler
}
SetTimer, WriteLog, 600000
Loop {
Gosub, GetWindow
Gosub, AttackButton
Gosub, FindMatchButton
Gosub, WaitForMatch
Gosub, EnemyGold
Gosub, EnemyElixir
Gosub, UpdateGui
pix:=GetFlowPixels()
if((pix < 135000) and ((enemyGold + enemyElixir)>2000)) {
useGoblins:= Ceil((enemyGold + enemyElixir) / 300) 
if (useGoblins > 75) {
	useGoblins := 75
}
DropGobsGold(useGoblins)
Gosub, ExitBattleIfDone
} else {
DropGobsGold(0)
Gosub, Surrender
}
Gosub, WaitForHome
Gosub, GetMyStats
if(myTrophies < 200) {
	Gosub, TrainGoblins
	Gosub, CollectResources
}
}
return

GoblinHandlerDebug:
if(idleOption = 1) {
	Gosub, IdleHandler
}
if(errorCheck = 0) {
	Gosub, ErrorHandler
}
SetTimer, WriteLog, 600000
Loop {
Gosub, GetWindow
Gosub, AttackButton
Gosub, FindMatchButton
Gosub, WaitForMatch
Gosub, EnemyGold
Gosub, EnemyElixir
Gosub, UpdateGui
pix:=GetFlowPixels()
if((pix < 135000) and ((enemyGold + enemyElixir)>2000)) {
useGoblins:= Ceil((enemyGold + enemyElixir) / 300) 
if (useGoblins > 100) {
	useGoblins := 100
}
DropGobsGold(useGoblins)
Gosub, ExitBattleIfDone
} else {
Gosub, ScrollUp
Gosub, DropTroop
Gosub, Surrender
}
Gosub, WaitForHome
Gosub, GetMyStats
}
return

DropTrophiesHandler:
Loop {
Gosub, AttackButton
Gosub, FindMatchButton
Gosub, WaitForLoading
Gosub, ZoomOut
Gosub, ScrollUp
Gosub, DropTroop
Gosub, Surrender
Gosub, WaitForLoading
}
return


GetWindow:
WinActivate, BlueStacks
WinWaitActive, BlueStacks,, 1
if ErrorLevel {
	MsgBox, Clash of Clans not running
	return
}
return


ExitButton:
Gosub, GetWindow
Click 1556, 64
return

AttackButton:
Gosub, GetWindow
Click 85, 788
return

FindMatchButton:
Gosub, GetWindow
Click 281, 671
return

EndMatchButton:
Gosub, GetWindow
Click 101, 676
return

TrainTroopsButton:
Gosub, GetWindow
Click 991, 782
return

TrainGoblinButton:
Gosub, GetWindow
Click 805, 438
return

TroopTrainExitButton:
Gosub, GetWindow
Click 1201, 201
return

ReturnFromBattleButton:
Gosub, GetWindow
Click 802, 702
return

SurrenderCancelButton:
Gosub, GetWindow
Click 692, 536
return

SurrenderOkayButton:
Gosub, GetWindow
Click 913, 536
return

ZoomOut:
Gosub, GetWindow
Loop, 8  {
SendInput, x
Sleep, 250
}
return

ScrollUp:
Gosub, GetWindow
MouseMove, 803, 305
Click down
MouseMove, 803, 705
Click up
;Click WheelUp
return

;wait for either base loading or match loading, deprecated
WaitForLoading:
Sleep 1000
Loop {
	Sleep 1000
	PixelGetColor, color, 831, 63
	if (color = 0xF4F4EC) {
		break
	}
	PixelGetColor, color, 141, 660
	if (color = 0x5450EF) {
		break
	}
}
return

WaitForMatch:
Sleep 1000
Loop {
	Sleep 1000
	;If there was a shield, hit okay and continue
	PixelGetColor, color, 914, 511
	if (color = 0x75EAD0) {
		Click 914, 511
	}
	;look for the red end battle button, finish blocking if found
	PixelGetColor, color, 141, 660
	if (color = 0x5450EF) {
		break
	}
	;if there was an error message the last time we are now back at the home screen but stuck
	if (error = 1) {
		;wait until we check for errors and there isn't one, sleep ten seconds, then restart the automation
		Loop {
			if (error = 0) {
				Sleep 10000
				Gosub, GoblinHandler
			}
		}
	}
}
return

WaitForHome:
Sleep 1000
Loop {
	Sleep 1000
	;Look for the shield icon on the home screen (opaque so it's easy to get)
	PixelGetColor, color, 831, 63
	if (color = 0xF4F4EC) {
		break
	}
}
return

ExitBattleIfDone:
lastResources := enemyGold + enemyElixir
i := 0
Loop {
	Sleep 500
	PixelGetColor, color, 802, 702
	if (color = 0x7CECD4) {
		Click 802, 702
		return
	}
	GoSub, EnemyGold
	GoSub, EnemyElixir
	if ((enemyGold + enemyElixir) = lastResources) {
		i := i + 1
		if (i > 20) {
			GoSub, Surrender
			return
		}
	}
	lastResources := enemyGold + enemyElixir
	GoSub, UpdateGui
	if ((enemyGold + enemyElixir) < 2000) {
		GoSub, Surrender
		return
	}
}
return

Surrender:
Sleep 500
GoSub, EndMatchButton
GoSub, SurrenderOkayButton
GoSub, ReturnFromBattleButton
return

TrainGoblins:

;B1X := 400
;B1Y := 611

;B2X := 735
;B2Y := 314

;B3X := 869
;B3Y := 314

;B4X := 1205
;B4Y := 719

Gosub, GetWindow
Gosub, ZoomOut
Gosub, ScrollUp

Loop %totalBarracks% {
MouseClick,, BX%A_Index%, BY%A_Index%
Gosub, TrainTroopsButton
MouseMove 805, 438
Click down
Sleep 2000
Click up
Gosub, TroopTrainExitButton
}
return

DropTroop:
MouseMove 799, 53
Click
return

DropTroops:
MouseMove 799, 53
Click down
Sleep 1000
MouseMove 72, 582, 100
Click up
Click 419, 787
Click 799, 53
return

ConfigResourceLocation:
Gosub, GetWindow
Gosub, ZoomOut
Gosub, ScrollUp
Gosub, GetWindow
WinGetPos,winX,winY,winWidth,winHeight
InputBox, numCollectors, Number of Collectors, How many collectors do you have? (E`,G`, and DE) After inputting the amount`, click on each collector once and do not move the screen. It also works better if you select the bottom most collectors and work up ,,300,250,winX+winWidth/2-150,winY+winHeight/2-125,,,13
if ErrorLevel
	return
if numCollectors is not integer 
{
	Msgbox, Not a valid number
	return
}
IniDelete, config.ini, collectors
IniWrite, %numCollectors%, config.ini, collectors, numCollectors
Loop %numCollectors% {
KeyWait, LButton, D
KeyWait, LButton, U
MouseGetPos, xPos, yPos
IniWrite, %xPos%, config.ini, collectors, CX%A_Index%
IniWrite, %yPos%, config.ini, collectors, CY%A_Index%
}
GoSub, ReadConfig
return

ConfigBarracksLocation:
Gosub, GetWindow
Gosub, ZoomOut
Gosub, ScrollUp
Gosub, GetWindow
WinGetPos,winX,winY,winWidth,winHeight
InputBox, numBarracks, Number of Barracks, How many normal barracks do you have? After inputting the amount`, click on each barracks once and do not move the screen.,,300,250,winX+winWidth/2-150,winY+winHeight/2-125,,,4
if ErrorLevel
	return
if numBarracks is not integer 
{
	Msgbox, Not a valid number
	return
}
IniDelete, config.ini, barracks
IniWrite, %numBarracks%, config.ini, barracks, numBarracks
Loop %numBarracks% {
KeyWait, LButton, D
KeyWait, LButton, U
MouseGetPos, xPos, yPos
IniWrite, %xPos%, config.ini, barracks, BX%A_Index%
IniWrite, %yPos%, config.ini, barracks, BY%A_Index%
}
GoSub, ReadConfig
return

ReadConfig:
IfNotExist, config.ini
{
	MsgBox, Please configure barracks and collector locations (which will be saved)
	return
}
IniRead, totalBarracks, config.ini, barracks, numBarracks
Loop %totalBarracks% {
IniRead, BX%A_Index%, config.ini, barracks, BX%A_Index%
IniRead, BY%A_Index%, config.ini, barracks, BY%A_Index%
}
IniRead, totalCollectors, config.ini, collectors, numCollectors
Loop %totalCollectors% {
IniRead, CX%A_Index%, config.ini, collectors, CX%A_Index%
IniRead, CY%A_Index%, config.ini, collectors, CY%A_Index%
}
return

CollectResources:
Gosub, GetWindow
Gosub, ZoomOut
Gosub, ScrollUp
Loop %totalCollectors% {
MouseClick,, CX%A_Index%, CY%A_Index%
}
return

DonateGoblins:
Gosub, GetWindow
Click 22, 466
Sleep 500
Click WheelUp
Sleep 500
Loop {
	Gosub, GetWindow
	PixelSearch, Dx, Dy, 166, 223, 167, 852, 0x50DCB4, 3, fast
	if ErrorLevel = 0
	{
	Click %Dx%, %Dy%
	Dx := Dx + 361
	Dy := Dy - 85
	MouseMove %Dx%, %Dy%
	Click Down
	Sleep 1500
	Click Up
	Dx := Dx - 361
	Dy := Dy + 85
	Click %Dx%, %Dy%
	} else {
	break
	}
}
Click 440, 471
Sleep 500
return

MyGold:
GoSub, GetWindow
myGold := GetOCR(1344, 55, 180, 25, "activeWindow")
StringReplace, myGold, myGold, %A_SPACE%, , All
StringReplace, myGold, myGold, `n, , All
if(myGold = "")
myGold := 0
return

MyElixir:
GoSub, GetWindow
myElixir := GetOCR(1344, 122, 185, 25, "activeWindow")
StringReplace, myElixir, myElixir, %A_SPACE%, , All
StringReplace, myElixir, myElixir, `n, , All
if(myElixir = "")
myElixir := 0
return

MyDarkElixir:
GoSub, GetWindow
myDarkElixir := GetOCR(1409, 186, 122, 25, "activeWindow")
StringReplace, myDarkElixir, myDarkElixir, %A_SPACE%, , All
StringReplace, myDarkElixir, myDarkElixir, `n, , All
if(myDarkElixir = "")
myDarkElixir := 0
return

MyTrophies:
GoSub, GetWindow
myTrophies := GetOCR(77, 119, 87, 27, "activeWindow")
StringReplace, myTrophies, myTrophies, %A_SPACE%, , All
StringReplace, myTrophies, myTrophies, `n, , All
if(myTrophies = "")
myTrophies := 0
return

MyGems:
GoSub, GetWindow
myGems := GetOCR(1440, 251, 92, 23, "activeWindow")
StringReplace, myGems, myGems, %A_SPACE%, , All
StringReplace, myGems, myGems, `n, , All
if(myGems = "")
myGems := 0
return

MyBuilders:
GoSub, GetWindow
myBuilders := GetOCR(654, 52, 68, 26, "activeWindow")
StringReplace, myBuilders, myBuilders, %A_SPACE%, , All
StringReplace, myBuilders, myBuilders, `n, , All
myBuilders := SubStr(myBuilders,1,1)
if(myBuilders = "")
myBuilders := 0
return

EnemyGold:
GoSub, GetWindow
enemyGold := GetOCR(68, 110, 162, 38, "activeWindow")
StringReplace, enemyGold, enemyGold, %A_SPACE%, , All
StringReplace, enemyGold, enemyGold, `n, , All
if(enemyGold = "")
enemyGold := 0
return

EnemyElixir:
GoSub, GetWindow
enemyElixir := GetOCR(64, 144, 162, 38, "activeWindow")
StringReplace, enemyElixir, enemyElixir, %A_SPACE%, , All
StringReplace, enemyElixir, enemyElixir, `n, , All
if(enemyElixir = "")
enemyElixir := 0
return

TestColors:
SetDefaultMouseSpeed, 0
WinActivate, Paint
Loop {
WinActivate, Paint
PixelSearch tempX, tempY, 15, 155, 1135, 809, 0x00A4D8, 1, Fast
; 0xE058D5
if ErrorLevel {
MsgBox, Done
SetDefaultMouseSpeed, 10
break
}
Click %tempX%, %tempY%
}
return

GetFlowPixels() {
GoSub, GetWindow
GoSub, ZoomOut
WinGetPos, xOffset, yOffset
fileJpg := "base.jpg"
filePng := "filter.png"
fileTxt := "base.txt"
jpegQual := 100
convertPath=convert.exe

;take a screenshot of the specified area
pToken:=Gdip_Startup()
TopLeftX:=211 + xOffset
TopLeftY:=38 + yOffset
Width:=1122
Height:=655
pBitmap:=Gdip_BitmapFromScreen(TopLeftX "|" TopLeftY "|" Width "|" Height)
Gdip_SaveBitmapToFile(pBitmap, fileJpg, jpegQual)
Gdip_Shutdown(pToken)

; Wait for jpg file to exist
while NOT FileExist(fileJpg)
  Sleep, 10

;ensure the exes are there
if NOT FileExist(convertPath)
  MsgBox, No convert.exe found
  
convertCmd=convert.exe %fileJpg% -negate -threshold 60`% -edge 5 -morphology EdgeOut Disk -fill white -floodfill +20+20 black -floodfill +1100+20 black -floodfill +20+630 black -floodfill +1100+630 black -floodfill +20+425 black -floodfill +20+375 black -floodfill +20+325 black -floodfill +20+275 black -floodfill +20+225 black -floodfill +1100+425 black -floodfill +1100+375 black -floodfill +1100+325 black -floodfill +1100+275 black -floodfill +1100+225 black %filePng%
Runwait, %comspec% /c %convertCmd%,, Hide

; Wait for png file to exist
while NOT FileExist(filePng)
	Sleep, 10

convertCmd=convert.exe %filePng% -format `%c histogram:info:- > %fileTxt%
Runwait, %comspec% /c %convertCmd%,, Hide

; Wait for txt file to exist
while NOT FileExist(fileTxt)
	Sleep, 10

FileRead, result, %fileTxt%

result:=SubStr(result,1,10)
result:=RegExReplace(result," ")

return result
}

DropGobsGold(gobs) {
	GoSub, GetWindow
	topLeftX:=211
	topLeftY:=38
	width:=1333
	height:=693
	WinGetPos,,,winWidth,winHeight
	PixelSearch seedX, seedY, topLeftX, topLeftY, 1135, 809, 0x00A4D8, 1, Fast
	if (ErrorLevel = 1) {
	seedX := winWidth/2
	seedY := winHeight/2
	}
	MouseMove seedX, seedY, 1
	Loop, 150 {
		topLeftX := Floor(seedX-(A_Index*3))
		if (topLeftX < 0)
			topLeftX := 0
		topLeftY := Floor(seedY-(A_Index*3))
		if (topLeftY < 0)
			topLeftY := 0
		bottomRightX := Floor(seedX+(A_Index*3))
		if (bottomRightX > winWidth) 
			bottomRightX := winWidth
		bottomRightY := Floor(seedY+(A_Index*3))
		if (bottomRightY > winHeight) 
			bottomRightY := winHeight
		MouseMove topLeftX, topLeftY, 1
		MouseMove bottomRightX, topLeftY, 1
		MouseMove bottomRightX, bottomRightY, 1
		MouseMove topLeftX, bottomRightY, 1
		PixelSearch, dropPointX, dropPointY, topLeftX, topLeftY, bottomRightX, bottomRightY, 0x2E7CCE, 1, Fast
		if (ErrorLevel == 0) {
			Loop %gobs% {
				Click %dropPointX% %dropPointY%
			}
			Click 419, 787
			Click %dropPointX% %dropPointY%
			return
		} else if (ErrorLevel == 2) {
			return
		}
	}
	return
}

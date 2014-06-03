#SingleInstance force
#Include OCR.ahk
#Include GDIp.ahk
#Include GDIpHelper.ahk
idleOption := 0
buttonOption := 0
donate := 0
errorCheck := 0
error := 0
useNN := 1
myTroopPercent := -1
myGold := -1
myElixir := -1
myDarkElixir := -1
myTrophies := -1
myGems := -1
myBuilders := -1
enemyGold := -1
enemyElixir := -1
dGold := -1
dElixir := -1
dDarkElixir := -1
dTrophies := -1
dAttacked := -1

barbarian		:= 1
archer			:= 2
goblin			:= 3
giant			:= 4
wallBreaker		:= 5
balloon 		:= 6
wizard 			:= 7
healer 			:= 8
dragon 			:= 9
pekka 			:= 10
minion 			:= 11
hogRider 		:= 12
valkyrie		:= 13
golem			:= 14
witch			:= 15
barbarianKing 	:= 16
archerQueen		:= 17
lightning 		:= 18
heal 			:= 19
rage 			:= 20
jump			:= 21
freeze			:= 22
santa			:= 23
clan 			:= 24
numSprites		:= 24

CoordMode, Pixel, Relative
CoordMode, Mouse, Relative
SetTitleMatchMode, RegEx
SetFormat, float, 0.16
SetDefaultMouseSpeed, 5

; Create the popup menu by adding some items to it. 
Menu, Toggles, Add, Keep from idling, IdleHandler
Menu, Toggles, Add, Donate Goblins, DonateHandler
Menu, Toggles, Add, Check for Errors, ErrorHandler
Menu, MyMenu, Add, Toggle Options, :Toggles

Menu, Buttons, Add, No Action, ButtonsHandler
Menu, Buttons, Add, Troop Spray, ButtonsHandler
Menu, Buttons, Add, Wall Upgrade, ButtonsHandler
Menu, Buttons, Check, No Action
Menu, MyMenu, Add, MouseButton1 Options, :Buttons

Menu, Automations, Add, Gobblegobble, GoblinHandler
Menu, Automations, Add, Drop Trophies Below 200, DropTrophies
Menu, Automations, Add, Drop All Trophies, DropAllTrophies
Menu, MyMenu, Add, Full Automation, :Automations

Menu, SmallAutomations, Add, Train Goblins, TrainGoblins 
Menu, SmallAutomations, Add, Collect Resources, CollectResources
Menu, SmallAutomations, Add, Test Colors, TestColors
Menu, MyMenu, Add, Small Routines, :SmallAutomations

Menu, Configuration, Add, Set Collector Locations, ConfigResourceLocation
Menu, Configuration, Add, Set Barracks Locations, ConfigBarracksLocation
Menu, Configuration, Add, Set Camp Location, ConfigCampLocation
Menu, MyMenu, Add, Configuration, :Configuration

Menu, MyMenu, Add, Get Resources, MenuHandler  ; Add another menu item beneath the submenu.
Menu, MyMenu, Add  ; Add a separator line.
Menu, MyMenu, Add, Cum on step it up, Sanic
Menu, MyMenu, Add, Show Debug Window, ShowDebug
Menu, MyMenu, Add, Lock MouseY, LockMouseY
Menu, MyMenu, Add, asdf, GatherTroopSelectors
Menu, MyMenu, Add, Close Script, CoCExit



BlockInput, MouseMoveOff
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
Gui, Add, Text,, Error:
Gui, Add, Text,w100 vEnemyGold ys, % enemyGold
Gui, Add, Text,w100 vEnemyElixir, % enemyElixir
Gui, Add, Text,w100 vError, % error

return  ; End of script's auto-execute section.

ShowDebug:
Gui, Show, ,
return

Sanic:
SoundPlay, sanictheweedhog.mp3
;SoundPlay, sanic.mp3
SoundSetWaveVolume, 100
return

WriteLog:
IfNotExist, log.csv 
{
	FileAppend, time`,myGold`,myElixir`,myDarkElixir`,myTrophies`,myGems`,myBuilders`n, log.csv
}
time := ((A_YDay*24)+A_Hour)*60+A_Min
FileAppend, %time%`,%myGold%`,%myElixir%`,%myDarkElixir%`,%myTrophies%`,%myGems%`,%myBuilders%`n, log.csv
return

WriteLog2:
IfNotExist, log2.csv 
{
	FileAppend, myTrophies`,flowPixels`,netGold`,netElixir`,netDarkElixir`,netTrophies`,attacked`n, log2.csv
}
FileAppend, %myTrophies%`,%pix%`,%dGold%`,%dElixir%`,%dDarkElixir%`,%dTrophies%`,%dAttacked%`n, log2.csv
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
GuiControl,, Error, %error%
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


ButtonsHandler:
menu, %A_ThisMenu%, Check, %A_ThisMenuItem%
if (A_ThisMenuItem = "No Action") {
	menu, %A_ThisMenu%, Uncheck, Wall Upgrade
	menu, %A_ThisMenu%, Uncheck, Troop Spray
	buttonOption := 0
} else if (A_ThisMenuItem = "Troop Spray") {
	menu, %A_ThisMenu%, Uncheck, No Action
	menu, %A_ThisMenu%, Uncheck, Wall Upgrade
	buttonOption := 1
} else if (A_ThisMenuItem = "Wall Upgrade") {
	menu, %A_ThisMenu%, Uncheck, No Action
	menu, %A_ThisMenu%, Uncheck, Troop Spray
	buttonOption := 2
}
Hotkey, IfWinActive, BlueStacks

if (buttonOption = 0) {
Hotkey, XButton1,TroopSpray, On
Hotkey, XButton1,, Off
} else if (buttonOption = 1){
Hotkey, XButton1, TroopSpray, On
} else if (buttonOption = 2){
Hotkey, XButton1, WallUpgrade, On
}
return


Esc::Reload
F1::GoSub, GoblinHandler
F2::GoSub, LockMouseY
F3::GoSub, DataLoop
F4::GoSub, GetDecision

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
PixelGetColor color2, 853, 488
PixelGetColor color3, 753, 488
if (color =  0x282828 and color2 = 0x282828 and color3 = 0x282828) {
Click 803, 488
error := 1
GoSub, UpdateGui
return
}
PixelGetColor color, 803, 499
PixelGetColor color2, 853, 499
PixelGetColor color3, 753, 499
if (color =  0x282828 and color2 = 0x282828 and color3 = 0x282828) {
Click 803, 499
error := 1
GoSub, UpdateGui
return
}
error := 0
GoSub, UpdateGui
return

CheckInactive:
Gosub, GetWindow
BlockInput On
MouseGetPos, xPos, yPos
MouseClick,,CX1,CY1,,0
MouseMove,xPos,yPos,0
BlockInput Off
return
return

GoblinHandler:
GoSub, GetWindow
BlockInput, MouseMove
if(idleOption = 1) {
	Gosub, IdleHandler
}
if(errorCheck = 0) {
	Gosub, ErrorHandler
}
SetTimer, WriteLog, 600000
Click 444, 77
Gosub, WaitForHome
Gosub, GetMyStats
Gosub, DropTrophies
Loop {
	Gosub, MyTroopTotal
	Gosub, TrainGoblins
	Gosub, CollectResources
	if(myTroopPercent < 0.3) {
		Loop {
			Sleep 10000
			GoSub, MyTroopTotal
			if (myTroopPercent > 0.3)
				break
		}
	}
	Gosub, GetWindow
	Gosub, AttackButton
	Gosub, FindMatchButton
	Gosub, WaitForMatch
	Gosub, UpdateGui
	GoSub, GatherTroopSelectors
	if(useNN) {
		if(myTrophies < 150) {
			Loop {
				attack := NNDecision()
				if(attack > 0.85) {
					FileCopy, base.jpg, BasePictures\Attacked\%A_Now%.jpg
					useGoblins:= Ceil((enemyGold + enemyElixir) / 400) 
					if (useGoblins > 60) {
						useGoblins := 60
					}
					DropGobsGold(useGoblins)
					dAttacked := 1
					Gosub, ExitBattleIfDone
					break
				} else {
					FileCopy, base.jpg, BasePictures\Surrendered\%A_Now%.jpg
					Gosub, NextMatchButton
					Gosub, WaitForMatch
				}
			}
		} else {
			attack := NNDecision()
			if(attack > 0.85) {
				FileCopy, base.jpg, BasePictures\Attacked\%A_Now%.jpg
				useGoblins:= Ceil((enemyGold + enemyElixir/2) / 400) 
				if (useGoblins > 60) {
					useGoblins := 60
				}
				DropGobsGold(useGoblins)
				dAttacked := 1
				Gosub, ExitBattleIfDone
				break
			} else {
				FileCopy, base.jpg, BasePictures\Surrendered\%A_Now%.jpg
				dAttacked := 0
				Gosub, Surrender
			}
		}
	} else {
		pix:=GetFlowPixels()
		if(pix < 135000) {
			Gosub, EnemyGold
			Gosub, EnemyElixir
			if((enemyGold + enemyElixir)>2000) {
				useGoblins:= Ceil((enemyGold + enemyElixir) / 400) 
				if (useGoblins > 60) {
					useGoblins := 60
				}
				DropGobsGold(useGoblins)
				dAttacked := 1
				Gosub, ExitBattleIfDone
			} else {
				DropGobsGold(0)
				dAttacked := 0
				Gosub, Surrender
			}
		} else {
			DropGobsGold(0)
			dAttacked := 0
			Gosub, Surrender
		}
	}
	Gosub, WaitForHome
	dGold := myGold
	dElixir := myElixir
	dDarkElixir := myDarkElixir
	dTrophies := myTrophies
	Gosub, GetMyStats
	dGold := myGold - dGold
	dElixir := myElixir - dElixir
	dDarkElixir := myDarkElixir - dDarkElixir
	dTrophies := myTrophies - dTrophies
}
return

DropTrophies:
Gosub, MyTrophies
if(myTrophies < 200) {
	return
}
Gosub, TrainGoblins
Loop {
Gosub, AttackButton
Gosub, FindMatchButton
Gosub, WaitForMatch
Gosub, GatherTroopSelectors
SelectTroop(goblin)
SelectTroop(barbarianKing)
SelectTroop(archerQueen)
Gosub, ZoomOut
Gosub, ScrollUp
Gosub, DropTroop
Gosub, Surrender
Gosub, WaitForHome
Gosub, MyTrophies
if(myTrophies < 200) {
	return
}
}
return

DropAllTrophies:
Gosub, TrainGoblins
Loop {
Gosub, AttackButton
Gosub, FindMatchButton
Gosub, WaitForMatch
Gosub, GatherTroopSelectors
SelectTroop(goblin)
SelectTroop(barbarianKing)
SelectTroop(archerQueen)
Gosub, ZoomOut
Gosub, ScrollUp
Gosub, DropTroop
Gosub, Surrender
Gosub, WaitForHome
}
return


GetWindow:
Loop {
WinActivate, BlueStacks
IfWinActive, BlueStacks
	break
Sleep 1000
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

NextMatchButton:
Gosub, GetWindow
Click 1464, 648
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
MouseMove, 803, 505
SendInput, {Control Down}
Sleep 300
SendInput, -
Sleep 300
SendInput, -
Sleep 300
SendInput, {Control Up}
return

ScrollUp:
Gosub, GetWindow
MouseMove, 803, 305, 0
Click down
MouseMove, 803, 705
Click up
return

WaitForMatch:
GoSub, GetWindow
Sleep 1000
Loop {
	GoSub, GetWindow
	Sleep 1000
	;If there was a shield, hit okay and continue
	PixelGetColor, color, 914, 511
	MouseMove, 914, 511
	if (color = 0x75EAD0) {
		Click 914, 511
	}
	;look for the red end battle button, finish blocking if found
	PixelGetColor, color, 141, 660
	MouseMove, 141, 660
	if (color = 0x5450EF) {
		break
	}
	;if there was an error message the last time we are now back at the home screen but stuck
	if (error = 1) {
		;wait until we check for errors and there isn't one, sleep ten seconds, then restart the automation
		Loop {
			Sleep 10000
			if (error = 0) {
				Gosub, GoblinHandler
			}
		}
	}
}
return

WaitForHome:
Gosub, GetWindow
Sleep 1000
Loop {
	GoSub, GetWindow
	Sleep 1000
	;Look for the shield icon on the home screen (opaque so it's easy to get)
	PixelGetColor, color, 831, 63
	if (color = 0xF4F4EC) {
		break
	}
}
return

ExitBattleIfDone:
Gosub, GetWindow
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
Gosub, GetWindow
Gosub, ZoomOut
Gosub, ScrollUp

Loop %totalBarracks% {
Train(A_Index,goblin,60)
}
return

Train(barracks,troop,amount) {
Gosub, GetWindow
MouseClick,, BX%barracks%, BY%barracks%
Gosub, TrainTroopsButton
TrainTroop(troop,amount)
Gosub, TroopTrainExitButton
return
}

;while in the barracks dialogue, click a troop for an amount
TrainTroop(troop,amount) {
if (troop < 1 or troop > 10 )
	return
clickX := Mod(troop-1,5)*141+525
clickY := ((troop-1)//5)*146+429
Loop %amount% {
	MouseClick,, clickX, clickY
}
return
}

DropTroop:
SelectTroop(goblin)
SelectTroop(barbarianKing)
SelectTroop(archerQueen)
MouseMove 799, 53
Click
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

ConfigCampLocation:
Gosub, GetWindow
Gosub, ZoomOut
Gosub, ScrollUp
Gosub, GetWindow
WinGetPos,winX,winY,winWidth,winHeight
MsgBox, 0, Camp Location, After clicking okay on this window, click on an army camp and do not move the screen. Also`, make sure the camp will not be covered by gui buttons for the game.

IniDelete, config.ini, camp
KeyWait, LButton, D
KeyWait, LButton, U
MouseGetPos, xPos, yPos
IniWrite, %xPos%, config.ini, camp, campX
IniWrite, %yPos%, config.ini, camp, campY
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
IniRead, campX, config.ini, camp, campX
IniRead, campY, config.ini, camp, campY
return

CollectResources:
Gosub, GetWindow
Gosub, ZoomOut
Gosub, ScrollUp
Loop 2 {
Loop %totalCollectors% {
MouseClick,, CX%A_Index%, CY%A_Index%,,0
}
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
PixelSearch tempX, tempY, 15, 155, 1135, 809, 0x2662DB, 5, Fast
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
WinGetPos, xOffset, yOffset,,,A
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
	global
	GoSub, GetWindow
	if (gobs = 0) {
		SelectTroop(goblin)
		SelectTroop(barbarianKing)
		SelectTroop(archerQueen)
		GoSub, ScrollUp
		Click 799, 53
		return	
	}
	topLeftX:=211
	topLeftY:=38
	width:=1333
	height:=693
	WinGetPos,,,winWidth,winHeight, A
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
		;MouseMove topLeftX, topLeftY, 0
		;MouseMove bottomRightX, topLeftY, 0
		;MouseMove bottomRightX, bottomRightY, 0
		;MouseMove topLeftX, bottomRightY, 0
		PixelSearch, dropPointX, dropPointY, topLeftX, topLeftY, bottomRightX, bottomRightY, 0x2E7CCE, 1, Fast
		if (ErrorLevel == 0) {
			SelectTroop(goblin)
			Loop %gobs% {
				Click %dropPointX% %dropPointY%
			}
			SelectTroop(barbarianKing)
			Click %dropPointX% %dropPointY%
			SelectTroop(archerQueen)
			Click %dropPointX% %dropPointY%
			return
		} else if (ErrorLevel == 2) {
			MsgBox, PixelSearch Error
			return
		}
	}
	return
}


;drops troop at fastest speed possible in random positions in a circle
TroopSpray:
BlockInput, MouseMove
While GetKeyState("XButton1","P")
{
	Random, randRadius, 0, 200
	Random, randRadians, 0.0, 6.2832
	MouseGetPos, xPos, yPos
	randX := Floor( randRadius * Cos(randRadians) ) + xPos
	randY := Floor( randRadius * Sin(randRadians) ) + yPos
	if (randX < 225)
		randX := 225
	if (randY < 30)
		randY := 30
	if (randX > 1595) 
		randX := 1595
	if (randY > 690) 
		randY := 690
	MouseClick,, randX, randY,, 0
	MouseMove, xPos, yPos, 0
}
BlockInput, MouseMoveOff
return

WallUpgrade:
BlockInput, MouseMove
MouseGetPos, xPos, yPos
Click
Click 926, 780
Click 820, 643
MouseMove, xPos, yPos
BlockInput, MouseMoveOff
return

MyTroopTotal:
GoSub, GetWindow
Gosub, ZoomOut
Gosub, ScrollUp
MouseClick,, campX, campY
Sleep 500
Click 741, 777
Sleep 500
minX := 801
maxX := 1165
Loop{
	searchX := (minX + maxX) // 2
	if (maxX - minX < 2) {
		break
	}
	PixelGetColor barColor, searchX, 284
	MouseMove, searchX, 284, 0
	if ColorsEqual(barColor,0x00A837,4) {
	minX := searchX
	} else {
	maxX := searchX
	}
}
myTroopPercent := (searchX - 801) / 364
Click 1156, 200
MouseClick,, CX1, CY1
return

ColorsEqual(c1,c2,variance=0) {
if (c1 = "" or c2 = "")
	return 0
d1 := Abs(c1//0x010000 - c2//0x010000)
d2 := Abs((Mod(c1,0x010000)//0x000100) - (Mod(c2,0x010000)//0x000100))
d3 := Abs(Mod(c1,0x000100) - Mod(c2,0x000100))
if (d1 <= variance and d2 <= variance and d3 <= variance)
	return 1
return 0
}

LockMouseY:
MouseGetPos, xPos, yPos
lockY := 776
Loop {
	MouseGetPos, xPos, yPos
	if (yPos != lockY)
		MouseMove,xPos,lockY,0
}
return

GatherTroopSelectors:
GoSub, GetWindow
WinGetPos,,,winWidth,winHeight, A
searchHeight := 776
%barbarian%Color		:= 0x186E92
%archer%Color			:= 0x6F3EE0
%goblin%Color			:= 0x51C779
%giant%Color			:= 0x64ACFC
%wallBreaker%Color		:= 0x5A454C
%balloon%Color 			:= 0x10144D
%wizard%Color 			:= 0xD1F4FC
%healer%Color 			:= 0xE4FBFC
%dragon%Color 			:= 0x835361
%pekka%Color 			:= 0xFF0000
%minion%Color 			:= 0xE8BC59
%hogRider%Color 		:= 0x343E66
%valkyrie%Color 		:= 0xFF0000
%golem%Color 			:= 0xFF0000
%witch%Color 			:= 0xFF0000
%barbarianKing%Color 	:= 0x1E3043
%archerQueen%Color 		:= 0xFF0000
%lightning%Color 		:= 0xFDF8D0
%heal%Color 			:= 0x91C8CA
%rage%Color 			:= 0x524360
%jump%Color 			:= 0xFF0000
%freeze%Color 			:= 0xFF0000
%santa%Color 			:= 0xFF0000
%clan%Color 			:= 0x27576C
Loop %numSprites% {
;if (%A_Index%Color = 0)
;	continue
PixelSearch, %A_Index%SelectX,, 0, searchHeight, winWidth, searchHeight, %A_Index%Color, 3, fast
if(%A_Index%SelectX != "")
	MouseMove, %A_Index%SelectX,searchHeight,3
}
return

SelectTroop(troop) {
	global
	if(%troop%SelectX = "")
		return
	MouseClick,, %troop%SelectX,776
	return
}

GatherData:
GoSub, GetWindow
GoSub, ZoomOut
IniRead, nextFile, config.ini, neuroInfo, infoFileName, 00000
WinGetPos, xOffset, yOffset,,,A
fileJpg := "base.jpg"
filePng := "NeuroInputs\pictures\" . nextFile . ".png"
fileTxt := "NeuroInputs\inputs\" . nextFile . ".txt"
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
  
convertCmd=convert.exe %fileJpg% -remap colormap.png %filePng%
Runwait, %comspec% /c %convertCmd%,, Hide

; Wait for png file to exist
while NOT FileExist(filePng)
	Sleep, 10

convertCmd=convert.exe %filePng% -format `%c histogram:info:- > %fileTxt%
Runwait, %comspec% /c %convertCmd%,, Hide

; Wait for txt file to exist
while NOT FileExist(fileTxt)
	Sleep, 10
pix:=GetFlowPixels()
Gosub, EnemyGold
Gosub, EnemyElixir
FileAppend, %enemyGold%: #enemyGold`n, %fileTxt%
FileAppend, %enemyElixir%: #enemyElixir`n, %fileTxt%
FileAppend, %pix%: #enemyFlow`n, %fileTxt%

nextFile := nextFile + 1
nextFile := SubStr("0000" . nextFile, -4)
IniWrite, %nextFile%, config.ini, neuroInfo, infoFileName
return

DataLoop:
Loop {
	GoSub, WaitForMatch
	GoSub, GatherData
	GoSub, NextMatchButton
}
return

NNDecision() {
global
GoSub, GetWindow
GoSub, ZoomOut
WinGetPos, xOffset, yOffset,,,A
fileJpg := "base.jpg"
filePng := "nnInputQuantized.png"
fileTxt := "baseHistQuantized.txt"
fileIns := "anji_2_01\properties\temp_stimuli.txt"
fileOut := "nnOutput.txt"
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
  
convertCmd=convert.exe %fileJpg% -remap colormap.png %filePng%
Runwait, %comspec% /c %convertCmd%,, Hide

; Wait for png file to exist
while NOT FileExist(filePng)
	Sleep, 10

convertCmd=convert.exe %filePng% -format `%c histogram:info:- > %fileTxt%
Runwait, %comspec% /c %convertCmd%,, Hide

; Wait for txt file to exist
while NOT FileExist(fileTxt)
	Sleep, 10
pix:=GetFlowPixels()
Gosub, EnemyGold
Gosub, EnemyElixir

FileDelete, %fileIns%
FileAppend,, %fileIns%
Loop, read, %fileTxt%, %fileIns%
{
	result:=SubStr(A_LoopReadLine,1,10)
	result:=RegExReplace(result," ")
	result:=result/7349.10
	FileAppend, %result%
	FileAppend, `;
}
result := enemyGold/8000.1000
FileAppend,%result%,%fileIns%
FileAppend, `;,%fileIns%
result := enemyElixir/8000.1000
FileAppend,%result%,%fileIns%
FileAppend, `;,%fileIns%
result:=pix/7349.10
FileAppend,%result%,%fileIns%
FileAppend, `n,%fileIns%

convertCmd= activate.bat CoC.properties 128833 > %fileOut%
Runwait, %comspec% /c %convertCmd%,, Hide

FileRead, result, %fileOut%
RegExMatch(result, "(?<=OUT \()([^ ]*)(?=\))",subpat)
IfInString, subpat, "E-"
	result := 0.0
else
	result := subpat

return result
}

GetDecision:
MsgBox % NNDecision()
return

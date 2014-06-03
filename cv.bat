for /f %%f in ('dir /b %~dp0\BasePictures') do (
	::convert %~dp0\BasePictures\%%f -negate -threshold 60%% -edge 5 -morphology EdgeOut Disk -fill white -floodfill +20+425 black -floodfill +20+375 black -floodfill +20+325 black -floodfill +20+275 black -floodfill +20+225 black -floodfill +1100+425 black -floodfill +1100+375 black -floodfill +1100+325 black -floodfill +1100+275 black -floodfill +1100+225 black %~dp0\Filtered\%%f
	::convert %~dp0\Filtered\%%f -format %%c histogram:info:- >%~dp0\Histograms\%%f.txt
	convert %~dp0\BasePictures\%%f -posterize 4 %~dp0\Filtered\%%f
	convert %~dp0\Filtered\%%f -format %%c histogram:info:- >%~dp0\Histograms\%%f.txt
)
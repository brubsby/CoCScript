for /f %%f in ('dir /b E:\GitHub\CoCScript\BasePictures') do (
	convert E:\GitHub\CoCScript\BasePictures\%%f -negate -threshold 60%% -edge 5 -morphology EdgeOut Disk -fill white -floodfill +20+425 black -floodfill +20+375 black -floodfill +20+325 black -floodfill +20+275 black -floodfill +20+225 black -floodfill +1100+425 black -floodfill +1100+375 black -floodfill +1100+325 black -floodfill +1100+275 black -floodfill +1100+225 black E:\GitHub\CoCScript\Filtered\%%f
	convert E:\GitHub\CoCScript\Filtered\%%f -format %%c histogram:info:- >E:\GitHub\CoCScript\Histograms\%%f.txt
)
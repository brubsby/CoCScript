setlocal ENABLEDELAYEDEXPANSION

for /f %%f in ('dir /b E:\GitHub\CoCScript\BasePictures\Filtered') do (
	SET file=%%f
	SET file=!file~0,2!
	convert E:\GitHub\CoCScript\BasePictures\Filtered\%%f -format %%c histogram:info:- ^> E:\GitHub\CoCScript\BasePictures\Filtered\Histograms\!file!.txt
)
@echo off
set MYCLASSPATH=.\lib\anji.jar;.\lib\jgap.jar;.\lib\log4j.jar;.\lib\jakarta-regexp-1.3.jar;.\lib\clibwrapper_jiio.jar;.\lib\mlibwrapper_jiio.jar;.\lib\jai_imageio.jar;.\lib\hb16.jar;.\lib\jcommon.jar;.\lib\jfreechart.jar;.\properties
cd anji_2_01
java -classpath %MYCLASSPATH% com.anji.neat.NeatActivator %1 %2
cd ..


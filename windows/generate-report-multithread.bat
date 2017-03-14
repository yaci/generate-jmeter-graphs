@echo off

rem Please specify the path of Command Line Plugin
rem In JMeter 2.x it's likely to be in JMETER_DIR\lib\ext\CMDRunner.jar 
rem while in JMeter 3.x it's located in JMETER_DIR\lib\cmdrunner-2.0.jar
set CMD_RUNNER="p:\ath\to\JMeter31\lib\cmdrunner-2.0.jar"

rem If there are any reports that you don't want to generate, simply remove them from array
rem Pay attention to quotes. Both variable name and value are surrounded with one pair of quotes.
set "VISUAL_REPORTS=ThreadsStateOverTime BytesThroughputOverTime HitsPerSecond LatenciesOverTime ResponseCodesPerSecond ResponseTimesDistribution ResponseTimesOverTime ResponseTimesPercentiles ThroughputVsThreads TimesVsThreads TransactionsPerSecond";
set "CSV_REPORTS=AggregateReport SynthesisReport"

rem ###!BE CAREFUL WHEN MODIFYING ANYTHING BELOW THIS LINE!###

set INPUT_FILE=%1
set RESULTS_DIR=./r2
set EXCLUDE_LABELS=""

if "%INPUT_FILE%"=="" (
goto :print_usage_and_exit
)
if not exist %INPUT_FILE% (
echo File %INPUT_FILE% does not exist.
goto :print_usage_and_exit
)

echo !! WARNING !!
echo This script will launch graph generation in multiple threads. Since there is no control over the number of threads in cmd shell, the script will attempt to launch all threads at once. If the jmeter result file that you are trying to process is too large then the script may run out of memory and this will severly slow down the computations. As a rule of thumb you need 13 x result_file_size of free memory for the computations to go smoothly. If you don't have enough memory available it may be better to use simple (single-threaded) version of the script.
set /P ANSWER=Do you want to continue? (y/n): %=%
if /I not "%ANSWER%"=="y" (
echo Exiting...
goto :eof
)
echo One more thing - there is no clear indication given when the jobs are finished. If the script appears to be frozen try pressing the Enter key.
pause

echo Generating reports under %RESULTS_DIR%
 
rem note that --loglevel parameter affects only kg.apc.* classes, jmeter.utils.* remains unaffected
for %%R in (%VISUAL_REPORTS%) do (
   start /B java -jar %CMD_RUNNER% --tool Reporter ^
                          --loglevel WARN ^
                          --generate-png %RESULTS_DIR%\%%R.png ^
                          --input-jtl %INPUT_FILE% ^
                          --plugin-type %%R ^
                          --width 1920 --height 1080 ^
                          --paint-markers no ^
                          --exclude-label-regex true
)


for %%R in (%CSV_REPORTS%) do (
   start /B java -jar %CMD_RUNNER% --tool Reporter ^
                          --loglevel WARN ^
                          --generate-csv %RESULTS_DIR%\%%R.csv ^
                          --input-jtl %INPUT_FILE% ^
                          --plugin-type %%R ^
                          --exclude-label-regex true
)

goto :eof

:print_usage_and_exit
echo Usage: report.bat p:\ath\to\result.<jtl|csv|txt>
goto :eof

:eof
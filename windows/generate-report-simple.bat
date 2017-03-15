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
IF NOT EXIST %INPUT_FILE% (
echo File %INPUT_FILE% does not exist.
goto :print_usage_and_exit
)

rem note that --loglevel parameter affects only kg.apc.* classes, jmeter.utils.* remains unaffected
for %%R in (%VISUAL_REPORTS%) do (
   echo Generating report: %%R
   java -jar %CMD_RUNNER% --tool Reporter ^
                          --generate-png %RESULTS_DIR%\%%R.png ^
                          --input-jtl %INPUT_FILE% ^
                          --plugin-type %%R ^
                          --width 1920 --height 1080 ^
                          --paint-markers no ^
                          --exclude-label-regex true
)

for %%R in (%CSV_REPORTS%) do (
   echo Generating report: %%R
   java -jar %CMD_RUNNER% --tool Reporter ^
                          --generate-csv %RESULTS_DIR%\%%R.csv ^
                          --input-jtl %INPUT_FILE% ^
                          --plugin-type %%R ^
                          --exclude-label-regex true
)

echo ALL DONE!
echo You can find results in %RESULTS_DIR%
goto :eof

:print_usage_and_exit
echo Usage: report.bat p:\ath\to\result.<jtl|csv|txt>
goto :eof
:eof
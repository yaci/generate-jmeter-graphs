$CMD_RUNNER = "p:\ath\to\JMeter31\lib\cmdrunner-2.0.jar"

$VISUAL_REPORTS = @("ThreadsStateOverTime", "BytesThroughputOverTime", "HitsPerSecond", "LatenciesOverTime", "ResponseCodesPerSecond", "ResponseTimesDistribution", "ResponseTimesOverTime", "ResponseTimesPercentiles", "ThroughputVsThreads", "TimesVsThreads", "TransactionsPerSecond");
$TEXT_REPORTS = @("AggregateReport", "SynthesisReport")

$EXCLUDE_LABELS = '\"[tT]rigger.*\"'

$INPUT_FILE = $args[ 0 ]
$RESULTS_DIR = Split-Path -r $INPUT_FILE #get parent directory of results file
$RESULTS_DIR = "$RESULTS_DIR\r2"

$TIMER=[system.diagnostics.stopwatch]::startNew()

ForEach ($REPORT in $VISUAL_REPORTS)
{
    echo "Generating graph: $REPORT"
    java -jar $CMD_RUNNER --tool Reporter `
                          --generate-png $RESULTS_DIR\$REPORT.png `
                          --input-jtl $INPUT_FILE `
                          --plugin-type $REPORT `
                          --width 1920 --height 1080 `
                          --paint-markers no `
                          --exclude-label-regex true `
                          --exclude-labels $EXCLUDE_LABELS | sls -n INFO
}

ForEach ($REPORT in $TEXT_REPORTS)
{
    echo "Generating CSV: $REPORT"
    java -jar $CMD_RUNNER --tool Reporter `
                          --generate-csv $RESULTS_DIR\$REPORT.csv `
                          --input-jtl $INPUT_FILE `
                          --plugin-type $REPORT `
                          --exclude-label-regex true `
                          --exclude-labels $EXCLUDE_LABELS | sls -n INFO
}

$TIMER.stop()
echo "Generated in: $($TIMER.Elapsed)"
echo "Reports generated under $RESULTS_DIR"

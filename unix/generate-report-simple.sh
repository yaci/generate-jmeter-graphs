#! /bin/bash

# Please specify the path of Command Line Plugin
# In JMeter 2.x it's likely to be in JMETER_DIR/lib/ext/CMDRunner.jar 
# while in JMeter 3.x it's located in JMETER_DIR/lib/cmdrunner-2.0.jar
CMD_RUNNER=$JMETER_HOME/lib/ext/CMDRunner.jar

#if there are any thread groups that you don't want to be shown in results, include their labels here
EXCLUDE_LABELS="\"[lL]abel.*\""

#if there are any reports that you don't want to generate, simply remove them from array
VISUAL_REPORTS=(ThreadsStateOverTime BytesThroughputOverTime HitsPerSecond LatenciesOverTime ResponseCodesPerSecond ResponseTimesDistribution ResponseTimesOverTime ResponseTimesPercentiles ThroughputVsThreads TimesVsThreads TransactionsPerSecond)
TEXT_REPORTS=(AggregateReport SynthesisReport)

###!BE CAREFUL WHEN MODIFYING ANYTHING BELOW THIS LINE!###

if [ "$#" -ne 1 ]; then
    echo "USAGE: ./$(basename $0) testResults.jtl"
    exit -1
fi

export JVM_ARGS="-Xms1024m -Xmx1024m"

INPUT_FILE=$1
RESULTS_DIR=$(dirname $INPUT_FILE)

START=$(date +%s)

for REPORT in "${VISUAL_REPORTS[@]}"
do
    echo "Generating graph: $REPORT"
    java -jar $CMD_RUNNER --tool Reporter \
                          --loglevel WARN \
                          --generate-png $RESULTS_DIR/$REPORT.png \
                          --input-jtl $INPUT_FILE \
                          --plugin-type $REPORT \
                          --width 1920 --height 1080 \
                          --paint-markers no \
                          --exclude-label-regex true \
                          --exclude-labels $EXCLUDE_LABELS

done

for REPORT in "${TEXT_REPORTS[@]}" 
do
    echo "Generating CSV: $REPORT"
    java -jar $CMD_RUNNER --tool Reporter \
                          --loglevel WARN \
                          --generate-csv $RESULTS_DIR/$REPORT.csv \
                          --input-jtl $INPUT_FILE \
                          --plugin-type $REPORT \
                          --exclude-label-regex true \
                          --exclude-labels $EXCLUDE_LABELS
done

STOP=$(date +%s)
echo
echo "DONE! All reports generated in about $(($STOP - $START)) seconds."
echo "Reports generated under $RESULTS_DIR"

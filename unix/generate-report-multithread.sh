#! /bin/bash

# Please specify the path of Command Line Plugin
# In JMeter 2.x it's likely to be in JMETER_DIR/lib/ext/CMDRunner.jar 
# while in JMeter 3.x it's located in JMETER_DIR/lib/cmdrunner-2.0.jar (or -2.1.jar)
CMD_RUNNER=$JMETER_HOME/lib/ext/CMDRunner.jar

#if there are any thread groups that you don't want to be shown in results, include their labels here
EXCLUDE_LABELS="\"[lL]abel.*\""

#if there are any reports that you don't want to generate, simply remove them from array
VISUAL_REPORTS=(ThreadsStateOverTime BytesThroughputOverTime HitsPerSecond LatenciesOverTime ResponseCodesPerSecond ResponseTimesDistribution ResponseTimesOverTime ResponseTimesPercentiles ThroughputVsThreads TimesVsThreads TransactionsPerSecond);
TEXT_REPORTS=(AggregateReport SynthesisReport)

###!BE CAREFUL WHEN MODIFYING ANYTHING BELOW THIS LINE!###

if [ "$#" -ne 2 ]; then
    echo "USAGE: ./$(basename $0) <testResults.jtl> <threadsLimit>"
    exit -1
fi

export JVM_ARGS="-Xms1024m -Xmx1024m"

INPUT_FILE=$1
THREAD_LIMIT=$2

#defining result directory as ./results/testFileName_YYYY-MM-DD-HHMM
RESULTS_DIR="./results/$(basename $INPUT_FILE .jmx)_$(date +%Y-%m-%d-%H%M)"

START=$(date +%s)
echo "Generating reports under $RESULTS_DIR"

#note that --loglevel parameter affects only kg.apc.* classes, jmeter.utils.* remain unaffected
GENERATE_GRAPHS_COMMAND="echo Generating {}; \
          java -jar $CMD_RUNNER --loglevel WARN \
              --tool Reporter \
              --plugin-type {} \
              --generate-png $RESULTS_DIR/{}.png \
              --input-jtl $INPUT_FILE \
              --width 1920 --height 1080 \
              --paint-markers no \
              --exclude-label-regex true \
              --exclude-labels $EXCLUDE_LABELS"

GENERATE_CSV_COMMAND="echo Generating{}; \
          java -jar $CMD_RUNNER --loglevel WARN \
              --tool Reporter --plugin-type {} \
              --generate-csv $RESULTS_DIR/{}.csv \
              --input-jtl $INPUT_FILE \
              --exclude-label-regex true \
              --exclude-labels $EXCLUDE_LABELS"

#for each element in array it takes the above GENERATE_GRAPHS_COMMAND, GENERATE_CSV_COMMAND
#and performs all substitutions
#so the result is a block of text, one command per line with all params substituted (i.e. ready to execute)
GRAPH_COMMANDS_SET=$(printf "%s\n" "${VISUAL_REPORTS[@]}" | xargs -n 1 -I {} echo "$GENERATE_GRAPHS_COMMAND")
CSV_COMMANDS_SET=$(printf "%s\n" "${TEXT_REPORTS[@]}" | xargs -n 1 -I {} echo "$GENERATE_CSV_COMMAND")

#here xargs takes commands one by one from stdin (in this example from echo output) and executes them in multiple threads
echo -e "$CSV_COMMANDS_SET\n$GRAPH_COMMANDS_SET" | xargs -n 1 -P $THREAD_LIMIT -i sh -c "{}"
wait

STOP=$(date +%s)

echo
echo "DONE! Generation took about $(($STOP - $START)) seconds."
echo "Reports are stored under $RESULTS_DIR"

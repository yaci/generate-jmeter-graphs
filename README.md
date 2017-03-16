Purpose
=======
This project contains set of scripts for analysing JMeter test results, both in Windows and Unix systems. The nice thing is that the script is multi-threaded so graph generation is much faster.

Why to use it?
-------------
JMeter >3.0 comes with native graph generation. One may argue that it's pointless to use the old, plugin-based way. It is true for many projects, but there are some benefits to old way
* it's much less memory consuming. For large result files you can easily run out of memory when trying to generate jmeter dashboard. In such case "the old way" is the only way.
* old graphs may be more readable (I know it's subjective)

Structure
---------
Windows and unix folders contain scripts for the respective operating systems. Each folder contains the following
* run-simple - generating graphs one after another - slower but unlikely to cause any problems. These files are also easier to understand so if you want to analyze the code they are a good starting point.
* run-parallel - generating graphs in parallel in multiple threads - much faster, but consumes lots of memory   

Additionaly saveservice.properties contains a set of properties that can be passed to JMeter when running a test to get a proper result file (csv/jtl) that can be further processed into graphs.


Prerequisites
-------------
* [JMeter](https://jmeter.apache.org/download_jmeter.cgi) (you can run it on older versions (2.x) too)
* for JMeter 2.x you need to install plugins manually [JMeter Plugins](http://jmeter-plugins.org)
* for JMeter 3.x I recomment to use plugins manager (download the Plugins Manager [JAR](https://jmeter-plugins.org/get/) file and put it into JMeter's lib/ext directory. Then start JMeter and go to "Options" menu to access the Plugins Manager. More details: https://jmeter-plugins.org/wiki/PluginsManager/)
* using plugins manager please install the following plugins
  * Command-Line Graph Plotting Tool (aka JMeter command line plugin in older versions)
  * 3 basic graphs
  * 5 additional graphs
  * Distribution/Percentile Graphs
  * KPI vs KPI Graphs
  * synthesis report 

Running tests
-------------
The easiest way to get proper results is to run
```
jmeter -n -t <yourTest.jmx> -q saveservice.properties -l whateverNameResultFile.jtl
```
where yourTest is your JMeter test file. Saveservice.properties can be found in this repo.
More details: https://jmeter.apache.org/usermanual/get-started.html#non_gui

Generating graphs
-------------
Simply run `name-of-script p:/ath/to/your/result/file`

Known issues
---------------
1. You may see the following warnings in the console:

    ```
    WARN Exception 'null' occurred when fetching String property:'sampleresult.default.encoding', defaulting to:ISO-8859-1
    WARN Exception 'null' occurred when fetching String property:'jmeterPlugin.prefixPlugins'
    ```
    Unfortunately setting these properties in jmeter.properties file seem to have no effect and I don't know how to get rid of these warnings. (I mean piping it to grep -v (or sls in powershell) will do the job, but this is ugly so I am not recommending it)   

2. `Unable to locate JAR file` message   
This may appear when you are working on some kind of emulator (like cygwin, git bash, etc) and java cannot figure out what kind of paths you are using. The easiest solution is to place the script in jmeter/bin directory and simply set `CMD_RUNNER=cmdrunner-2.0.jar` (or however the jar is called in your JMeter version) in the script.   

3. You see the following message when trying to run the script in Powershell   
`File ... cannot be loaded because running scripts is disabled on this system.`   
You need to allow PS to run scripts first by executing   
`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

4. Problems with viewing saveservice.properties file in Windows' Notepad   
On Windows you won't be able to edit the file in Notepad because the file uses unix line endings. I can only hope that everyone is using [Notepad++](https://notepad-plus-plus.org/) so this won't be an issue.
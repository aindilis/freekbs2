#!/bin/sh
#
# opencyc-api-test.sh
#
# shell script that executes the OpenCyc api unit test
#
# written by Stephen Reed  12/8/04
#
# This script must be executed from the release java directory,
# Usage:    ./opencyc-api-test.sh <cyc host> <cyc base port>
# example:  ./opencyc-api-test.sh localhost 3600 (this is the default if no arguments are given)

CLASSPATH=/var/lib/myfrdcsa/sandbox/opencyc-2.0/opencyc-2.0/api/java/build/OpenCyc.jar
CLASSPATH=$CLASSPATH:/var/lib/myfrdcsa/sandbox/opencyc-2.0/opencyc-2.0/api/java/lib/UtilConcurrent.jar
CLASSPATH=$CLASSPATH:/var/lib/myfrdcsa/sandbox/opencyc-2.0/opencyc-2.0/api/java/lib/junit.jar
CLASSPATH=$CLASSPATH:/var/lib/myfrdcsa/sandbox/opencyc-2.0/opencyc-2.0/api/java/lib/jakarta-oro-2.0.4.jar
echo $CLASSPATH
_JAVA_OPTIONS="-Xms1664m -Xmx1664m -XX:NewSize=256m -XX:MaxNewSize=256m"

java -cp $CLASSPATH org.opencyc.parser.CycLParserUtil "(#$isa ?X ?Y)"

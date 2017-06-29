#!/bin/sh

# java -cp /var/lib/myfrdcsa/sandbox/opencyc-2.0/opencyc-2.0/api/java/build/classes/org/opencyc/parser CycLParserUtil "(#$isa ?X ?Y)"

java -cp /var/lib/myfrdcsa/sandbox/opencyc-2.0/opencyc-2.0/api/java/build/OpenCyc.jar:/var/lib/myfrdcsa/sandbox/opencyc-2.0/opencyc-2.0/api/java/lib org.opencyc.parser.CycLParserUtil "(#$isa ?X ?Y)"
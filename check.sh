#!/bin/sh

var=`egrep -o -w "\[+.+]" "./ip.txt"`
echo $var

#!/bin/bash

for test in test/**/*.tpc
do
	echo $(./bin/tpcas < $test 2>>rapport.txt;i=$?;$(echo $test renvoie $i>>rapport.txt ))
done




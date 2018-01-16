#!/bin/bash

for nimf in `ls src`;
do
    if [ $nimf == 'main.nim' ] || [ -d src/$nimf ] ; then
        continue
    fi

    echo "============================="
    echo test src/$nimf
    echo "============================="

    nim c -r src/$nimf

    exe=$(echo $nimf | sed 's/.nim$//')
    rm src/$exe
    
done
#!/bin/bash

# usage:
#   ./test.sh <moudle-name>
#   ./test.sh
#
# e.g. 
# ./test.sh configs     # test configs.nim moudle
# ./test.sh             # test all moudles

function test {
    moudle=$1
    moudle_path=src/$moudle.nim

    echo "============================="
    echo test $moudle_path
    echo "============================="

    nim c -r $moudle_path
    exe="src/$moudle"
    rm $exe
}

function test_all {
    for nimf in `ls src`;
    do
        if [ $nimf == 'main.nim' ] || [ -d src/$nimf ] ; then
            continue
        fi

        moudle=$(echo $nimf | sed 's/.nim$//')

        test $moudle

    done
}

if [ $# -eq 0 ]; then
    test_all
else
    moudle=$1
    test $moudle
fi
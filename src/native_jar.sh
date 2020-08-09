LIBS=../env/lib/java
OUT=$LIBS
NAME=$1

mkdir $OUT
rm -rf temp
mkdir temp

set -e

find ./$NAME/java -name '*.java' | xargs javac -g -cp $LIBS/fanx.jar:$LIBS/sys.jar:$LIBS/std.jar:$LIBS/stub/sys.jar:$LIBS/stub/std.jar:$LIBS/stub/concurrent.jar -d temp

jar cvf $OUT/$NAME.jar -C temp .

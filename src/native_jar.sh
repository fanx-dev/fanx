LIBS=../env/lib/java
OUT=$LIBS
NAME=$1

mkdir $OUT
rm -rf temp
mkdir temp

find ./$NAME/java -name '*.java' | xargs javac -g -cp $LIBS/fanx.jar:$LIBS/sys.jar:$LIBS/std.jar:$LIBS/stub/sys.jar:$LIBS/stub/std.jar -d temp

jar cvf $OUT/$NAME.jar -C temp .

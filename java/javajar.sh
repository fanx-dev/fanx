
OUT=libs
NAME=$1

rm -rf temp
mkdir temp
find ./$NAME -name '*.java' | xargs javac -g -cp libs/fan_gen.jar:libs/sys.jar:libs/std.jar:libs/sys_nat.jar -d temp

jar cvf $OUT/$NAME.jar -C temp .

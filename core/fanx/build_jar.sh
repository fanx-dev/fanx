
OUT=../../devEnv/lib/java
NAME=fanx
mkdir -p ../../devEnv/lib/java/stub

rm -rf temp
mkdir temp
find ./$NAME -name '*.java' | xargs javac -g -d temp
jar cvf $OUT/$NAME.jar -C temp .


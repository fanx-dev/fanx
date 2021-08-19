
OUT=../env/lib/java
NAME=fanx
mkdir -p ../env/lib/java/stub

mkdir temp
find ./javaEmit -name '*.java' | xargs javac -source 8 -target 8 -g -d temp
jar cvf $OUT/$NAME.jar -C temp .

rm -rf temp


OUT=../../env/lib/java
NAME=fanx

rm -rf temp
mkdir temp
find ./$NAME -name '*.java' | xargs javac -g -d temp
jar cvf $OUT/$NAME.jar -C temp .


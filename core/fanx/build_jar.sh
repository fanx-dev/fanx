
OUT=../../devEnv/lib/java
HOME_DIR=../../env/lib/java
NAME=fanx
mkdir -p ../../devEnv/lib/java/stub

rm -rf temp
mkdir temp
find ./$NAME -name '*.java' | xargs javac -g -d temp
jar cvf $OUT/$NAME.jar -C temp .

cp $OUT/$NAME.jar $HOME_DIR/$NAME.jar

OUT=../env/lib/java

sh jstub.sh

sh javajar.sh fan_gen
sh javajar.sh sys_nat
sh javajar.sh std_nat
rm -rf temp

mv libs/fan_gen.jar $OUT
mv libs/sys_nat.jar $OUT
mv libs/std_nat.jar $OUT

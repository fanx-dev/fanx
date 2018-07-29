
OUT=../env/lib/java
jar cvf $OUT/fan_gen.jar -C fan_gen/bin .
jar cvf $OUT/sys_nat.jar -C sys_nat/bin .
jar cvf $OUT/std_nat.jar -C std_nat/bin .
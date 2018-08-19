#! /bin/sh
#fast jar IDE bin class for test

OUT=../env/lib/java
jar cvf $OUT/fanx.jar -C fanx/bin .
jar cvf $OUT/sys_nat.jar -C sys/java/bin .
jar cvf $OUT/std_nat.jar -C std/java/bin .
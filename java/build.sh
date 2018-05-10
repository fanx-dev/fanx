mkdir libs
java -cp fan_gen/bin fanx.main.Jstub -v sys -d libs
java -cp fan_gen/bin fanx.main.Jstub -v std -d libs
java -cp fan_gen/bin fanx.main.Jstub -v reflect -d libs
java -cp fan_gen/bin fanx.main.Jstub -v testlib -d libs

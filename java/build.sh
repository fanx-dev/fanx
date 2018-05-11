mkdir libs
jstub='java -cp fan_gen/bin fanx.main.Jstub -v -d libs'
$jstub sys
$jstub std
$jstub reflect
$jstub testlib
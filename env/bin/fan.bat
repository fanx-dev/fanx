@echo OFF
REM fantom launcher

SET FAN_HOME=%~dp0%..
pushd "%FAN_HOME%"
SET FAN_HOME=%CD%
popd

java -cp %FAN_HOME%\lib\java\fanx.jar -Dfan.home=\%FAN_HOME%\ fanx.tools.Fan %*


### Run in VM ###

The default runtime is JVM. fanrun vm is a simple interpreter.
```
fanvm podName[::TypeName][.methodName]

```

Build from sources:

- xcode: fanx/runtime/fanRun.xcworkspace
- visual studio: fanx/runtime/fanRun.vcproject/vm.sln

### Gen to C ###

Compile to C:
```
fangen -r podName
```

Header search path:

```
../../fanx/runtime/common
../../fanx/runtime/gen
../../fanx/runtime/fni 
../../fanx/runtime 
../../fanx/runtime/gen/runtime 
../../fanx/runtime/gen/temp
```

Amalgamation File:
```
fanx/runtime/gen/fr_gen.c
fanx/runtime/gen/fr_gen.cpp
fanx/runtime/fni/corelib.c
fanx/runtime/fni/corelib.cpp

```

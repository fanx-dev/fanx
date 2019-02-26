
## Setup

### Setup Exe Path ###

The current implementation requires that 
you have a "java" command available in your environment.

To add "bin" into your path:
```
Unix:
  PATH=$PATH:/apps/env/bin
  chmod +x /apps/env/bin/*

Windows:

  PATH=%PATH%;C:\dev\env\bin
```

If your path is configured properly, you should be able to run
```
  fan -version
```

### Run ###

Run as script:
```
  fan scriptFile.fan
```
Run pod:
```
Build pod:
  fanb dir/pod.props

Run pod:
  fan Main::main
```
Run test:
```
  fant testSys::StrTest
```

### Custom Env Path ###
The Env define pods search path and resources search path.
The search path is specified with the FAN_ENV_PATH envirnomenal variable:
```
export FAN_ENV_PATH=/apps/devEnv/
```

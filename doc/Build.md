

## Build from Sources

### Build ###

```
  cd src
  sh build_all.sh
  sh test_all.sh
```

### Build Ext Librarys ###
clone hg repo
```
  hg clone http://bitbucket.org/chunquedong/fan-1.0
```
build:
```
  cd src
  sh build_lib.sh
```

### API Docs ###
generate the HTML docs
```
  fan compilerDoc -all
```

### Bootstrap Configs ###

Config output dir:
```
  env/etc/build/config.props
    devHome=xxx/env/
```
Config compile depends env:
```
  env/etc/compiler/config.props
    devHome=xxx/env/
```

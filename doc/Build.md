

## Build from Sources

### Bootstrap Build ###
clone fanx repo
```
  git clone https://github.com/fanx-dev/fanx.git
```
download [last release](https://github.com/fanx-dev/fanx/releases).
Unzip to git repo dir and rename to release. the directory tree like this:
```
  fanx/
     env/
       bin/
       ...
     src/
       ...
     release/
       bin/
       etc/
       lib/
       ...
```
run build:
```
  cd src
  sh build_all.sh
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


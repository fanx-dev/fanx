

## Build from Sources

### Bootstrap Build ###
1. Clone fanx repo
```
  git clone https://github.com/fanx-dev/fanx.git
```
2. Download [last release](https://github.com/fanx-dev/fanx/releases). And unzip to git repo dir and rename to release. The directory tree like this:
```
  fanx/
     env/
       bin/
       ...
     compiler/
       ...
     release/
       fanx-*.*/
         bin/
         etc/
         lib/
         ...
```
3. Config jdkHome
Edit the file in:
```
env/etc/build/config.props
release/fanx-*.*/etc/build/config.pros
```
4. Run build:
```
  sh build_all.sh
```

### Build Ext Librarys ###
clone hg repo
```
  hg clone https://github.com/fanx-dev/fantom.git
```
build:
```
  cd src
  sh build_lib.sh
```
